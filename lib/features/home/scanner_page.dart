import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/service_locator.dart';

@RoutePage()
class ScannerPage extends StatefulWidget {
  /// When provided, the captured image is handed back to the caller (and the
  /// page pops) instead of dispatching a Home scan. Used by the onboarding
  /// current-food step so the same camera UI works outside the Home tab.
  final void Function(String imageBase64, String mimeType)? onCaptured;

  const ScannerPage({super.key, this.onCaptured});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isInitializing = false;
  bool _isTakingPicture = false;
  bool _hasCameraError = false;

  /// Camera access is resolved once per scanner open, not once per
  /// `_initCamera` — the lifecycle handler re-inits on every resume, and a
  /// permission answer that has not changed is not news.
  bool _accessReported = false;

  /// Set when a photo is handed onward. Its absence at dispose is what makes
  /// the visit a cancellation.
  bool _captured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Opening the camera and backing out used to look identical to never
    // opening it: `Product Image Captured` was the first event in the funnel,
    // so everything upstream of the shutter was invisible.
    if (!_captured) {
      sl<LogEventUsecase>().call(
        eventName: AnalyticsEvents.scanCancelled,
        properties: {
          // Distinguishes "changed their mind" from "the camera never worked".
          'camera_ready': _isCameraInitialized,
          'camera_error': _hasCameraError,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
    _cameraController?.dispose();
    super.dispose();
  }

  /// Reports whether the camera is usable, exactly once per scanner open.
  ///
  /// The plugin surfaces a permission refusal as a `CameraException` whose code
  /// is one of the `CameraAccess*` values, so denial is separable from a device
  /// with no camera or a driver failure — worth keeping apart, because only the
  /// first is recoverable by the user in Settings.
  void _reportCameraAccess({required bool granted, String? errorCode}) {
    if (_accessReported) return;
    _accessReported = true;
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.cameraAccessResult,
      properties: {
        'granted': granted,
        if (errorCode != null) 'error_code': errorCode,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    // Ignore lifecycle churn while there's no live, initialized controller —
    // notably the inactive event the iOS permission prompt itself triggers
    // during the very first initialize(). Tearing the controller down here
    // would race the in-flight init and leave the preview black.
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    if (mounted) {
      setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _initCamera() async {
    if (_isCameraInitialized || _isInitializing) return;
    _isInitializing = true;

    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        _reportCameraAccess(granted: false, errorCode: 'no_camera');
        setState(() => _hasCameraError = true);
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _reportCameraAccess(granted: true);
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _hasCameraError = false;
        });
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      _reportCameraAccess(
        granted: false,
        errorCode: e is CameraException ? e.code : 'unknown',
      );
      if (mounted) {
        setState(() => _hasCameraError = true);
      }
    } finally {
      _isInitializing = false;
    }
  }

  void _onImageCaptured(String imageBase64, String mimeType) {
    _captured = true;
    final router = context.router;

    // Caller-handled mode (e.g. onboarding): hand the image back and pop.
    final onCaptured = widget.onCaptured;
    if (onCaptured != null) {
      onCaptured(imageBase64, mimeType);
      router.maybePop();
      return;
    }

    final bloc = context.read<HomeBloc>();
    // Device region (e.g. "ES") from the OS locale — biases backend web_search
    // to the user's market. Uses platformDispatcher (the device locale), not
    // Localizations (the app locale, which is language-only here).
    final countryCode =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode;
    // App language (e.g. "fr") for translated product copy. Deliberately
    // Localizations, not platformDispatcher: this is the locale the app
    // actually resolved to, so an unsupported device language correctly asks
    // for English rather than a language we don't ship.
    final locale = Localizations.localeOf(context).languageCode;
    // Capture the router controller while still mounted — the scan resolves
    // after this page pops, so navigating via this page's context later would
    // throw. The controller persists past the pop.
    bloc.add(ImageCapturedEvent(
      imageBase64: imageBase64,
      mimeType: mimeType,
      router: router,
      countryCode: countryCode,
      locale: locale,
    ));
    router.maybePop();
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isTakingPicture = true);

    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await File(xFile.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = xFile.mimeType ?? 'image/jpeg';
      _onImageCaptured(base64Image, mimeType);
    } catch (e) {
      debugPrint('Take picture error: $e');
    } finally {
      if (mounted) {
        setState(() => _isTakingPicture = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final bytes = await File(pickedFile.path).readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = pickedFile.mimeType ?? 'image/jpeg';
    _onImageCaptured(base64Image, mimeType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.inkPrimary,
      body: Stack(
        children: [
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    // previewSize is reported landscape; swap for portrait UI.
                    width: _cameraController!.value.previewSize!.height,
                    height: _cameraController!.value.previewSize!.width,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            ),

          // Scanning overlay — reticle + sweeping coral line. Only while the
          // live preview is up; hidden on the error path. IgnorePointer lets
          // the shutter/gallery taps fall through to the controls below.
          if (_isCameraInitialized && !_hasCameraError)
            const Positioned.fill(
              child: IgnorePointer(child: _ScanOverlay()),
            ),

          if (_hasCameraError) Positioned.fill(child: _CameraErrorView(
            onPickFromGallery: _pickFromGallery,
          )),

          // Top close button
          Positioned(
            top: MediaQuery.of(context).padding.top + DSDimens.sizeS,
            left: DSDimens.sizeL,
            child: _ChromeButton(
              icon: Icons.close_rounded,
              onTap: () => context.router.maybePop(),
            ),
          ),

          // Bottom controls (hidden when the camera is unavailable — the
          // error view offers the gallery fallback instead).
          if (!_hasCameraError)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(context).padding.bottom + DSDimens.sizeM,
                  top: DSDimens.sizeL,
                  left: DSDimens.size3xl,
                  right: DSDimens.size3xl,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ChromeButton(
                      icon: Icons.photo_outlined,
                      onTap: _pickFromGallery,
                    ),
                    GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DSColors.inkInverse,
                            width: 4,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: DSColors.inkInverse,
                          ),
                        ),
                      ),
                    ),
                    // Spacer to balance the shutter
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Live-camera scanning effect: a centered reticle (corner brackets) over a
/// gently dimmed surround, with a glowing coral line sweeping inside it.
/// Mirrors the scan-line idiom from `home_loading_page.dart` (`_ScanCard`) so
/// the live scanner and the post-capture loading screen feel like one motion.
class _ScanOverlay extends StatefulWidget {
  const _ScanOverlay();

  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<_ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Scan window: a portrait rounded rectangle sized to fit typical packages
  // (cans, pouches, bags). It's a soft framing guide only — the full camera
  // frame is still captured, so loose framing never clips the label.
  static const double _windowWidthFactor = 0.74; // fraction of screen width
  static const double _windowAspect = 1.3; // height / width — taller than wide
  static const double _lineHeight = 3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final w = size.width * _windowWidthFactor;
    final h = w * _windowAspect;
    // Sit the window slightly above centre so the bottom shutter row and the
    // hint caption have room beneath it.
    final left = (size.width - w) / 2;
    final top = (size.height - h) / 2 - DSDimens.size3xl;
    final window = Rect.fromLTWH(left, top, w, h);

    return Stack(
      children: [
        // Dim surround + corner brackets.
        Positioned.fill(
          child: CustomPaint(
            painter: _ScanReticlePainter(window: window),
          ),
        ),

        // Sweeping glow line, clipped to the scan window.
        Positioned.fromRect(
          rect: window,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DSRadii.xl),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_controller.value);
                final y = t * (h - _lineHeight);
                return Stack(
                  children: [
                    Positioned(
                      top: y,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: _lineHeight,
                        decoration: BoxDecoration(
                          color: DSColors.coralAccent,
                          boxShadow: [
                            BoxShadow(
                              color: DSColors.coralAccent
                                  .withValues(alpha: 0.6),
                              blurRadius: 18,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // Hint caption below the window.
        Positioned(
          left: DSDimens.sizeL,
          right: DSDimens.sizeL,
          top: window.bottom + DSDimens.sizeL,
          child: Text(
            AppLocalizations.of(context).homeScannerHint,
            textAlign: TextAlign.center,
            style: DSTextStyles.label.copyWith(
              color: DSColors.inkInverse,
              shadows: const [
                Shadow(color: Color(0x99000000), blurRadius: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints a translucent scrim over everything except the rounded scan window,
/// then draws four L-shaped corner brackets framing that window.
class _ScanReticlePainter extends CustomPainter {
  final Rect window;

  const _ScanReticlePainter({required this.window});

  static const double _bracketArm = 26;
  static const double _bracketStroke = 3;
  static const double _radius = DSRadii.xl;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      window,
      const Radius.circular(_radius),
    );

    // Dim surround: fill the whole canvas, then punch out the window.
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = DSColors.inkPrimary.withValues(alpha: 0.45),
    );
    canvas.drawRRect(
      rrect,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();

    // Corner brackets.
    final stroke = Paint()
      ..color = DSColors.inkInverse
      ..style = PaintingStyle.stroke
      ..strokeWidth = _bracketStroke
      ..strokeCap = StrokeCap.round;

    final r = _radius;
    final l = window.left;
    final t = window.top;
    final right = window.right;
    final b = window.bottom;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(l, t + r + _bracketArm)
        ..lineTo(l, t + r)
        ..arcToPoint(Offset(l + r, t), radius: Radius.circular(r))
        ..lineTo(l + r + _bracketArm, t),
      stroke,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(right - r - _bracketArm, t)
        ..lineTo(right - r, t)
        ..arcToPoint(Offset(right, t + r), radius: Radius.circular(r))
        ..lineTo(right, t + r + _bracketArm),
      stroke,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(right, b - r - _bracketArm)
        ..lineTo(right, b - r)
        ..arcToPoint(Offset(right - r, b), radius: Radius.circular(r))
        ..lineTo(right - r - _bracketArm, b),
      stroke,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(l + r + _bracketArm, b)
        ..lineTo(l + r, b)
        ..arcToPoint(Offset(l, b - r), radius: Radius.circular(r))
        ..lineTo(l, b - r - _bracketArm),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_ScanReticlePainter oldDelegate) =>
      oldDelegate.window != window;
}

class _CameraErrorView extends StatelessWidget {
  final VoidCallback onPickFromGallery;

  const _CameraErrorView({required this.onPickFromGallery});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: DSColors.inkPrimary,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.size3xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: DSColors.inkInverse,
                size: 48,
              ),
              const SizedBox(height: DSDimens.sizeL),
              Text(
                l10n.homeCameraUnavailable,
                style: DSTextStyles.titleMd.copyWith(
                  color: DSColors.inkInverse,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSDimens.sizeXs),
              Text(
                l10n.homeCameraUnavailableBody,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkInverse.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSDimens.sizeXl),
              FilledButton.icon(
                onPressed: onPickFromGallery,
                icon: const Icon(Icons.photo_outlined),
                label: Text(l10n.homeChooseFromGallery),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChromeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ChromeButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x33FFFFFF),
      shape: const CircleBorder(
        side: BorderSide(color: Color(0x66FFFFFF), width: 1.5),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: DSColors.inkInverse, size: 22),
        ),
      ),
    );
  }
}

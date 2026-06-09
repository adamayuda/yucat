import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';
import 'package:yucat/features/home/bloc/home_event.dart';

@RoutePage()
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  bool _hasCameraError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
    if (_isCameraInitialized) return;

    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() => _hasCameraError = true);
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _hasCameraError = false;
        });
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        setState(() => _hasCameraError = true);
      }
    }
  }

  void _onImageCaptured(String imageBase64, String mimeType) {
    final bloc = context.read<HomeBloc>();
    // Capture the router controller while still mounted — the scan resolves
    // after this page pops, so navigating via this page's context later would
    // throw. The controller persists past the pop.
    final router = context.router;
    bloc.add(ImageCapturedEvent(
      imageBase64: imageBase64,
      mimeType: mimeType,
      router: router,
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
                  fit: BoxFit.cover,
                  child: SizedBox(
                    // previewSize is reported landscape; swap for portrait UI.
                    width: _cameraController!.value.previewSize!.height,
                    height: _cameraController!.value.previewSize!.width,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
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

class _CameraErrorView extends StatelessWidget {
  final VoidCallback onPickFromGallery;

  const _CameraErrorView({required this.onPickFromGallery});

  @override
  Widget build(BuildContext context) {
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
                'Camera unavailable',
                style: DSTextStyles.titleMd.copyWith(
                  color: DSColors.inkInverse,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSDimens.sizeXs),
              Text(
                'Enable camera access for YuCat in Settings, or pick a photo '
                'from your gallery instead.',
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkInverse.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSDimens.sizeXl),
              FilledButton.icon(
                onPressed: onPickFromGallery,
                icon: const Icon(Icons.photo_outlined),
                label: const Text('Choose from gallery'),
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

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/services/scan_tracking_service.dart';
import 'package:yucat/service_locator.dart';

class HomeLoadedPage extends StatefulWidget {
  final Function(String) onBarcodeDetected;
  final bool hasScanned;
  // final HomeBloc bloc;
  // final List<ProductDisplayModel>? searchResults;

  HomeLoadedPage({
    super.key,
    required this.onBarcodeDetected,
    this.hasScanned = false,
  });

  @override
  State<HomeLoadedPage> createState() => _HomeLoadedPageState();
}

class _HomeLoadedPageState extends State<HomeLoadedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start or pause scanner after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateScannerState();
    });
  }

  @override
  void didUpdateWidget(HomeLoadedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle changes to hasScanned
    if (oldWidget.hasScanned != widget.hasScanned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _updateScannerState();
      });
    }
  }

  void _updateScannerState() {
    if (!mounted) return;
    try {
      if (widget.hasScanned) {
        _scannerController.pause();
      } else {
        _scannerController.start();
      }
    } catch (e) {
      debugPrint('Error updating scanner state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _scannerController,
      overlayBuilder: _overlayBuilder,
      onDetect: onDetect,
    );
  }

  void onDetect(BarcodeCapture capture) {
    print('===============================================: $capture');
    _scannerController.pause();

    // if (widget.hasScanned) return; // Prevent multiple scans
    // print('hasScanned: ${widget.hasScanned}');

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        debugPrint('Scanned barcode: ${barcode.rawValue}');
        // Stop scanning to prevent multiple calls
        // widget._scannerController.start();

        widget.onBarcodeDetected(barcode.rawValue!);
        break;
      }
    }
  }

  Widget _overlayBuilder(BuildContext context, BoxConstraints constraints) {
    final size = constraints.biggest;
    // Rectangle for barcode scanning: wider than tall
    final scanSize = Size(size.width * 0.8, size.width * 0.5);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            size: size,
            painter: ScannerOverlayPainter(
              scanSize: scanSize,
              screenSize: size,
              scanProgress: _animationController.value,
            ),
          );
        },
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Size scanSize;
  final Size screenSize;
  final double scanProgress;

  ScannerOverlayPainter({
    required this.scanSize,
    required this.screenSize,
    required this.scanProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the position of the scan square (centered)
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanSize.width,
      height: scanSize.height,
    );

    // Draw full screen black overlay with opacity 0.5
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Create a path for the full screen
    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a path for the scan square (rounded rectangle)
    const radius = 30.0;
    final scanSquarePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanRect, const Radius.circular(radius)),
      );

    // Cut out the scan square from the overlay
    final overlayPath = Path.combine(
      PathOperation.difference,
      fullScreenPath,
      scanSquarePath,
    );

    // Draw the overlay with cutout
    canvas.drawPath(overlayPath, overlayPaint);

    // Draw scanning line effect
    final scanLineY = scanRect.top + (scanRect.height * scanProgress);

    // Save canvas state and clip to the scan rectangle
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(radius)),
    );

    final scanLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw the scanning line
    canvas.drawLine(
      Offset(scanRect.left, scanLineY),
      Offset(scanRect.right, scanLineY),
      scanLinePaint,
    );

    // Draw gradient effect around the scanning line
    final gradientPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromLTWH(scanRect.left, scanLineY - 20, scanRect.width, 40),
          )
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(scanRect.left, scanLineY - 20, scanRect.width, 40),
      gradientPaint,
    );

    // Restore canvas state
    canvas.restore();

    // Draw the corner borders
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    const cornerLength = 40.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.top + radius)
        ..quadraticBezierTo(
          scanRect.left,
          scanRect.top,
          scanRect.left + radius,
          scanRect.top,
        )
        ..lineTo(scanRect.left + cornerLength, scanRect.top),
      borderPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.top + radius)
        ..lineTo(scanRect.left, scanRect.top + cornerLength),
      borderPaint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - cornerLength, scanRect.top)
        ..lineTo(scanRect.right - radius, scanRect.top)
        ..quadraticBezierTo(
          scanRect.right,
          scanRect.top,
          scanRect.right,
          scanRect.top + radius,
        ),
      borderPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right, scanRect.top + radius)
        ..lineTo(scanRect.right, scanRect.top + cornerLength),
      borderPaint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.bottom - cornerLength)
        ..lineTo(scanRect.left, scanRect.bottom - radius)
        ..quadraticBezierTo(
          scanRect.left,
          scanRect.bottom,
          scanRect.left + radius,
          scanRect.bottom,
        ),
      borderPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left + radius, scanRect.bottom)
        ..lineTo(scanRect.left + cornerLength, scanRect.bottom),
      borderPaint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - cornerLength, scanRect.bottom)
        ..lineTo(scanRect.right - radius, scanRect.bottom)
        ..quadraticBezierTo(
          scanRect.right,
          scanRect.bottom,
          scanRect.right,
          scanRect.bottom - radius,
        ),
      borderPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right, scanRect.bottom - radius)
        ..lineTo(scanRect.right, scanRect.bottom - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) =>
      oldDelegate.scanSize != scanSize ||
      oldDelegate.screenSize != screenSize ||
      oldDelegate.scanProgress != scanProgress;
}

import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen QR scanner using the mobile_scanner package.
///
/// Returns the scanned [String] value via [Navigator.pop], or null if the
/// user dismisses without scanning.
///
/// Usage:
/// ```dart
/// final result = await Navigator.push<String>(
///   context,
///   MaterialPageRoute(builder: (_) => const QrScannerScreen()),
/// );
/// if (result != null) { /* handle scanned value */ }
/// ```
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _hasScanned = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause/resume camera with app lifecycle to free resources
    if (!_controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    _hasScanned = true;
    _controller.stop();

    // Return the scanned value to the caller
    Navigator.of(context).pop(value);
  }

  void _toggleTorch() async {
    await _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: AppTheme.black,
        foregroundColor: AppTheme.white,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: AppTheme.white),
        ),
        actions: [
          // Torch toggle
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on : Icons.flash_off,
              color: _torchOn ? Colors.yellow : AppTheme.white,
            ),
            tooltip: _torchOn ? 'Turn off flash' : 'Turn on flash',
            onPressed: _toggleTorch,
          ),
          // Flip camera
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_outlined,
                color: AppTheme.white),
            tooltip: 'Switch camera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Camera feed ─────────────────────────────────────────────────
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // ── Scan overlay ─────────────────────────────────────────────────
          _ScanOverlay(),

          // ── Bottom hint ───────────────────────────────────────────────────
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Align the QR code within the frame',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scan overlay widget ───────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const cutoutSize = 260.0;
    const cornerSize = 28.0;
    const cornerThickness = 4.0;
    const cornerRadius = 10.0;

    return CustomPaint(
      painter: _OverlayPainter(cutoutSize: cutoutSize),
      child: Center(
        child: SizedBox(
          width: cutoutSize,
          height: cutoutSize,
          child: Stack(
            children: [
              // Top-left corner
              Positioned(
                top: 0, left: 0,
                child: _Corner(
                  radius: cornerRadius, size: cornerSize,
                  thickness: cornerThickness, top: true, left: true),
              ),
              // Top-right corner
              Positioned(
                top: 0, right: 0,
                child: _Corner(
                  radius: cornerRadius, size: cornerSize,
                  thickness: cornerThickness, top: true, left: false),
              ),
              // Bottom-left corner
              Positioned(
                bottom: 0, left: 0,
                child: _Corner(
                  radius: cornerRadius, size: cornerSize,
                  thickness: cornerThickness, top: false, left: true),
              ),
              // Bottom-right corner
              Positioned(
                bottom: 0, right: 0,
                child: _Corner(
                  radius: cornerRadius, size: cornerSize,
                  thickness: cornerThickness, top: false, left: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dark overlay with transparent cutout ─────────────────────────────────────

class _OverlayPainter extends CustomPainter {
  final double cutoutSize;

  const _OverlayPainter({required this.cutoutSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final cutout = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: cutoutSize,
        height: cutoutSize,
      ),
      const Radius.circular(12),
    );

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(cutout)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.cutoutSize != cutoutSize;
}

// ── Corner bracket widget ─────────────────────────────────────────────────────

class _Corner extends StatelessWidget {
  final double radius;
  final double size;
  final double thickness;
  final bool top;
  final bool left;

  const _Corner({
    required this.radius,
    required this.size,
    required this.thickness,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          radius: radius,
          thickness: thickness,
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double radius;
  final double thickness;
  final bool top;
  final bool left;

  const _CornerPainter({
    required this.radius,
    required this.thickness,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.red
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    if (top && left) {
      path.moveTo(0, h);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
      path.lineTo(w, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(w - radius, 0);
      path.quadraticBezierTo(w, 0, w, radius);
      path.lineTo(w, h);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, h - radius);
      path.quadraticBezierTo(0, h, radius, h);
      path.lineTo(w, h);
    } else {
      path.moveTo(0, h);
      path.lineTo(w - radius, h);
      path.quadraticBezierTo(w, h, w, h - radius);
      path.lineTo(w, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Opened by the blood requester at the hospital.
/// They scan the QR code shown by hospital staff.
/// Calls POST /api/requests/{requestId}/pickup-scan with the scanned token.
class PickupScanScreen extends StatefulWidget {
  final String requestId;

  const PickupScanScreen({super.key, required this.requestId});

  @override
  State<PickupScanScreen> createState() => _PickupScanScreenState();
}

class _PickupScanScreenState extends State<PickupScanScreen> {
  final MobileScannerController _controller = MobileScannerController();

  bool _isProcessing = false;
  bool _isDone = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String qrToken) async {
    if (_isProcessing || _isDone) return;
    setState(() => _isProcessing = true);

    await _controller.stop();

    try {
      final id = int.tryParse(widget.requestId);
      if (id == null) throw Exception('Invalid request ID');

      final response = await const ApiClient().post(
        ApiEndpoints.pickupScan(id),
        body: {'qrToken': qrToken},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _isDone = true);
        _showResult(success: true);
      } else {
        setState(() => _isProcessing = false);
        _showError(ApiClient.errorMessage(response));
        await _controller.start();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showError('Connection error. Please try again.');
        await _controller.start();
      }
    }
  }

  void _showResult({required bool success}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: AppTheme.green, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Blood Received!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your blood pickup has been confirmed.\nThank you!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close scanner
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Done',
                  style: TextStyle(color: AppTheme.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue != null) {
                _handleScan(barcode!.rawValue!);
              }
            },
          ),

          // Overlay
          CustomPaint(
            painter: _ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),

          // Bottom instruction panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: BoxDecoration(
                color: AppTheme.black.withValues(alpha: 0.7),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner,
                      color: AppTheme.white, size: 28),
                  const SizedBox(height: 10),
                  const Text(
                    'Point your camera at the QR code\nshown by hospital staff',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (_isProcessing) ...[
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws the dark overlay with a transparent scan window in the center.
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const scanSize = 250.0;
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: scanSize,
      height: scanSize,
    );

    final paint = Paint()..color = Colors.black54;
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Dark overlay with a hole
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(fullRect),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
              scanRect, const Radius.circular(12))),
      ),
      paint,
    );

    // Corner guides
    final guidePaint = Paint()
      ..color = AppTheme.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const corner = 20.0;

    // Top-left
    canvas.drawPath(
        Path()
          ..moveTo(scanRect.left, scanRect.top + corner)
          ..lineTo(scanRect.left, scanRect.top)
          ..lineTo(scanRect.left + corner, scanRect.top),
        guidePaint);
    // Top-right
    canvas.drawPath(
        Path()
          ..moveTo(scanRect.right - corner, scanRect.top)
          ..lineTo(scanRect.right, scanRect.top)
          ..lineTo(scanRect.right, scanRect.top + corner),
        guidePaint);
    // Bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(scanRect.left, scanRect.bottom - corner)
          ..lineTo(scanRect.left, scanRect.bottom)
          ..lineTo(scanRect.left + corner, scanRect.bottom),
        guidePaint);
    // Bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(scanRect.right - corner, scanRect.bottom)
          ..lineTo(scanRect.right, scanRect.bottom)
          ..lineTo(scanRect.right, scanRect.bottom - corner),
        guidePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
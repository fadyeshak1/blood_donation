import 'dart:async';
import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/rewards/data/models/reward_qr_model.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown after the user redeems a reward.
/// The hospital name card is tappable and opens Google Maps.
class RewardQrScreen extends StatefulWidget {
  final String redemptionId;
  final String rewardTitle;
  final String status; // 'Unused' | 'Used'
  final String? hospitalName; // optional — shown if provided

  const RewardQrScreen({
    super.key,
    required this.redemptionId,
    required this.rewardTitle,
    required this.status,
    this.hospitalName,
  });

  @override
  State<RewardQrScreen> createState() => _RewardQrScreenState();
}

class _RewardQrScreenState extends State<RewardQrScreen> {
  RewardQrModel? _qr;
  bool _isLoading = true;
  bool _isExpired = false;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchQr();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchQr() async {
    _timer?.cancel();
    _timer = null;

    setState(() {
      _isLoading = true;
      _error = null;
      _isExpired = false;
      _qr = null;
    });

    try {
      final id = int.tryParse(widget.redemptionId);
      if (id == null) throw Exception('Invalid redemption ID');

      final response = await const ApiClient()
          .get(ApiEndpoints.redemptionQr(id));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = ApiClient.decode(response) as Map<String, dynamic>;
        final qr = RewardQrModel.fromJson(data);

        if (qr.isExpired) {
          setState(() {
            _isLoading = false;
            _isExpired = true;
          });
          return;
        }

        setState(() {
          _qr = qr;
          _isLoading = false;
        });

        if (qr.expiresAt != null) {
          _timer = Timer.periodic(const Duration(seconds: 1), (t) {
            if (!mounted) { t.cancel(); return; }
            if (_qr != null && _qr!.isExpired) {
              t.cancel();
              setState(() => _isExpired = true);
            } else {
              setState(() {});
            }
          });
        }
      } else {
        setState(() {
          _error = ApiClient.errorMessage(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load QR code. Please check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openInMaps(String name) async {
    final query = Uri.encodeComponent(name);
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward QR Code'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.red),
            SizedBox(height: 16),
            Text('Generating QR code...',
                style: TextStyle(color: AppTheme.grey)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.red, size: 56),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF444444), height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchQr,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_isExpired) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code,
                  color: AppTheme.grey, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('QR Code Expired',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black)),
            const SizedBox(height: 8),
            const Text('Generate a new one to proceed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Color(0xFF666666))),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _fetchQr,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New QR'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    if (_qr == null) return const SizedBox.shrink();

    final isUsed = widget.status.toLowerCase() == 'used';

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Status banner ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUsed
                  ? AppTheme.green.withValues(alpha: 0.08)
                  : AppTheme.purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUsed
                    ? AppTheme.green.withValues(alpha: 0.3)
                    : AppTheme.purple.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUsed
                      ? Icons.check_circle_outline
                      : Icons.card_giftcard_outlined,
                  color: isUsed ? AppTheme.green : AppTheme.purple,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.rewardTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isUsed
                            ? 'This reward has been used.'
                            : 'Status: Unused',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isUsed ? AppTheme.green : AppTheme.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Hospital card (if name available) — tappable → Google Maps ─
          if (widget.hospitalName != null &&
              widget.hospitalName!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _HospitalCard(
              hospitalName: widget.hospitalName!,
              onTap: () => _openInMaps(widget.hospitalName!),
            ),
          ],

          const SizedBox(height: 28),

          if (isUsed) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.green.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppTheme.green, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Reward Used',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This reward was already redeemed at the hospital.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.grey.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'Show this QR code to hospital staff',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'They will scan it to confirm you used this reward',
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 28),

            // QR code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: _qr!.qrToken,
                version: QrVersions.auto,
                size: 240,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square, color: Colors.black),
                dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black),
              ),
            ),
            const SizedBox(height: 24),

            // Timer
            if (_qr!.expiresAt != null) ...[
              Builder(builder: (_) {
                final remaining = _qr!.remaining;
                final totalSecs =
                    remaining.inSeconds.clamp(0, 999999);
                final mins = totalSecs ~/ 60;
                final secs = totalSecs % 60;
                final almost = totalSecs < 60;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: almost
                        ? AppTheme.red.withValues(alpha: 0.08)
                        : AppTheme.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: almost
                          ? AppTheme.red.withValues(alpha: 0.3)
                          : AppTheme.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 16,
                          color: almost
                              ? AppTheme.red
                              : AppTheme.green),
                      const SizedBox(width: 8),
                      Text(
                        mins > 0
                            ? 'Expires in ${mins}m ${secs}s'
                            : 'Expires in ${secs}s',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: almost
                              ? AppTheme.red
                              : AppTheme.green,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            OutlinedButton.icon(
              onPressed: _fetchQr,
              icon: const Icon(Icons.refresh, color: AppTheme.red),
              label: const Text('Refresh QR Code',
                  style: TextStyle(color: AppTheme.red)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                side: const BorderSide(color: AppTheme.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tappable hospital card — opens Google Maps on tap.
class _HospitalCard extends StatelessWidget {
  final String hospitalName;
  final VoidCallback onTap;

  const _HospitalCard({
    required this.hospitalName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.red.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppTheme.red.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_hospital_outlined,
                  color: AppTheme.red, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tap to open in Maps',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.grey)),
                    Text(
                      hospitalName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.map_outlined,
                  color: AppTheme.red.withValues(alpha: 0.6),
                  size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
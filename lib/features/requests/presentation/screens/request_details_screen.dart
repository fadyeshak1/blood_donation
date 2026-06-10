import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/core/widgets/loading_indicator.dart';
import 'package:blood_donation/features/donations/presentation/donation_qr_screen.dart';
import 'package:blood_donation/features/home/data/models/eligibility_result.dart';
import 'package:blood_donation/features/home/presentation/widgets/check_eligibility_sheet.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_provider.dart';
import 'package:blood_donation/features/requests/data/datasources/requests_remote_datasource.dart';
import 'package:blood_donation/features/requests/data/models/blood_request_model.dart';
import 'package:blood_donation/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:blood_donation/features/requests/presentation/providers/requests_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestDetailsScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailsScreen({super.key, required this.requestId});

  @override
  State<RequestDetailsScreen> createState() =>
      _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  BloodRequestModel? _request;
  bool _isLoading = true;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _loadRequestDetails();
  }

  Future<void> _loadRequestDetails() async {
    setState(() => _isLoading = true);
    final repository = RequestsRepositoryImpl(
      RequestsRemoteDataSourceImpl(const ApiClient()),
    );
    final result = await repository.getRequestById(widget.requestId);
    if (mounted) {
      switch (result) {
        case ApiSuccess(data: final data):
          setState(() {
            _request = data;
            _isLoading = false;
          });
        case ApiFailure():
          setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAcceptRequest() async {
    if (_request == null) return;

    final profileProvider = context.read<ProfileProvider>();

    // ── Pending donation gate ───────────────────────────────────────────
    // Only one active Pending donation is allowed at a time.
    if (profileProvider.state.hasPendingDonation) {
      _showPendingBlockDialog(profileProvider);
      return;
    }

    // ── Hospital confirmation dialog ────────────────────────────────────
    final confirmed = await _showHospitalConfirmDialog();
    if (!confirmed || !mounted) return;

    // ── Eligibility sheet (steps 1–4, hospital pre-selected) ───────────
    EligibilityResult? eligibilityResult;

    final isEligible = await CheckEligibilitySheet.show(
      context,
      onEligible: (result) => eligibilityResult = result,
      preselectedHospitalId: _request!.hospitalId,
      preselectedHospitalName: _request!.hospitalName,
    );

    if (isEligible == null) return;

    if (!isEligible) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not eligible to donate right now.'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
      return;
    }

    if (eligibilityResult == null) return;

    setState(() => _isAccepting = true);

    final created = await context
        .read<RequestsProvider>()
        .acceptRequest(_request!, eligibilityResult!);

    if (mounted) {
      setState(() => _isAccepting = false);

      if (created != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DonationQrScreen(
              donationId: created.id,
              hospitalName: eligibilityResult!.hospitalName,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept request. Please try again.'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  /// Shown when the user already has a Pending donation.
  void _showPendingBlockDialog(ProfileProvider profileProvider) {
    final pending = profileProvider.state.pendingDonation!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pending_outlined,
                  color: Colors.orange, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pending Donation Exists',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You already have a pending donation at '
              '${pending.hospitalName}. '
              'You can only have one active donation at a time.\n\n'
              'Please cancel your existing donation first if you no '
              'longer plan to complete it.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF444444),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await profileProvider.cancelDonation(pending.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Donation cancelled. You can now accept this request.'
                        : 'Failed to cancel donation. Please try again.'),
                    backgroundColor:
                        success ? AppTheme.green : AppTheme.red,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel Existing Donation',
                style: TextStyle(color: AppTheme.red)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows "Donate at [Hospital Name]?" and returns true if the user taps Yes.
  Future<bool> _showHospitalConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Donation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You are about to donate at:',
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF666666))),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_hospital_outlined,
                    color: AppTheme.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _request!.hospitalName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No',
                style: TextStyle(color: AppTheme.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Donate',
                style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: _isLoading
          ? const LoadingIndicator()
          : _request == null
              ? const Center(
                  child: Text('Failed to load request details'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final r = _request!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blood type header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  r.bloodType,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  r.isUrgent ? '🚨 Emergency' : 'Normal',
                  style: const TextStyle(
                      fontSize: 16, color: AppTheme.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Details card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _InfoRow(label: 'Patient', value: r.patientName),
                _InfoRow(label: 'Hospital', value: r.hospitalName),
                _InfoRow(label: 'Location', value: r.location),
                _InfoRow(
                    label: 'Units Needed',
                    value:
                        '${r.unitsNeeded} unit${r.unitsNeeded > 1 ? 's' : ''}'),
                _InfoRow(
                    label: 'Needed By',
                    value: DateFormatter.formatDate(r.neededBy)),
                _InfoRow(label: 'Status', value: r.status),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Accept Request button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAccepting ? null : _handleAcceptRequest,
              icon: _isAccepting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.white))
                  : const Icon(Icons.volunteer_activism_outlined),
              label: Text(_isAccepting
                  ? 'Processing...'
                  : 'Accept Request (Donate)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF444444))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black)),
          ),
        ],
      ),
    );
  }
}
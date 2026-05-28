import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/core/widgets/loading_indicator.dart';
import 'package:blood_donation/features/donations/presentation/donation_qr_screen.dart';
import 'package:blood_donation/features/home/data/models/eligibility_result.dart';
import 'package:blood_donation/features/home/presentation/widgets/check_eligibility_sheet.dart';
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

    EligibilityResult? eligibilityResult;

    final isEligible = await CheckEligibilitySheet.show(
      context,
      onEligible: (result) => eligibilityResult = result,
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

          // Accept Request button (donor only)
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
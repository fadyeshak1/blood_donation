import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/core/widgets/loading_indicator.dart';
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
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
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

  /// First run eligibility check — only accept if user passes.
  Future<void> _handleAcceptRequest() async {
    // Show the eligibility sheet and wait for result
    final isEligible = await CheckEligibilitySheet.show(context);

    // User dismissed without completing
    if (isEligible == null) return;

    // User failed eligibility
    if (!isEligible) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'You are not eligible to donate right now. Please check the eligibility result for details.'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
      return;
    }

    // User is eligible — proceed with accepting the request
    setState(() => _isAccepting = true);

    final success = await context
        .read<RequestsProvider>()
        .acceptRequest(widget.requestId);

    if (mounted) {
      setState(() => _isAccepting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted! Thank you for donating.'),
            backgroundColor: AppTheme.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept request')),
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
              ? const Center(child: Text('Request not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildPatientInfo(),
                      _buildHospitalInfo(),
                      _buildTimeline(),
                      _buildActionButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.red, AppTheme.red.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppTheme.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _request!.bloodType,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.red,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_request!.unitsNeeded} ${_request!.unitsNeeded == 1 ? 'Unit' : 'Units'} Needed',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _request!.isUrgent ? 'URGENT' : 'NORMAL',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    return _Section(
      title: 'Patient Information',
      children: [
        _InfoRow(
          icon: Icons.person,
          label: 'Name',
          value: _request!.patientName,
        ),
      ],
    );
  }

  Widget _buildHospitalInfo() {
    return _Section(
      title: 'Hospital Information',
      children: [
        _InfoRow(
          icon: Icons.local_hospital,
          label: 'Hospital',
          value: _request!.hospitalName,
        ),
        _InfoRow(
          icon: Icons.location_on,
          label: 'Location',
          value: _request!.location,
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return _Section(
      title: 'Timeline',
      children: [
        _InfoRow(
          icon: Icons.calendar_today,
          label: 'Requested On',
          value: DateFormatter.formatDateTime(_request!.requestDate),
        ),
        _InfoRow(
          icon: Icons.alarm,
          label: 'Needed By',
          value: DateFormatter.formatDateTime(_request!.neededBy),
          valueColor: _request!.isUrgent ? AppTheme.red : AppTheme.green,
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isAccepting ? null : _handleAcceptRequest,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isAccepting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.white,
                  ),
                )
              : const Text('Accept Request'),
        ),
      ),
    );
  }
}

// ─── Private Widgets ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
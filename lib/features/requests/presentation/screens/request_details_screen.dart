import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/core/widgets/loading_indicator.dart';
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
        case ApiSuccess(data: final requestData):
          setState(() {
            _request = requestData;
            _isLoading = false;
          });
        case ApiFailure():
          setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAcceptRequest() async {
    setState(() => _isAccepting = true);

    final success = await context
        .read<RequestsProvider>()
        .acceptRequest(widget.requestId);

    if (mounted) {
      setState(() => _isAccepting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request accepted successfully!')),
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
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
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
                      _buildUrgencyInfo(),
                      if (_request!.notes != null) _buildNotes(),
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
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    return _buildSection(
      title: 'Patient Information',
      children: [
        _buildInfoRow(Icons.person, 'Name', _request!.patientName),
        _buildInfoRow(Icons.phone, 'Contact', _request!.contactNumber),
      ],
    );
  }

  Widget _buildHospitalInfo() {
    return _buildSection(
      title: 'Hospital Information',
      children: [
        _buildInfoRow(Icons.local_hospital, 'Hospital', _request!.hospitalName),
        _buildInfoRow(Icons.location_on, 'Location', _request!.location),
      ],
    );
  }

  Widget _buildUrgencyInfo() {
    return _buildSection(
      title: 'Timeline',
      children: [
        _buildInfoRow(
          Icons.calendar_today,
          'Requested On',
          DateFormatter.formatDateTime(_request!.requestDate),
        ),
        _buildInfoRow(
          Icons.alarm,
          'Needed By',
          DateFormatter.formatDateTime(_request!.neededBy),
          valueColor: _request!.isUrgent ? AppTheme.red : AppTheme.green,
        ),
        _buildInfoRow(
          Icons.timelapse,
          'Days Remaining',
          '${_request!.daysRemaining} days',
          valueColor: _request!.daysRemaining < 2 ? AppTheme.red : AppTheme.green,
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.note, size: 20, color: AppTheme.blue),
              SizedBox(width: 8),
              Text(
                'Additional Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _request!.notes!,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.black,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
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

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
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
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.grey.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

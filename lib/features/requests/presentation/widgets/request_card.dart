import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/features/requests/data/models/blood_request_model.dart';
import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
  final BloodRequestModel request;
  final VoidCallback? onTap;

  const RequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildPatientName(),
                const SizedBox(height: 8),
                _buildHospitalInfo(),
                const SizedBox(height: 6),
                _buildLocationInfo(),
                const SizedBox(height: 6),
                _buildUnitsInfo(),
                const SizedBox(height: 12),
                Divider(color: AppTheme.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 8),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              request.bloodType,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.red,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: request.isUrgent
                ? AppTheme.red.withValues(alpha: 0.1)
                : AppTheme.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                request.isUrgent ? Icons.warning_amber : Icons.schedule,
                size: 16,
                color: request.isUrgent ? AppTheme.red : AppTheme.green,
              ),
              const SizedBox(width: 4),
              Text(
                request.isUrgent ? 'Urgent' : 'Normal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: request.isUrgent ? AppTheme.red : AppTheme.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientName() {
    return Text(
      request.patientName,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.black,
      ),
    );
  }

  Widget _buildHospitalInfo() {
    return Row(
      children: [
        const Icon(
          Icons.local_hospital,
          size: 16,
          color: AppTheme.blue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            request.hospitalName,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.black.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        const Icon(
          Icons.location_on,
          size: 16,
          color: AppTheme.purple,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            request.location,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.black.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitsInfo() {
    return Row(
      children: [
        const Icon(
          Icons.bloodtype,
          size: 16,
          color: AppTheme.red,
        ),
        const SizedBox(width: 8),
        Text(
          '${request.unitsNeeded} ${request.unitsNeeded == 1 ? 'Unit' : 'Units'} Needed',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.black.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Needed By',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormatter.formatDate(request.neededBy),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.black,
              ),
            ),
            Text(
              DateFormatter.formatTime(request.neededBy),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          child: const Text('View Details'),
        ),
      ],
    );
  }
}
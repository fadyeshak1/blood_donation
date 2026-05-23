import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
import 'package:blood_donation/features/profile/data/models/request_history_model.dart';
import 'package:blood_donation/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestHistorySection extends StatelessWidget {
  const RequestHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final requests = provider.state.requestHistory;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Request History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  if (requests.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${requests.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (requests.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No requests submitted yet',
                      style: TextStyle(color: AppTheme.grey),
                    ),
                  ),
                )
              else
                ...requests.map(
                  (r) => _RequestCard(
                    request: r,
                    onDelete: () =>
                        _confirmDelete(context, provider, r),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    ProfileProvider provider,
    RequestHistoryModel request,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Request'),
        content: Text(
          'Remove the ${request.bloodType} request for ${request.hospitalName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              // Show loading indicator while deleting
              final scaffold = ScaffoldMessenger.of(context);

              final success =
                  await provider.deleteRequest(request.id);

              if (!context.mounted) return;

              if (success) {
                scaffold.showSnackBar(
                  SnackBar(
                    content: const Text('Request deleted successfully'),
                    backgroundColor: AppTheme.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              } else {
                scaffold.showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Failed to delete request. Please try again.'),
                    backgroundColor: AppTheme.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestHistoryModel request;
  final VoidCallback onDelete;

  const _RequestCard({required this.request, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == 'pending';
    final isFulfilled = request.status == 'fulfilled';
    final statusColor = isPending
        ? Colors.orange
        : isFulfilled
            ? AppTheme.green
            : AppTheme.grey;
    final statusLabel = isPending
        ? 'Pending'
        : isFulfilled
            ? 'Fulfilled'
            : 'Cancelled';
    final statusIcon = isPending
        ? Icons.hourglass_top_outlined
        : isFulfilled
            ? Icons.check_circle_outline
            : Icons.cancel_outlined;

    final isUrgent =
        request.neededByDate.difference(DateTime.now()).inDays <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.grey.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blood type badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.bloodType,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.hospitalName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (request.hospitalLocation.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppTheme.grey),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              request.hospitalLocation,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF444444)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.red, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Delete',
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),

          Row(
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 11, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Urgency badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppTheme.red.withValues(alpha: 0.1)
                      : AppTheme.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isUrgent ? 'Emergency' : 'Normal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isUrgent ? AppTheme.red : AppTheme.green,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: AppTheme.grey),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatDate(request.neededByDate),
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF444444)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
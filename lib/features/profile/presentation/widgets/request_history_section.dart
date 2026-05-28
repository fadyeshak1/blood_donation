import 'package:blood_donation/core/theme/app_theme.dart';
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
                    onDelete: () => _confirmDelete(context, provider, r),
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
          'Delete the ${request.bloodType} request for ${request.hospitalName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final scaffold = ScaffoldMessenger.of(context);
              final success = await provider.deleteRequest(request.id);
              if (!context.mounted) return;
              scaffold.showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Request deleted successfully'
                      : 'Failed to delete request. Please try again.'),
                  backgroundColor:
                      success ? AppTheme.green : AppTheme.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red),
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.white)),
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
    final style = _statusStyle(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.grey.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row — blood type + hospital + delete
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                child: Text(
                  request.hospitalName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Delete button — always visible
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.red, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Delete request',
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quantity + Priority row
          Row(
            children: [
              _Chip(
                icon: Icons.water_drop_outlined,
                iconColor: AppTheme.red,
                label: '${request.bloodQuantity} unit${request.bloodQuantity > 1 ? 's' : ''}',
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: request.priority == 'Emergency'
                    ? Icons.warning_amber_outlined
                    : Icons.schedule_outlined,
                iconColor: request.priority == 'Emergency'
                    ? AppTheme.red
                    : AppTheme.green,
                label: request.priority,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),

          // Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(style.icon, size: 12, color: style.color),
                    const SizedBox(width: 4),
                    Text(
                      request.displayStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: style.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Status description
          if (request.statusDescription.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              request.statusDescription,
              style: TextStyle(
                fontSize: 12,
                color: style.color.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(String status) {
    switch (status) {
      case 'Open':
        return _StatusStyle(Colors.orange, Icons.hourglass_top_outlined);
      case 'Fulfilled':
        return _StatusStyle(AppTheme.blue, Icons.inventory_2_outlined);
      case 'Completed':
        return _StatusStyle(AppTheme.green, Icons.check_circle_outline);
      case 'Closed':
        return _StatusStyle(AppTheme.grey, Icons.cancel_outlined);
      default:
        return _StatusStyle(AppTheme.grey, Icons.help_outline);
    }
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _Chip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final Color color;
  final IconData icon;
  const _StatusStyle(this.color, this.icon);
}
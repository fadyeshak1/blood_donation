import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:blood_donation/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showNotification;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showNotification = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
      actions: [
        if (showNotification) _NotificationBell(),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, provider, _) {
        final hasUnread = provider.state.hasUnread;
        final count = provider.state.unreadCount;

        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: provider,
                        child: const NotificationsScreen(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_outlined),
              ),
              if (hasUnread)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    constraints: const BoxConstraints(
                        minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 1),
                    decoration: const BoxDecoration(
                      color: AppTheme.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
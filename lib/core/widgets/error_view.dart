import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final display = _friendlyMessage(message);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: display.isNetwork
                    ? AppTheme.blue.withValues(alpha: 0.08)
                    : AppTheme.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                display.isNetwork
                    ? Icons.wifi_off_rounded
                    : Icons.error_outline_rounded,
                size: 48,
                color: display.isNetwork ? AppTheme.blue : AppTheme.red,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              display.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Subtitle
            Text(
              display.subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.grey.withValues(alpha: 0.9),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Retry button
            if (onRetry != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: display.isNetwork
                        ? AppTheme.blue
                        : AppTheme.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Maps raw error strings to clean user-facing copy.
  _DisplayError _friendlyMessage(String raw) {
    final lower = raw.toLowerCase();

    // Network / connectivity errors
    if (lower.contains('socket') ||
        lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('errno') ||
        lower.contains('host') ||
        lower.contains('internet') ||
        lower.contains('handshake') ||
        lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('unreachable')) {
      return _DisplayError(
        title: 'No Internet Connection',
        subtitle:
            'Unable to connect to the network.\nPlease check your internet connection and try again.',
        isNetwork: true,
      );
    }

    // Server errors
    if (lower.contains('500') ||
        lower.contains('server') ||
        lower.contains('internal')) {
      return _DisplayError(
        title: 'Server Unavailable',
        subtitle:
            'Our servers are temporarily unavailable.\nPlease try again in a few moments.',
        isNetwork: false,
      );
    }

    // Generic fallback — still clean, no raw exception text
    return _DisplayError(
      title: 'Something Went Wrong',
      subtitle:
          'An unexpected error occurred.\nPlease try again.',
      isNetwork: false,
    );
  }
}

class _DisplayError {
  final String title;
  final String subtitle;
  final bool isNetwork;

  const _DisplayError({
    required this.title,
    required this.subtitle,
    required this.isNetwork,
  });
}
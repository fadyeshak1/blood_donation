import 'package:intl/intl.dart';

/// Date formatting utilities
class DateFormatter {
  /// Format date as "Jan 15, 2024"
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  /// Format date as "15/01/2024"
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  /// Format time as "10:30 AM"
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }
  
  /// Format date and time as "Jan 15, 2024 at 10:30 AM"
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(date);
  }
  
  /// Get relative time (e.g., "2 days ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Calculate days remaining
  static int getDaysRemaining(DateTime futureDate) {
    final now = DateTime.now();
    return futureDate.difference(now).inDays;
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}
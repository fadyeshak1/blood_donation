/// Represents a single notification from GET /api/notifications.
///
/// Expected API response shape (once backend is fixed):
/// {
///   "id": 1,
///   "title": "Blood Request Accepted",
///   "message": "A donor has accepted your blood request at Al Galaa Hospital.",
///   "type": "RequestAccepted",
///   "isRead": false,
///   "createdAt": "2026-06-07T10:00:00"
/// }
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;   // RequestAccepted | DonationConfirmed | RewardRedeemed | General
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ??
          json['body'] as String? ??
          json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'General',
      isRead: json['isRead'] as bool? ??
          json['read'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? _parseUtc(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  static DateTime _parseUtc(String raw) {
    final normalised =
        (raw.endsWith('Z') || raw.contains('+')) ? raw : '${raw}Z';
    return DateTime.tryParse(normalised)?.toUtc() ?? DateTime.now();
  }

  /// Icon and color per notification type
  String get iconKey => type;
}
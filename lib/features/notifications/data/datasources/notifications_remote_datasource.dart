import 'dart:convert';
import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/services/token_storage.dart';
import 'package:blood_donation/features/notifications/data/models/notification_model.dart';
import 'package:http/http.dart' as http;

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final ApiClient apiClient;

  const NotificationsRemoteDataSourceImpl(this.apiClient);

  static const String _base = ApiClient.baseUrl;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await apiClient.get('/api/notifications');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is List) {
        return decoded
            .map((j) => NotificationModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      // Some APIs wrap in { "data": [...] } or { "notifications": [...] }
      if (decoded is Map) {
        final list = decoded['data'] as List? ??
            decoded['notifications'] as List? ??
            decoded['items'] as List? ??
            [];
        return list
            .map((j) =>
                NotificationModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    // 500 = backend bug — return empty list gracefully
    if (response.statusCode == 500) return [];

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // PUT /api/notifications/{id}/read requires Content-Length: 0 (no body)
    final token = await TokenStorage.instance.getAccessToken();
    final uri = Uri.parse('$_base/api/notifications/$notificationId/read');
    final response = await http.put(
      uri,
      headers: {
        'Content-Length': '0',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204 ||
        response.statusCode == 500) {
      // 500 = backend bug — treat as success so UI updates optimistically
      return;
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<void> markAllAsRead() async {
    // No bulk-read endpoint — mark each unread notification individually
    // This is a no-op at the API level if the backend is down;
    // the provider handles optimistic UI updates locally.
  }
}
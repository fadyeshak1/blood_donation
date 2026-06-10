import 'package:blood_donation/core/network/api_result.dart';
import 'package:blood_donation/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:blood_donation/features/notifications/data/models/notification_model.dart';

abstract class NotificationsRepository {
  Future<ApiResult<List<NotificationModel>>> getNotifications();
  Future<ApiResult<void>> markAsRead(String notificationId);
  Future<ApiResult<void>> markAllAsRead();
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  const NotificationsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<NotificationModel>>> getNotifications() async {
    try {
      final notifications = await remoteDataSource.getNotifications();
      return ApiSuccess(notifications);
    } catch (e) {
      return ApiFailure(
          'Failed to load notifications: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  @override
  Future<ApiResult<void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const ApiSuccess(null);
    } catch (e) {
      return ApiFailure(
          'Failed to mark as read: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  @override
  Future<ApiResult<void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const ApiSuccess(null);
    } catch (e) {
      return ApiFailure('Failed to mark all as read');
    }
  }
}
import 'dart:io';
import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/services/location_storage.dart';
import 'package:blood_donation/features/home/data/models/dashboard_stats_model.dart';
import 'package:blood_donation/features/home/data/models/urgent_request_model.dart';

abstract class HomeRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats(String userId);
  Future<List<UrgentRequestModel>> getUrgentRequests(String userId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  const HomeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DashboardStatsModel> getDashboardStats(String userId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.dashboard);
      if (response.statusCode == 200) {
        final data = ApiClient.decode(response) as Map<String, dynamic>;
        return DashboardStatsModel.fromJson(data);
      }
      throw Exception(ApiClient.errorMessage(response));
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HandshakeException {
      throw Exception('Connection error. Please try again.');
    }
  }

  @override
  Future<List<UrgentRequestModel>> getUrgentRequests(String userId) async {
    try {
      // Fetch ALL requests (no priority filter) so we can apply
      // the client-side priority fallback sorting
      final response = await apiClient.get(ApiEndpoints.matchRequests);

      if (response.statusCode == 200) {
        final all = _parseResults(ApiClient.decode(response));
        return _pickTop2(all);
      }

      // 400 = "location not set on account" — try locally stored coordinates
      if (response.statusCode == 400) {
        return await _getWithLocalLocation();
      }

      return [];
    } on SocketException {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fallback when the server has no location for this user.
  /// Re-tries with locally stored coordinates if available.
  Future<List<UrgentRequestModel>> _getWithLocalLocation() async {
    try {
      final stored = await LocationStorage.instance.getLocation();
      if (stored == null) return []; // no location saved → show empty CTA

      final url = '${ApiEndpoints.matchRequests}'
          '?latitude=${stored.lat}'
          '&longitude=${stored.lng}';

      final response = await apiClient.get(url);
      if (response.statusCode == 200) {
        final all = _parseResults(ApiClient.decode(response));
        return _pickTop2(all);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ── Priority sorting ────────────────────────────────────────────────────
  //
  // Pick up to 2 requests using this priority order:
  //   1. Urgent  + Near
  //   2. Urgent  + Far
  //   3. Normal  + Near
  //   4. Normal  + Far
  //
  // The API doesn't support distance filtering server-side, so we sort
  // the full result set client-side.

  List<UrgentRequestModel> _pickTop2(List<UrgentRequestModel> all) {
    if (all.isEmpty) return [];

    final result = <UrgentRequestModel>[];

    // Buckets in priority order
    final buckets = [
      _bucket(all, urgent: true,  near: true),  // 1. Urgent + Near
      _bucket(all, urgent: true,  near: false), // 2. Urgent + Far
      _bucket(all, urgent: false, near: true),  // 3. Normal + Near
      _bucket(all, urgent: false, near: false), // 4. Normal + Far
    ];

    for (final bucket in buckets) {
      for (final req in bucket) {
        if (result.length >= 2) break;
        if (!result.any((r) => r.id == req.id)) {
          result.add(req);
        }
      }
      if (result.length >= 2) break;
    }

    return result;
  }

  /// Filters requests matching a specific urgent + near combination.
  List<UrgentRequestModel> _bucket(
    List<UrgentRequestModel> all, {
    required bool urgent,
    required bool near,
  }) {
    return all.where((r) {
      final isUrgent = r.urgency.toLowerCase() == 'urgent' ||
          r.urgency.toLowerCase() == 'emergency';
      final isNear = _isNear(r.distance);
      return isUrgent == urgent && isNear == near;
    }).toList();
  }

  /// Returns true if the distance string indicates "near".
  /// Known API values: "Near you", "Near", "Far", "Very far"
  bool _isNear(String? distance) {
    if (distance == null || distance.isEmpty) return false;
    return distance.toLowerCase().contains('near');
  }

  // ── Response parsing ─────────────────────────────────────────────────────

  List<UrgentRequestModel> _parseResults(dynamic decoded) {
    List<dynamic> list = const [];

    if (decoded is Map) {
      if (decoded.containsKey('results')) {
        list = decoded['results'] as List? ?? [];
      } else if (decoded.containsKey('data')) {
        list = decoded['data'] as List? ?? [];
      }
    } else if (decoded is List) {
      list = decoded;
    }

    if (list.isEmpty) return [];

    return list
        .map((json) => UrgentRequestModel.fromApiJson(
            json as Map<String, dynamic>))
        .toList();
  }
}
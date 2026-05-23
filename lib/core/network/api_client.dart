import 'dart:convert';
import 'package:blood_donation/core/services/token_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://blooddonationsys.runasp.net';
  static const String _refreshEndpoint = '/api/auth/refresh-token';

  const ApiClient();

  // ── Headers ───────────────────────────────────────────────────────────────

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.instance.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
      };

  // ── Token refresh ─────────────────────────────────────────────────────────

  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns true if successful, false if the refresh token is also expired.
  /// Called automatically on every 401, and explicitly from SplashScreen.
  Future<bool> tryRefreshToken() async {
    final refreshToken = await TokenStorage.instance.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final uri = Uri.parse('$baseUrl$_refreshEndpoint');
      final response = await http.post(
        uri,
        headers: _publicHeaders,
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await TokenStorage.instance.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          return true;
        }
      }
    } catch (_) {}

    return false;
  }

  // ── Core HTTP methods ─────────────────────────────────────────────────────
  //
  // Every authenticated method uses _executeWithRefresh which:
  //   1. Runs the request with the current access token
  //   2. If 401 → calls tryRefreshToken()
  //   3. If refresh succeeds → retries the request once with the new token
  //   4. If refresh fails → returns the 401 response as-is

  Future<http.Response> _executeWithRefresh(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    final headers = await _authHeaders();
    final response = await request(headers);

    if (response.statusCode == 401) {
      final refreshed = await tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _authHeaders();
        return request(newHeaders);
      }
    }

    return response;
  }

  Future<http.Response> get(String path) {
    return _executeWithRefresh((headers) async {
      final uri = Uri.parse('$baseUrl$path');
      return http.get(uri, headers: headers);
    });
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    if (!requiresAuth) {
      final uri = Uri.parse('$baseUrl$path');
      return http.post(
        uri,
        headers: _publicHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
    }

    return _executeWithRefresh((headers) async {
      final uri = Uri.parse('$baseUrl$path');
      return http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _executeWithRefresh((headers) async {
      final uri = Uri.parse('$baseUrl$path');
      return http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<http.Response> delete(String path) {
    return _executeWithRefresh((headers) async {
      final uri = Uri.parse('$baseUrl$path');
      return http.delete(uri, headers: headers);
    });
  }

  // ── Response helpers ──────────────────────────────────────────────────────

  static dynamic decode(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static String errorMessage(http.Response response) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map) {
        if (body.containsKey('message') && body['message'] != null) {
          return body['message'] as String;
        }
        if (body.containsKey('errors')) {
          final errors = body['errors'] as Map;
          final messages = <String>[];
          errors.forEach((key, value) {
            if (value is List) messages.addAll(value.cast<String>());
          });
          if (messages.isNotEmpty) return messages.first;
        }
        if (body.containsKey('title')) return body['title'] as String;
      }
    } catch (_) {}
    return 'An unexpected error occurred (${response.statusCode})';
  }
}
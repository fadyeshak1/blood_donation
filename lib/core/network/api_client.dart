class ApiClient {
  static const String baseUrl = 'https://api.blooddonation.com/v1';
  
  // TODO: When ready for real API integration:
  // 1. Add http or dio package to pubspec.yaml
  // 2. Implement actual HTTP methods
  // 3. Add authentication token management
  
  const ApiClient();
  
  /// Get common headers for all requests
  Future<Map<String, String>> getHeaders() async {
    // TODO: Get token from secure storage
    // final token = await _secureStorage.read(key: 'auth_token');
    
    return {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer $token',
    };
  }
  
  // Example future implementation:
  /*
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load data');
  }
  */
}
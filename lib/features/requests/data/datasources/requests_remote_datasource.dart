import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/features/requests/data/models/blood_request_model.dart';
import 'package:blood_donation/features/requests/data/models/create_request_model.dart';

abstract class RequestsRemoteDataSource {
  Future<List<BloodRequestModel>> getRequests({
    String? bloodType,
    String? urgency,
    String? search,
  });
  Future<BloodRequestModel> getRequestById(String requestId);
  Future<void> acceptRequest(String requestId);
  Future<void> createRequest(CreateRequestModel request);
}

class RequestsRemoteDataSourceImpl implements RequestsRemoteDataSource {
  final ApiClient apiClient;

  const RequestsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<BloodRequestModel>> getRequests({
    String? bloodType,
    String? urgency,
    String? search,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: Replace with actual API call
    /*
    final queryParams = <String, String>{};
    if (bloodType != null && bloodType != 'All') {
      queryParams['bloodType'] = bloodType;
    }
    if (urgency != null && urgency != 'All') {
      queryParams['urgency'] = urgency.toLowerCase();
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse('${ApiClient.baseUrl}/blood-requests')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: await apiClient.getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BloodRequestModel.fromJson(json)).toList();
    }

    throw Exception('Failed to load requests');
    */

    // Apply filters to sample data
    var requests = BloodRequestModel.getSampleRequests();

    if (bloodType != null && bloodType != 'All') {
      requests = requests.where((r) => r.bloodType == bloodType).toList();
    }

    if (urgency != null && urgency != 'All') {
      requests = requests
          .where((r) =>
              r.urgency.toLowerCase() == urgency.toLowerCase())
          .toList();
    }

    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      requests = requests.where((r) {
        return r.patientName.toLowerCase().contains(query) ||
            r.hospitalName.toLowerCase().contains(query) ||
            r.location.toLowerCase().contains(query);
      }).toList();
    }

    return requests;
  }

  @override
  Future<BloodRequestModel> getRequestById(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Replace with actual API call
    /*
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/blood-requests/$requestId'),
      headers: await apiClient.getHeaders(),
    );

    if (response.statusCode == 200) {
      return BloodRequestModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load request details');
    */

    final request = BloodRequestModel.getSampleRequests()
        .firstWhere((r) => r.id == requestId);
    return request;
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: Replace with actual API call
    /*
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/blood-requests/$requestId/accept'),
      headers: await apiClient.getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept request');
    }
    */
  }
  @override
Future<void> createRequest(CreateRequestModel request) async {
  await Future.delayed(const Duration(milliseconds: 1000));
  
  // TODO: Replace with actual API call
  /*
  final response = await http.post(
    Uri.parse('${ApiClient.baseUrl}/blood-requests'),
    headers: await apiClient.getHeaders(),
    body: jsonEncode(request.toJson()),
  );
  
  if (response.statusCode != 201) {
    throw Exception('Failed to create request');
  }
  */
}
}

import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/network/api_enums.dart';
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
  Future<void> deleteRequest(String requestId);
  Future<List<HospitalDropdownItem>> getHospitals();
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
    final params = <String>[];

    if (bloodType != null && bloodType != 'All') {
      params.add('BloodType=${BloodTypeEnum.toInt(bloodType)}');
    }
    if (urgency != null && urgency != 'All') {
      final priorityStr =
          urgency.toLowerCase() == 'urgent' ? 'Emergency' : 'Normal';
      params.add('Priority=$priorityStr');
    }
    if (search != null && search.isNotEmpty) {
      params.add('Search=${Uri.encodeQueryComponent(search)}');
    }

    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    final response =
        await apiClient.get('${ApiEndpoints.matchRequests}$query');

    if (response.statusCode == 200) {
      final decoded = ApiClient.decode(response);

      if (decoded is Map && decoded.containsKey('results')) {
        final list = decoded['results'] as List? ?? [];
        if (list.isEmpty) return BloodRequestModel.getSampleRequests();
        return list
            .map((json) => BloodRequestModel.fromApiJson(
                json as Map<String, dynamic>))
            .toList();
      }

      if (decoded is Map) {
        return BloodRequestModel.getSampleRequests();
      }

      if (decoded is List) {
        if (decoded.isEmpty) return BloodRequestModel.getSampleRequests();
        return decoded
            .map((json) => BloodRequestModel.fromApiJson(
                json as Map<String, dynamic>))
            .toList();
      }

      return BloodRequestModel.getSampleRequests();
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<BloodRequestModel> getRequestById(String requestId) async {
    final id = int.tryParse(requestId);
    if (id == null) throw Exception('Invalid request ID');

    final response = await apiClient.get(ApiEndpoints.requestById(id));

    if (response.statusCode == 200) {
      final data = ApiClient.decode(response) as Map<String, dynamic>;
      return BloodRequestModel.fromApiJson(data);
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    // No-op — acceptance = creating a donation, handled elsewhere
  }

  @override
  Future<void> createRequest(CreateRequestModel request) async {
    final response = await apiClient.post(
      ApiEndpoints.createRequest,
      body: request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    final id = int.tryParse(requestId);
    if (id == null) throw Exception('Invalid request ID');

    final response =
        await apiClient.delete(ApiEndpoints.deleteRequest(id));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<List<HospitalDropdownItem>> getHospitals() async {
    final response = await apiClient.get(ApiEndpoints.hospitalsDropdown);

    if (response.statusCode == 200) {
      final decoded = ApiClient.decode(response);
      if (decoded is List) {
        return decoded
            .map((json) => HospitalDropdownItem.fromJson(
                json as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }
}

class HospitalDropdownItem {
  final int id;
  final String name;

  const HospitalDropdownItem({required this.id, required this.name});

  factory HospitalDropdownItem.fromJson(Map<String, dynamic> json) {
    return HospitalDropdownItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ??
          json['hospitalName'] as String? ??
          '',
    );
  }
}
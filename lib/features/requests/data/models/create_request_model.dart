class CreateRequestModel {
  final String bloodType;
  final String chronicDiseases;
  final String urgency;
  final String hospitalName;
  final String hospitalLocation;
  final int bloodQuantity;

  const CreateRequestModel({
    required this.bloodType,
    required this.chronicDiseases,
    required this.urgency,
    required this.hospitalName,
    required this.hospitalLocation,
    required this.bloodQuantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'bloodType': bloodType,
      'chronicDiseases': chronicDiseases,
      'urgency': urgency,
      'hospitalName': hospitalName,
      'hospitalLocation': hospitalLocation,
      'bloodQuantity': bloodQuantity,
    };
  }
}

// ============================================================================
// DATA LAYER - DATASOURCE (Add method to existing file)
// ============================================================================

// UPDATE FILE 42: Add this method to RequestsRemoteDataSource abstract class:
/*
abstract class RequestsRemoteDataSource {
  Future<List<BloodRequestModel>> getRequests({...});
  Future<BloodRequestModel> getRequestById(String requestId);
  Future<void> acceptRequest(String requestId);
  Future<void> createRequest(CreateRequestModel request); // ADD THIS
}
*/

// UPDATE FILE 42: Add this method to RequestsRemoteDataSourceImpl class:
/*
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
*/

// ============================================================================
// DATA LAYER - REPOSITORY (Add method to existing file)
// ============================================================================

// UPDATE FILE 43: Add this method to RequestsRepository abstract class:
/*
abstract class RequestsRepository {
  Future<ApiResult<List<BloodRequestModel>>> getRequests({...});
  Future<ApiResult<BloodRequestModel>> getRequestById(String requestId);
  Future<ApiResult<void>> acceptRequest(String requestId);
  Future<ApiResult<void>> createRequest(CreateRequestModel request); // ADD THIS
}
*/

// UPDATE FILE 43: Add this method to RequestsRepositoryImpl class:
/*
@override
Future<ApiResult<void>> createRequest(CreateRequestModel request) async {
  try {
    await remoteDataSource.createRequest(request);
    return const ApiSuccess(null);
  } catch (e) {
    return ApiFailure('Failed to create request: ${e.toString()}');
  }
}
*/

// ============================================================================
// BUSINESS LOGIC - PROVIDER (Add method to existing file)
// ============================================================================

// UPDATE FILE 45: Add this method to RequestsProvider class:
/*
Future<bool> createRequest(CreateRequestModel request) async {
  final result = await repository.createRequest(request);
  
  if (result is ApiSuccess) {
    // Refresh the list after creating
    await loadRequests();
    return true;
  }
  return false;
}
*/
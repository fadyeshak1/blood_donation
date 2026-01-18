import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:blood_donation/features/profile/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel> updateUserProfile(UserModel user);
  Future<List<DonationHistoryModel>> getDonationHistory(String userId);
  Future<void> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;
  
  const ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> getUserProfile(String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // TODO: Replace with actual API call
    /*
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/users/$userId'),
      headers: await apiClient.getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }
    
    throw Exception('Failed to load user profile');
    */
    
    // Return sample data for now
    return UserModel.getSampleUser();
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // TODO: Replace with actual API call
    /*
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/users/${user.id}'),
      headers: await apiClient.getHeaders(),
      body: jsonEncode(user.toJson()),
    );
    
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }
    
    throw Exception('Failed to update profile');
    */
    
    return user;
  }

  @override
  Future<List<DonationHistoryModel>> getDonationHistory(String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // TODO: Replace with actual API call
    /*
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/users/$userId/donations'),
      headers: await apiClient.getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DonationHistoryModel.fromJson(json)).toList();
    }
    
    throw Exception('Failed to load donation history');
    */
    
    return DonationHistoryModel.getSampleHistory();
  }

  @override
  Future<void> logout() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // TODO: Replace with actual API call
    /*
    await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/logout'),
      headers: await apiClient.getHeaders(),
    );
    
    // Clear local storage
    await secureStorage.deleteAll();
    */
  }
}
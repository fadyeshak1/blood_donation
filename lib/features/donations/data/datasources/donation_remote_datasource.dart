import 'dart:convert';
import 'package:blood_donation/core/network/api_client.dart';
import 'package:blood_donation/core/network/api_endpoints.dart';
import 'package:blood_donation/core/services/token_storage.dart';
import 'package:blood_donation/features/donations/data/models/create_donation_model.dart';
import 'package:blood_donation/features/profile/data/models/donation_history_model.dart';
import 'package:http/http.dart' as http;

abstract class DonationRemoteDataSource {
  Future<DonationHistoryModel> createDonation(CreateDonationModel donation);
  Future<List<DonationHistoryModel>> getMyDonations();
  Future<void> cancelDonation(String donationId);
}

class DonationRemoteDataSourceImpl implements DonationRemoteDataSource {
  final ApiClient apiClient;

  const DonationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DonationHistoryModel> createDonation(
      CreateDonationModel donation) async {
    final response = await apiClient.post(
      ApiEndpoints.createDonation,
      body: donation.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = ApiClient.decode(response) as Map<String, dynamic>;
      return _fromCreateResponse(data);
    }

    throw Exception(ApiClient.errorMessage(response));
  }

  @override
  Future<List<DonationHistoryModel>> getMyDonations() async {
    final response = await apiClient.get(ApiEndpoints.myDonations);

    if (response.statusCode == 200) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list
          .map((json) =>
              DonationHistoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<void> cancelDonation(String donationId) async {
    final id = int.tryParse(donationId);
    if (id == null) throw Exception('Invalid donation ID');

    // POST /api/donations/{id}/cancel requires Content-Length: 0 (no body).
    // Sending a body changes Content-Type and causes a 400 error from the API.
    final token = await TokenStorage.instance.getAccessToken();
    final uri = Uri.parse(
        '${ApiClient.baseUrl}${ApiEndpoints.cancelDonation(id)}');
    final response = await http.post(
      uri,
      headers: {
        'Content-Length': '0',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(ApiClient.errorMessage(response));
  }

  static DonationHistoryModel _fromCreateResponse(
      Map<String, dynamic> json) {
    return DonationHistoryModel(
      id: json['id'].toString(),
      date: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      hospitalName: json['hospitalName'] as String? ?? '',
      location: '',
      unitsQuantity: 1,
      pointsEarned: 0,
      certificateUrl: '',
      status: 'pending',
    );
  }
}
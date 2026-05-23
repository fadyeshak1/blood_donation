import 'package:blood_donation/core/network/api_enums.dart';

class DonationHistoryModel {
  final String id;
  final DateTime date;
  final String hospitalName;
  final String location;
  final int unitsQuantity;
  final int pointsEarned;
  final String certificateUrl;
  final String status; // 'pending' | 'confirmed' | 'cancelled' | 'rejected' | 'withdrawn'

  const DonationHistoryModel({
    required this.id,
    required this.date,
    required this.hospitalName,
    required this.location,
    required this.unitsQuantity,
    required this.pointsEarned,
    required this.certificateUrl,
    this.status = 'pending',
  });

  DonationHistoryModel copyWith({String? status}) {
    return DonationHistoryModel(
      id: id,
      date: date,
      hospitalName: hospitalName,
      location: location,
      unitsQuantity: unitsQuantity,
      pointsEarned: pointsEarned,
      certificateUrl: certificateUrl,
      status: status ?? this.status,
    );
  }

  factory DonationHistoryModel.fromJson(Map<String, dynamic> json) {
    return DonationHistoryModel(
      id: json['id']?.toString() ?? '',
      date: json['donationDate'] != null
          ? DateTime.tryParse(json['donationDate'] as String) ?? DateTime.now()
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
              : DateTime.now(),
      hospitalName: json['hospitalName'] as String? ?? 'Unknown Hospital',
      location: json['hospitalLocation'] as String? ??
          json['location'] as String? ??
          '',
      unitsQuantity:
          (json['quantity'] as num?)?.toInt() ??
          (json['unitsQuantity'] as num?)?.toInt() ??
          1,
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      certificateUrl: json['certificateUrl'] as String? ?? '',
      status: _parseStatus(json['status']),
    );
  }

  static String _parseStatus(dynamic raw) {
    if (raw == null) return 'pending';
    final s = raw.toString().toLowerCase();
    if (s == 'confirmed') return 'confirmed';
    if (s == 'cancelled') return 'cancelled';
    if (s == 'rejected') return 'rejected';
    if (s == 'withdrawn') return 'withdrawn';
    return 'pending';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donationDate': date.toIso8601String(),
      'hospitalName': hospitalName,
      'location': location,
      'unitsQuantity': unitsQuantity,
      'pointsEarned': pointsEarned,
      'certificateUrl': certificateUrl,
      'status': status,
    };
  }

  static List<DonationHistoryModel> getSampleHistory() {
    return [
      DonationHistoryModel(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 45)),
        hospitalName: 'Cairo University Hospital',
        location: 'Giza, Cairo',
        unitsQuantity: 1,
        pointsEarned: 100,
        certificateUrl: '',
        status: 'confirmed',
      ),
    ];
  }
}
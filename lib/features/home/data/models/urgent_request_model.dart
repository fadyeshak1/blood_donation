import 'package:blood_donation/core/network/api_enums.dart';

class UrgentRequestModel {
  final String id;
  final String bloodType;
  final String hospitalName;
  final String location;
  final String urgency;   // 'urgent' | 'normal'
  final int unitsNeeded;
  final String? distance; // 'Near you' | 'Far' | 'Very far' — from API

  const UrgentRequestModel({
    required this.id,
    required this.bloodType,
    required this.hospitalName,
    required this.location,
    required this.urgency,
    required this.unitsNeeded,
    this.distance,
  });

  bool get isUrgent => urgency.toLowerCase() == 'urgent' ||
      urgency.toLowerCase() == 'emergency';

  /// Parses from GET /api/ai/match-requests response shape:
  /// { requestId, requesterName, hospitalName, hospitalAddress,
  ///   bloodType, quantity, priority, neededBy, status, distance }
  factory UrgentRequestModel.fromApiJson(Map<String, dynamic> json) {
    final bloodTypeRaw = json['bloodType'];
    final bloodTypeStr = bloodTypeRaw is int
        ? BloodTypeEnum.fromInt(bloodTypeRaw)
        : (bloodTypeRaw?.toString() ?? '');

    final priority =
        (json['priority'] as String? ?? '').toLowerCase();
    final urgency = (priority.contains('emergency') ||
            priority.contains('urgent'))
        ? 'urgent'
        : 'normal';

    return UrgentRequestModel(
      id: json['requestId']?.toString() ??
          json['id']?.toString() ?? '',
      bloodType: bloodTypeStr,
      hospitalName: json['hospitalName'] as String? ??
          json['hospital'] as String? ?? '',
      location: json['hospitalAddress'] as String? ??
          json['hospitalLocation'] as String? ??
          json['location'] as String? ?? '',
      urgency: urgency,
      unitsNeeded: (json['quantity'] as num?)?.toInt() ??
          (json['unitsNeeded'] as num?)?.toInt() ?? 1,
      distance: json['distance'] as String?,
    );
  }

  factory UrgentRequestModel.fromJson(Map<String, dynamic> json) =>
      UrgentRequestModel.fromApiJson(json);

  Map<String, dynamic> toJson() => {
        'id': id,
        'bloodType': bloodType,
        'hospitalName': hospitalName,
        'location': location,
        'urgency': urgency,
        'unitsNeeded': unitsNeeded,
        if (distance != null) 'distance': distance,
      };

  static List<UrgentRequestModel> getSampleRequests() => [];
}
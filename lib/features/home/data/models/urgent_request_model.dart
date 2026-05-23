import 'package:blood_donation/core/network/api_enums.dart';

class UrgentRequestModel {
  final String id;
  final String bloodType;
  final String hospitalName;
  final String location;
  final String urgency;
  final int unitsNeeded;

  const UrgentRequestModel({
    required this.id,
    required this.bloodType,
    required this.hospitalName,
    required this.location,
    required this.urgency,
    required this.unitsNeeded,
  });

  factory UrgentRequestModel.fromJson(Map<String, dynamic> json) {
    return UrgentRequestModel(
      id: json['id']?.toString() ?? '',
      bloodType: json['bloodType'] as String? ?? '',
      hospitalName: json['hospitalName'] as String? ?? '',
      location: json['location'] as String? ?? '',
      urgency: json['urgency'] as String? ?? 'normal',
      unitsNeeded: (json['unitsNeeded'] as num?)?.toInt() ?? 1,
    );
  }

  /// Parses from GET /api/ai/match-requests response
  factory UrgentRequestModel.fromApiJson(Map<String, dynamic> json) {
    final bloodTypeRaw = json['bloodType'];
    final bloodTypeStr = bloodTypeRaw is int
        ? BloodTypeEnum.fromInt(bloodTypeRaw)
        : bloodTypeRaw?.toString() ?? '';

    final priority = (json['priority'] as num?)?.toInt() ?? 1;
    final urgency = priority >= 2 ? 'urgent' : 'normal';

    return UrgentRequestModel(
      id: json['id']?.toString() ?? '',
      bloodType: bloodTypeStr,
      hospitalName: json['hospitalName'] as String? ??
          json['hospital'] as String? ??
          '',
      location: json['hospitalLocation'] as String? ??
          json['location'] as String? ??
          '',
      urgency: urgency,
      unitsNeeded: (json['quantity'] as num?)?.toInt() ??
          (json['unitsNeeded'] as num?)?.toInt() ??
          1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bloodType': bloodType,
      'hospitalName': hospitalName,
      'location': location,
      'urgency': urgency,
      'unitsNeeded': unitsNeeded,
    };
  }

  bool get isUrgent => urgency.toLowerCase() == 'urgent';

  static List<UrgentRequestModel> getSampleRequests() {
    return [
      const UrgentRequestModel(
        id: '1',
        bloodType: 'A+',
        hospitalName: 'Cairo University Hospital',
        location: 'Giza, Cairo',
        urgency: 'urgent',
        unitsNeeded: 2,
      ),
      const UrgentRequestModel(
        id: '2',
        bloodType: 'O-',
        hospitalName: 'Ain Shams Hospital',
        location: 'Nasr City, Cairo',
        urgency: 'urgent',
        unitsNeeded: 3,
      ),
    ];
  }
}
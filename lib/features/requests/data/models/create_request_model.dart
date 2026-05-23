import 'package:blood_donation/core/network/api_enums.dart';

class CreateRequestModel {
  final String bloodType;
  final String hospitalName;
  final String hospitalLocation;
  final int bloodQuantity;
  final DateTime neededByDate;
  final int hospitalId;
  final double latitude;
  final double longitude;

  String get urgency {
    final daysRemaining =
        neededByDate.difference(DateTime.now()).inDays;
    return daysRemaining <= 3 ? 'Emergency' : 'Normal';
  }

  const CreateRequestModel({
    required this.bloodType,
    required this.hospitalName,
    required this.hospitalLocation,
    required this.bloodQuantity,
    required this.neededByDate,
    this.hospitalId = 0,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'bloodType': BloodTypeEnum.toInt(bloodType),
      'quantity': bloodQuantity,
      'hospitalLocation': hospitalLocation,
      'latitude': latitude,
      'longitude': longitude,
      // Send date only (yyyy-MM-dd) — API rejects full ISO string
      'neededBy':
          '${neededByDate.year.toString().padLeft(4, '0')}-'
          '${neededByDate.month.toString().padLeft(2, '0')}-'
          '${neededByDate.day.toString().padLeft(2, '0')}',
    };

    // Only include hospitalId when it's a valid value (> 0)
    // When the hospital dropdown is empty, hospitalId stays 0
    // and we omit it so the API doesn't reject it
    if (hospitalId > 0) {
      map['hospitalId'] = hospitalId;
    }

    return map;
  }
}
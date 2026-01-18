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
      id: json['id'] as String,
      bloodType: json['bloodType'] as String,
      hospitalName: json['hospitalName'] as String,
      location: json['location'] as String,
      urgency: json['urgency'] as String,
      unitsNeeded: (json['unitsNeeded'] as num).toInt(),
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
      UrgentRequestModel(
        id: '1',
        bloodType: 'A+',
        hospitalName: 'Cairo University Hospital',
        location: 'Giza, Cairo',
        urgency: 'urgent',
        unitsNeeded: 2,
      ),
      UrgentRequestModel(
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

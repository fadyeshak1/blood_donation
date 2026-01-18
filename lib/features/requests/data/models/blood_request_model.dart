class BloodRequestModel {
  final String id;
  final String patientName;
  final String bloodType;
  final int unitsNeeded;
  final String hospitalName;
  final String location;
  final String contactNumber;
  final DateTime requestDate;
  final DateTime neededBy;
  final String urgency;
  final String? notes;
  final String status;

  const BloodRequestModel({
    required this.id,
    required this.patientName,
    required this.bloodType,
    required this.unitsNeeded,
    required this.hospitalName,
    required this.location,
    required this.contactNumber,
    required this.requestDate,
    required this.neededBy,
    required this.urgency,
    this.notes,
    this.status = 'pending',
  });

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) {
    return BloodRequestModel(
      id: json['id'] as String,
      patientName: json['patientName'] as String,
      bloodType: json['bloodType'] as String,
      unitsNeeded: (json['unitsNeeded'] as num).toInt(),
      hospitalName: json['hospitalName'] as String,
      location: json['location'] as String,
      contactNumber: json['contactNumber'] as String,
      requestDate: DateTime.parse(json['requestDate'] as String),
      neededBy: DateTime.parse(json['neededBy'] as String),
      urgency: json['urgency'] as String,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'bloodType': bloodType,
      'unitsNeeded': unitsNeeded,
      'hospitalName': hospitalName,
      'location': location,
      'contactNumber': contactNumber,
      'requestDate': requestDate.toIso8601String(),
      'neededBy': neededBy.toIso8601String(),
      'urgency': urgency,
      if (notes != null) 'notes': notes,
      'status': status,
    };
  }

  bool get isUrgent => urgency.toLowerCase() == 'urgent';

  int get daysRemaining {
    final now = DateTime.now();
    return neededBy.difference(now).inDays;
  }

  static List<BloodRequestModel> getSampleRequests() {
    return [
      BloodRequestModel(
        id: '1',
        patientName: 'Ahmed Hassan',
        bloodType: 'A+',
        unitsNeeded: 2,
        hospitalName: 'Cairo University Hospital',
        location: 'Giza, Cairo',
        contactNumber: '01012345678',
        requestDate: DateTime.now().subtract(const Duration(hours: 2)),
        neededBy: DateTime.now().add(const Duration(days: 1)),
        urgency: 'urgent',
        notes: 'Patient scheduled for surgery tomorrow',
      ),
      BloodRequestModel(
        id: '2',
        patientName: 'Fatma Mohamed',
        bloodType: 'O-',
        unitsNeeded: 3,
        hospitalName: 'Ain Shams University Hospital',
        location: 'Nasr City, Cairo',
        contactNumber: '01123456789',
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        neededBy: DateTime.now().add(const Duration(days: 3)),
        urgency: 'normal',
        notes: 'Anemia treatment',
      ),
      BloodRequestModel(
        id: '3',
        patientName: 'Mohamed Ali',
        bloodType: 'B+',
        unitsNeeded: 1,
        hospitalName: 'Kasr Al Ainy Hospital',
        location: 'Downtown, Cairo',
        contactNumber: '01234567890',
        requestDate: DateTime.now().subtract(const Duration(hours: 5)),
        neededBy: DateTime.now().add(const Duration(hours: 12)),
        urgency: 'urgent',
        notes: 'Emergency case - accident victim',
      ),
      BloodRequestModel(
        id: '4',
        patientName: 'Sara Ibrahim',
        bloodType: 'AB+',
        unitsNeeded: 2,
        hospitalName: 'Al Salam Hospital',
        location: 'Maadi, Cairo',
        contactNumber: '01098765432',
        requestDate: DateTime.now().subtract(const Duration(days: 2)),
        neededBy: DateTime.now().add(const Duration(days: 5)),
        urgency: 'normal',
      ),
      BloodRequestModel(
        id: '5',
        patientName: 'Omar Khaled',
        bloodType: 'O+',
        unitsNeeded: 4,
        hospitalName: 'Nasser Institute Hospital',
        location: 'Shoubra, Cairo',
        contactNumber: '01156789012',
        requestDate: DateTime.now().subtract(const Duration(hours: 8)),
        neededBy: DateTime.now().add(const Duration(days: 2)),
        urgency: 'urgent',
        notes: 'Cancer patient needs blood transfusion',
      ),
      BloodRequestModel(
        id: '6',
        patientName: 'Layla Ahmed',
        bloodType: 'A-',
        unitsNeeded: 1,
        hospitalName: 'Dar Al Fouad Hospital',
        location: '6th October City',
        contactNumber: '01287654321',
        requestDate: DateTime.now().subtract(const Duration(days: 3)),
        neededBy: DateTime.now().add(const Duration(days: 7)),
        urgency: 'normal',
      ),
    ];
  }
}
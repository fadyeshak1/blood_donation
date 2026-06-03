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
  final String? distance;
  final String? compatibilityNote;

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
    this.status = 'Open',
    this.distance,
    this.compatibilityNote,
  });

  /// Parses both API response shapes:
  ///
  /// GET /api/ai/match-requests → { requestId, requesterName, hospitalName,
  ///   hospitalAddress, bloodType(str), quantity, priority(str), neededBy, status }
  ///
  /// GET /api/requests/{id}     → { id, hospitalName, bloodType, quantity,
  ///   priority, status, hospitalLocation, createdBy, createdAt, neededBy }
  factory BloodRequestModel.fromApiJson(Map<String, dynamic> json) {
    final rawBt = json['bloodType'] as String? ?? '';
    final bt = _normaliseBloodType(rawBt);

    final priority = (json['priority'] as String? ?? '').toLowerCase();
    final urgency = priority.contains('emergency') ? 'urgent' : 'normal';

    final neededByStr = json['neededBy'] as String? ?? '';

    return BloodRequestModel(
      id: json['requestId']?.toString() ??
          json['id']?.toString() ?? '',

      // requesterName → from match-requests list
      // createdBy     → from GET /api/requests/{id}
      // patientName   → legacy fallback
      patientName: json['requesterName'] as String? ??
          json['createdBy'] as String? ??
          json['patientName'] as String? ??
          'Unknown',

      bloodType: bt,
      unitsNeeded: (json['quantity'] as num?)?.toInt() ??
          (json['unitsNeeded'] as num?)?.toInt() ?? 1,
      hospitalName: json['hospitalName'] as String? ?? '',
      location: json['hospitalAddress'] as String? ??
          json['hospitalLocation'] as String? ??
          json['location'] as String? ?? '',
      contactNumber: json['contactNumber'] as String? ?? '',
      requestDate: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      neededBy: neededByStr.isNotEmpty
          ? DateTime.tryParse(neededByStr) ??
              DateTime.now().add(const Duration(days: 3))
          : DateTime.now().add(const Duration(days: 3)),
      urgency: urgency,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'Open',
      distance: json['distance'] as String?,
      compatibilityNote: json['compatibilityNote'] as String?,
    );
  }

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) =>
      BloodRequestModel.fromApiJson(json);

  Map<String, dynamic> toJson() => {
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

  bool get isUrgent => urgency.toLowerCase() == 'urgent';
  int get daysRemaining => neededBy.difference(DateTime.now()).inDays;

  static String _normaliseBloodType(String raw) {
    const types = ['AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-'];
    for (final t in types) {
      if (raw.startsWith(t)) return t;
    }
    return raw;
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
        contactNumber: '',
        requestDate: DateTime.now().subtract(const Duration(hours: 2)),
        neededBy: DateTime.now().add(const Duration(days: 1)),
        urgency: 'urgent',
        status: 'Open',
      ),
      BloodRequestModel(
        id: '2',
        patientName: 'Fatma Mohamed',
        bloodType: 'O-',
        unitsNeeded: 3,
        hospitalName: 'Ain Shams University Hospital',
        location: 'Nasr City, Cairo',
        contactNumber: '',
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        neededBy: DateTime.now().add(const Duration(days: 3)),
        urgency: 'normal',
        status: 'Open',
      ),
      BloodRequestModel(
        id: '3',
        patientName: 'Mohamed Ali',
        bloodType: 'B+',
        unitsNeeded: 1,
        hospitalName: 'Kasr Al Ainy Hospital',
        location: 'Downtown, Cairo',
        contactNumber: '',
        requestDate: DateTime.now().subtract(const Duration(hours: 5)),
        neededBy: DateTime.now().add(const Duration(hours: 12)),
        urgency: 'urgent',
        status: 'Open',
      ),
    ];
  }
}
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

  /// Parses from GET /api/ai/match-requests → results[] item.
  ///
  /// Real shape:
  /// {
  ///   "requestId": 1,
  ///   "requestedByUserId": "...",
  ///   "requesterName": "Default User",
  ///   "hospitalName": "Ain Shams University Hospital",
  ///   "hospitalAddress": "Nasr City, Cairo",
  ///   "bloodType": "A+",          ← string, NOT int
  ///   "quantity": 2,
  ///   "priority": "Emergency",    ← string, NOT int
  ///   "neededBy": "2026-05-25",
  ///   "status": "Open",
  ///   "distance": "Near you",
  ///   "compatibilityNote": "مطابق تام"
  /// }
  factory BloodRequestModel.fromApiJson(Map<String, dynamic> json) {
    // bloodType is a string like "A+" or "A+Positive" — normalise it
    final rawBloodType = json['bloodType'] as String? ?? '';
    final bloodType = _normaliseBloodType(rawBloodType);

    // priority is a string like "Emergency" or "Normal"
    final priority = (json['priority'] as String? ?? '').toLowerCase();
    final urgency = priority.contains('emergency') ? 'urgent' : 'normal';

    final neededByStr = json['neededBy'] as String? ?? '';

    return BloodRequestModel(
      id: json['requestId']?.toString() ??
          json['id']?.toString() ??
          '',
      patientName: json['requesterName'] as String? ??
          json['patientName'] as String? ??
          'Unknown',
      bloodType: bloodType,
      unitsNeeded: (json['quantity'] as num?)?.toInt() ??
          (json['unitsNeeded'] as num?)?.toInt() ??
          1,
      hospitalName: json['hospitalName'] as String? ?? '',
      location: json['hospitalAddress'] as String? ??
          json['hospitalLocation'] as String? ??
          json['location'] as String? ??
          '',
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
  int get daysRemaining => neededBy.difference(DateTime.now()).inDays;

  /// Normalises API blood type strings.
  /// "A+Positive" → "A+", "A+positive" → "A+", "A+" → "A+"
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
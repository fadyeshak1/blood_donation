class RequestHistoryModel {
  final String id;
  final String bloodType;
  final String hospitalName;
  final String hospitalLocation;
  final int bloodQuantity;
  final String priority;   // "Normal" | "Emergency"
  final DateTime neededByDate;
  final DateTime createdAt;
  final String status; // "Open" | "Fulfilled" | "Completed" | "Closed"

  const RequestHistoryModel({
    required this.id,
    required this.bloodType,
    required this.hospitalName,
    required this.hospitalLocation,
    required this.bloodQuantity,
    this.priority = 'Normal',
    required this.neededByDate,
    required this.createdAt,
    this.status = 'Open',
  });

  /// Returns the status exactly as received from the API.
  String get displayStatus => status;

  /// One-line explanation shown under the status badge.
  String get statusDescription {
    switch (status) {
      case 'Open':      return 'Waiting for a donor to accept your request.';
      case 'Fulfilled': return 'A donor confirmed — blood is ready for pickup.';
      case 'Completed': return 'Blood successfully received by the patient.';
      case 'Closed':    return 'Request was cancelled or expired.';
      default:          return '';
    }
  }

  factory RequestHistoryModel.fromJson(Map<String, dynamic> json) {
    return RequestHistoryModel(
      id: json['id']?.toString() ?? '',
      bloodType: _normaliseBloodType(json['bloodType'] as String? ?? ''),
      hospitalName: json['hospitalName'] as String? ?? '',
      hospitalLocation: json['hospitalLocation'] as String? ??
          json['location'] as String? ?? '',
      bloodQuantity: (json['quantity'] as num?)?.toInt() ??
          (json['bloodQuantity'] as num?)?.toInt() ?? 1,
      priority: json['priority'] as String? ?? 'Normal',
      neededByDate:
          DateTime.tryParse(json['neededBy'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 3)),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? 'Open',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bloodType': bloodType,
        'hospitalName': hospitalName,
        'hospitalLocation': hospitalLocation,
        'bloodQuantity': bloodQuantity,
        'priority': priority,
        'neededByDate': neededByDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  static String _normaliseBloodType(String raw) {
    const types = ['AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-'];
    for (final t in types) {
      if (raw.startsWith(t)) return t;
    }
    return raw;
  }
}
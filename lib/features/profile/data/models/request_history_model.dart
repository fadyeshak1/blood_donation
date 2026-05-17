class RequestHistoryModel {
  final String id;
  final String bloodType;
  final String hospitalName;
  final String hospitalLocation;
  final int bloodQuantity;
  final DateTime neededByDate;
  final DateTime createdAt;
  final String status; // 'pending' | 'fulfilled' | 'cancelled' | 'expired'

  const RequestHistoryModel({
    required this.id,
    required this.bloodType,
    required this.hospitalName,
    required this.hospitalLocation,
    required this.bloodQuantity,
    required this.neededByDate,
    required this.createdAt,
    this.status = 'pending',
  });

  String get urgency {
    final days = neededByDate.difference(DateTime.now()).inDays;
    return days <= 3 ? 'urgent' : 'normal';
  }

  factory RequestHistoryModel.fromJson(Map<String, dynamic> json) {
    return RequestHistoryModel(
      id: json['id'] as String,
      bloodType: json['bloodType'] as String,
      hospitalName: json['hospitalName'] as String,
      hospitalLocation: json['hospitalLocation'] as String,
      bloodQuantity: (json['bloodQuantity'] as num).toInt(),
      neededByDate: DateTime.parse(json['neededByDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bloodType': bloodType,
        'hospitalName': hospitalName,
        'hospitalLocation': hospitalLocation,
        'bloodQuantity': bloodQuantity,
        'neededByDate': neededByDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  RequestHistoryModel copyWith({String? status}) {
    return RequestHistoryModel(
      id: id,
      bloodType: bloodType,
      hospitalName: hospitalName,
      hospitalLocation: hospitalLocation,
      bloodQuantity: bloodQuantity,
      neededByDate: neededByDate,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}
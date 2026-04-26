class RedemptionHistoryModel {
  final String id;
  final String rewardTitle;
  final int pointsSpent;
  final DateTime redeemedAt;
  final String status;
  final String? code;

  const RedemptionHistoryModel({
    required this.id,
    required this.rewardTitle,
    required this.pointsSpent,
    required this.redeemedAt,
    required this.status,
    this.code,
  });

  factory RedemptionHistoryModel.fromJson(Map<String, dynamic> json) {
    return RedemptionHistoryModel(
      id: json['id'] as String,
      rewardTitle: json['rewardTitle'] as String,
      pointsSpent: (json['pointsSpent'] as num).toInt(),
      redeemedAt: DateTime.parse(json['redeemedAt'] as String),
      status: json['status'] as String,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rewardTitle': rewardTitle,
      'pointsSpent': pointsSpent,
      'redeemedAt': redeemedAt.toIso8601String(),
      'status': status,
      if (code != null) 'code': code,
    };
  }

  static List<RedemptionHistoryModel> getSampleHistory() {
    return [
      RedemptionHistoryModel(
        id: '1',
        rewardTitle: 'Coffee Voucher',
        pointsSpent: 100,
        redeemedAt: DateTime.now().subtract(const Duration(days: 5)),
        status: 'used',
        code: 'COFFEE123',
      ),
      RedemptionHistoryModel(
        id: '2',
        rewardTitle: 'Blood Donor T-Shirt',
        pointsSpent: 150,
        redeemedAt: DateTime.now().subtract(const Duration(days: 15)),
        status: 'claimed',
        code: 'SHIRT456',
      ),
    ];
  }
}
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
      // API returns id as int — always convert with .toString()
      id: json['id']?.toString() ?? '',

      // Try multiple possible field names the API might use
      rewardTitle: json['rewardTitle'] as String? ??
          json['reward'] as String? ??
          json['title'] as String? ??
          json['rewardName'] as String? ??
          '',

      pointsSpent: (json['pointsSpent'] as num?)?.toInt() ??
          (json['pointsRequired'] as num?)?.toInt() ??
          (json['points'] as num?)?.toInt() ??
          0,

      redeemedAt: json['redeemedAt'] != null
          ? DateTime.tryParse(json['redeemedAt'] as String) ??
              DateTime.now()
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String) ??
                  DateTime.now()
              : DateTime.now(),

      status: json['status'] as String? ?? 'redeemed',

      code: json['code'] as String? ?? json['voucherCode'] as String?,
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
}
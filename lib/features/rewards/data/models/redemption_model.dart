/// Represents one item from GET /api/users/rewards (redemption history).
/// Fields are mapped defensively since the API schema is not documented.
class RedemptionModel {
  final String id;
  final String rewardTitle;
  final int pointsSpent;
  final DateTime redeemedAt;
  final String status; // 'Unused' | 'Used'

  const RedemptionModel({
    required this.id,
    required this.rewardTitle,
    required this.pointsSpent,
    required this.redeemedAt,
    required this.status,
  });

  bool get isUsed => status.toLowerCase() == 'used';

  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    return RedemptionModel(
      id: json['id']?.toString() ?? '',
      rewardTitle: json['rewardTitle'] as String? ??
          json['reward'] as String? ??
          json['title'] as String? ??
          json['rewardName'] as String? ?? '',
      pointsSpent: (json['pointsSpent'] as num?)?.toInt() ??
          (json['pointsRequired'] as num?)?.toInt() ??
          (json['points'] as num?)?.toInt() ?? 0,
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.tryParse(json['redeemedAt'] as String) ?? DateTime.now()
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
              : DateTime.now(),
      status: json['status'] as String? ?? 'Unused',
    );
  }
}
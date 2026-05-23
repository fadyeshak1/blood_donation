class DashboardStatsModel {
  final int totalDonations;
  final int livesSaved;
  final int streakDays;
  final int totalPoints;
  final bool isEligibleToDonate;
  final DateTime? nextEligibleDate;
  // kept for display
  final String bloodType;
  final String donorId;

  const DashboardStatsModel({
    required this.totalDonations,
    required this.livesSaved,
    required this.streakDays,
    required this.totalPoints,
    required this.isEligibleToDonate,
    this.nextEligibleDate,
    this.bloodType = '',
    this.donorId = '',
  });

  /// Parses from GET /api/users/dashboard:
  /// { fullName, totalDonations, totalPoints }
  /// Fields not returned by the API default to safe values.
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalDonations:
          (json['totalDonations'] as num?)?.toInt() ?? 0,
      livesSaved:
          (json['livesSaved'] as num?)?.toInt() ??
              // Derive: each donation saves ~3 lives
              ((json['totalDonations'] as num?)?.toInt() ?? 0) * 3,
      streakDays:
          (json['streakDays'] as num?)?.toInt() ?? 0,
      totalPoints:
          (json['totalPoints'] as num?)?.toInt() ?? 0,
      isEligibleToDonate:
          json['isEligibleToDonate'] as bool? ?? true,
      nextEligibleDate: json['nextEligibleDate'] != null
          ? DateTime.tryParse(json['nextEligibleDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDonations': totalDonations,
      'livesSaved': livesSaved,
      'streakDays': streakDays,
      'totalPoints': totalPoints,
      'isEligibleToDonate': isEligibleToDonate,
      if (nextEligibleDate != null)
        'nextEligibleDate': nextEligibleDate!.toIso8601String(),
    };
  }

  static DashboardStatsModel getSampleStats() {
    return const DashboardStatsModel(
      totalDonations: 0,
      livesSaved: 0,
      streakDays: 0,
      totalPoints: 0,
      isEligibleToDonate: true,
    );
  }
}
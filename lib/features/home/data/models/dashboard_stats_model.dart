class DashboardStatsModel {
  final int totalDonations;
  final int livesSaved;
  final int streakDays;
  final int totalPoints;
  final bool isEligibleToDonate;
  final DateTime? nextEligibleDate;

  const DashboardStatsModel({
    required this.totalDonations,
    required this.livesSaved,
    required this.streakDays,
    required this.totalPoints,
    required this.isEligibleToDonate,
    this.nextEligibleDate,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalDonations: (json['totalDonations'] as num).toInt(),
      livesSaved: (json['livesSaved'] as num).toInt(),
      streakDays: (json['streakDays'] as num).toInt(),
      totalPoints: (json['totalPoints'] as num).toInt(),
      isEligibleToDonate: json['isEligibleToDonate'] as bool,
      nextEligibleDate: json['nextEligibleDate'] != null
          ? DateTime.parse(json['nextEligibleDate'] as String)
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
    return DashboardStatsModel(
      totalDonations: 12,
      livesSaved: 36,
      streakDays: 45,
      totalPoints: 1200,
      isEligibleToDonate: false,
      nextEligibleDate: DateTime.now().add(const Duration(days: 11)),
    );
  }
}

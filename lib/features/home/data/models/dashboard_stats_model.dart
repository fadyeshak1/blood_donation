class DashboardStatsModel {
  final String fullName;  // from GET /api/users/dashboard
  final int totalDonations;
  final int livesSaved;
  final int streakDays;
  final int totalPoints;
  final bool isEligibleToDonate;
  final DateTime? nextEligibleDate;
  final String bloodType;
  final String donorId;

  const DashboardStatsModel({
    this.fullName = '',
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
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      fullName: json['fullName'] as String? ?? '',
      totalDonations:
          (json['totalDonations'] as num?)?.toInt() ?? 0,
      livesSaved: (json['livesSaved'] as num?)?.toInt() ??
          ((json['totalDonations'] as num?)?.toInt() ?? 0) * 3,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      isEligibleToDonate:
          json['isEligibleToDonate'] as bool? ?? true,
      nextEligibleDate: json['nextEligibleDate'] != null
          ? DateTime.tryParse(json['nextEligibleDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
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
      fullName: '',
      totalDonations: 0,
      livesSaved: 0,
      streakDays: 0,
      totalPoints: 0,
      isEligibleToDonate: true,
    );
  }
}
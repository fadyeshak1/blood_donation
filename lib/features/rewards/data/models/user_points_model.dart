class UserPointsModel {
  final int totalPoints;
  final int availablePoints;
  final int redeemedPoints;
  final int lifetimePoints;

  const UserPointsModel({
    required this.totalPoints,
    required this.availablePoints,
    required this.redeemedPoints,
    required this.lifetimePoints,
  });

  factory UserPointsModel.fromJson(Map<String, dynamic> json) {
    return UserPointsModel(
      totalPoints: (json['totalPoints'] as num).toInt(),
      availablePoints: (json['availablePoints'] as num).toInt(),
      redeemedPoints: (json['redeemedPoints'] as num).toInt(),
      lifetimePoints: (json['lifetimePoints'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'redeemedPoints': redeemedPoints,
      'lifetimePoints': lifetimePoints,
    };
  }

  static UserPointsModel getSamplePoints() {
    return const UserPointsModel(
      totalPoints: 1200,
      availablePoints: 1200,
      redeemedPoints: 0,
      lifetimePoints: 1200,
    );
  }
}

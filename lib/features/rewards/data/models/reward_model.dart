class RewardModel {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final bool isAvailable;
  final String? category;

  const RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.isAvailable,
    this.category,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      // API returns id as int — always convert with .toString()
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pointsRequired: (json['pointsRequired'] as num?)?.toInt() ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsRequired': pointsRequired,
      'isAvailable': isAvailable,
      if (category != null) 'category': category,
    };
  }
}
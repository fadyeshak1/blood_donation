class RewardModel {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final bool isAvailable;
  final String? imageUrl;
  final String? category;

  const RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.isAvailable,
    this.imageUrl,
    this.category,
  });

  /// Parses from GET /api/rewards:
  /// { id, title, description, isAvailable }
  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pointsRequired:
          (json['pointsRequired'] as num?)?.toInt() ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
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
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (category != null) 'category': category,
    };
  }

  static List<RewardModel> getSampleRewards() {
    return [
      const RewardModel(
        id: '1',
        title: 'Free Medical Checkup',
        description:
            'Get a free basic health checkup at participating clinics.',
        pointsRequired: 0,
        isAvailable: true,
        category: 'Health',
      ),
      const RewardModel(
        id: '2',
        title: 'Pharmacy Discount',
        description: '20% discount at partner pharmacies on your next purchase.',
        pointsRequired: 0,
        isAvailable: true,
        category: 'Shopping',
      ),
      const RewardModel(
        id: '3',
        title: 'Blood Test Package',
        description:
            'Complete blood test panel including CBC and metabolic panel.',
        pointsRequired: 0,
        isAvailable: true,
        category: 'Health',
      ),
      const RewardModel(
        id: '4',
        title: 'Hospital Priority Service',
        description:
            'Skip the queue at partner hospitals for your next visit.',
        pointsRequired: 0,
        isAvailable: true,
        category: 'Health',
      ),
      const RewardModel(
        id: '5',
        title: 'Full Health Package',
        description:
            'Comprehensive health screening including blood work, ECG, and consultation.',
        pointsRequired: 0,
        isAvailable: true,
        category: 'Health',
      ),
    ];
  }
}
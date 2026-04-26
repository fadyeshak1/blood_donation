class RewardModel {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final int stockRemaining;

  const RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.category,
    required this.imageUrl,
    this.isAvailable = true,
    this.stockRemaining = 0,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pointsRequired: (json['pointsRequired'] as num).toInt(),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      stockRemaining: (json['stockRemaining'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsRequired': pointsRequired,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'stockRemaining': stockRemaining,
    };
  }

  static List<RewardModel> getSampleRewards() {
    return [
      RewardModel(
        id: '1',
        title: 'Coffee Voucher',
        description: '1 free coffee at any partner café',
        pointsRequired: 100,
        category: 'Food & Beverage',
        imageUrl: 'https://via.placeholder.com/150',
        stockRemaining: 50,
      ),
      RewardModel(
        id: '2',
        title: 'Movie Ticket',
        description: '1 cinema ticket at VOX Cinemas',
        pointsRequired: 200,
        category: 'Entertainment',
        imageUrl: 'https://via.placeholder.com/150',
        stockRemaining: 30,
      ),
      RewardModel(
        id: '3',
        title: 'Restaurant Meal',
        description: 'Free meal voucher (up to 150 EGP)',
        pointsRequired: 300,
        category: 'Food & Beverage',
        imageUrl: 'https://via.placeholder.com/150',
        stockRemaining: 20,
      ),
      RewardModel(
        id: '4',
        title: 'Gym Membership',
        description: '1 month free gym membership',
        pointsRequired: 500,
        category: 'Health & Fitness',
        imageUrl: 'https://via.placeholder.com/150',
        stockRemaining: 10,
      ),
      RewardModel(
        id: '5',
        title: 'Blood Donor T-Shirt',
        description: 'Exclusive blood donor merchandise',
        pointsRequired: 150,
        category: 'Merchandise',
        imageUrl: 'https://via.placeholder.com/150',
        stockRemaining: 100,
      ),
      RewardModel(
        id: '6',
        title: 'Shopping Voucher',
        description: '200 EGP shopping voucher',
        pointsRequired: 400,
        category: 'Shopping',
        imageUrl: 'https://via.placeholder.com/150',
        stockRemaining: 15,
      ),
    ];
  }
}

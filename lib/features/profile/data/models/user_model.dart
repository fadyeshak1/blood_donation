class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String bloodType;
  final String donorId;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? profileImage;
  final int totalDonations;
  final int pointsEarned;
  final DateTime? lastDonationDate;
  final DateTime? nextEligibleDate;
  final bool isEligibleToDonate;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodType,
    required this.donorId,
    this.dateOfBirth,
    this.address,
    this.city,
    this.profileImage,
    this.totalDonations = 0,
    this.pointsEarned = 0,
    this.lastDonationDate,
    this.nextEligibleDate,
    this.isEligibleToDonate = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      bloodType: json['bloodType'] as String,
      donorId: json['donorId'] as String,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String) 
          : null,
      address: json['address'] as String?,
      city: json['city'] as String?,
      profileImage: json['profileImage'] as String?,
      totalDonations: (json['totalDonations'] as num?)?.toInt() ?? 0,
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      lastDonationDate: json['lastDonationDate'] != null
          ? DateTime.parse(json['lastDonationDate'] as String)
          : null,
      nextEligibleDate: json['nextEligibleDate'] != null
          ? DateTime.parse(json['nextEligibleDate'] as String)
          : null,
      isEligibleToDonate: json['isEligibleToDonate'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'bloodType': bloodType,
      'donorId': donorId,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (profileImage != null) 'profileImage': profileImage,
      'totalDonations': totalDonations,
      'pointsEarned': pointsEarned,
      if (lastDonationDate != null) 
        'lastDonationDate': lastDonationDate!.toIso8601String(),
      if (nextEligibleDate != null) 
        'nextEligibleDate': nextEligibleDate!.toIso8601String(),
      'isEligibleToDonate': isEligibleToDonate,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? bloodType,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? profileImage,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodType: bloodType ?? this.bloodType,
      donorId: donorId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      profileImage: profileImage ?? this.profileImage,
      totalDonations: totalDonations,
      pointsEarned: pointsEarned,
      lastDonationDate: lastDonationDate,
      nextEligibleDate: nextEligibleDate,
      isEligibleToDonate: isEligibleToDonate,
    );
  }

  // Sample data for development/testing
  static UserModel getSampleUser() {
    return UserModel(
      id: 'user_123',
      name: 'Ahmed Hassan',
      email: 'ahmed.hassan@example.com',
      phone: '01012345678',
      bloodType: 'A+',
      donorId: 'DN2024001',
      dateOfBirth: DateTime(1995, 5, 15),
      address: '123 Tahrir Street',
      city: 'Cairo',
      totalDonations: 12,
      pointsEarned: 1200,
      lastDonationDate: DateTime.now().subtract(const Duration(days: 45)),
      nextEligibleDate: DateTime.now().add(const Duration(days: 11)),
      isEligibleToDonate: false,
    );
  }
}
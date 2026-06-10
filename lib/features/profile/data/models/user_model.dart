class UserModel {
  final String id;
  final String name;          // existing field — kept as-is
  final String email;
  final String phone;         // existing field — kept as-is
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
  final int age;
  final int gender;
  final String? nationalId;
  final double? latitude;     // NEW — for location update
  final double? longitude;    // NEW — for location update

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
    this.age = 0,
    this.gender = 0,
    this.nationalId,
    this.latitude,
    this.longitude,
  });

  bool get hasLocation => latitude != null && longitude != null;

  factory UserModel.fromProfileJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['fullName'] as String? ??
          json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phoneNumber'] as String? ??
          json['phone'] as String? ?? '',
      bloodType: json['bloodType']?.toString() ?? '',
      donorId: json['donorId']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      address: json['address'] as String?,
      city: json['city'] as String? ??
          json['administrativeArea'] as String?,
      profileImage: json['profileImage'] as String?,
      totalDonations:
          (json['totalDonations'] as num?)?.toInt() ?? 0,
      pointsEarned:
          (json['pointsEarned'] as num?)?.toInt() ??
          (json['totalPoints'] as num?)?.toInt() ?? 0,
      lastDonationDate: json['lastDonationDate'] != null
          ? DateTime.tryParse(json['lastDonationDate'] as String)
          : null,
      nextEligibleDate: json['nextEligibleDate'] != null
          ? DateTime.tryParse(json['nextEligibleDate'] as String)
          : null,
      isEligibleToDonate:
          json['isEligibleToDonate'] as bool? ?? true,
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: (json['gender'] as num?)?.toInt() ?? 0,
      nationalId: json['nationalId'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel.fromProfileJson(json);

  /// Sent to PUT /api/users/profile.
  /// Uses the backend's expected field names (fullName, phoneNumber).
  Map<String, dynamic> toJson() {
    return {
      'fullName': name,
      'phoneNumber': phone,
      'age': age,
      'gender': gender,
      'address': address ?? '',
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? bloodType,
    String? donorId,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? profileImage,
    int? totalDonations,
    int? pointsEarned,
    DateTime? lastDonationDate,
    DateTime? nextEligibleDate,
    bool? isEligibleToDonate,
    int? age,
    int? gender,
    String? nationalId,
    double? latitude,
    double? longitude,
    bool clearLocation = false,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodType: bloodType ?? this.bloodType,
      donorId: donorId ?? this.donorId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      profileImage: profileImage ?? this.profileImage,
      totalDonations: totalDonations ?? this.totalDonations,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      nextEligibleDate: nextEligibleDate ?? this.nextEligibleDate,
      isEligibleToDonate: isEligibleToDonate ?? this.isEligibleToDonate,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      nationalId: nationalId ?? this.nationalId,
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
    );
  }

  UserModel copyWithDashboard({
    required int totalDonations,
    required int totalPoints,
  }) {
    return copyWith(
      totalDonations: totalDonations,
      pointsEarned: totalPoints,
    );
  }
}
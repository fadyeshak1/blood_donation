import 'package:blood_donation/core/network/api_enums.dart';

class UserModel {
  final String id;
  final String name;          // fullName
  final String email;
  final String phone;         // phoneNumber
  final String bloodType;
  final int? age;
  final String? gender;       // display string converted from int
  final String? address;
  final String? nationalId;
  final DateTime? createdAt;
  // From dashboard endpoint
  final int totalDonations;
  final int pointsEarned;
  // Legacy fields kept so existing widgets don't break
  final String? city;
  final String? profileImage;
  final DateTime? dateOfBirth;
  final DateTime? nextEligibleDate;
  final bool isEligibleToDonate;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodType,
    this.age,
    this.gender,
    this.address,
    this.nationalId,
    this.createdAt,
    this.totalDonations = 0,
    this.pointsEarned = 0,
    this.city,
    this.profileImage,
    this.dateOfBirth,
    this.nextEligibleDate,
    this.isEligibleToDonate = true,
  });

  // ── Parsing ──────────────────────────────────────────────────────────────

  /// Parses from GET /api/users/profile:
  /// { id, fullName, email, phoneNumber, age, gender(int), address, nationalId, createdAt }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final bloodTypeRaw = json['bloodType'];
    final bloodTypeStr = bloodTypeRaw is int
        ? BloodTypeEnum.fromInt(bloodTypeRaw)
        : bloodTypeRaw as String? ?? '';

    final genderRaw = json['gender'];
    final genderStr = genderRaw is int
        ? GenderEnum.fromInt(genderRaw)
        : genderRaw as String?;

    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['fullName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phoneNumber'] as String? ?? json['phone'] as String? ?? '',
      bloodType: bloodTypeStr,
      age: (json['age'] as num?)?.toInt(),
      gender: genderStr,
      address: json['address'] as String?,
      nationalId: json['nationalId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      totalDonations: (json['totalDonations'] as num?)?.toInt() ?? 0,
      pointsEarned:
          (json['totalPoints'] as num? ?? json['pointsEarned'] as num?)
                  ?.toInt() ??
              0,
      city: json['city'] as String?,
      profileImage: json['profileImage'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      nextEligibleDate: json['nextEligibleDate'] != null
          ? DateTime.tryParse(json['nextEligibleDate'] as String)
          : null,
      isEligibleToDonate: json['isEligibleToDonate'] as bool? ?? true,
    );
  }

  factory UserModel.fromProfileJson(Map<String, dynamic> json) =>
      UserModel.fromJson(json);

  UserModel copyWithDashboard({
    required int totalDonations,
    required int totalPoints,
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      bloodType: bloodType,
      age: age,
      gender: gender,
      address: address,
      nationalId: nationalId,
      createdAt: createdAt,
      totalDonations: totalDonations,
      pointsEarned: totalPoints,
      city: city,
      profileImage: profileImage,
      dateOfBirth: dateOfBirth,
      nextEligibleDate: nextEligibleDate,
      isEligibleToDonate: isEligibleToDonate,
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? bloodType,
    int? age,
    String? gender,
    String? address,
    String? profileImage,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodType: bloodType ?? this.bloodType,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      nationalId: nationalId,
      createdAt: createdAt,
      totalDonations: totalDonations,
      pointsEarned: pointsEarned,
      city: city,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth,
      nextEligibleDate: nextEligibleDate,
      isEligibleToDonate: isEligibleToDonate,
    );
  }

  /// PUT /api/users/profile always requires these 4 fields.
  /// Any field the user didn't change is pre-filled with the current value.
  Map<String, dynamic> toJson() {
    return {
      'fullName': name,
      'phoneNumber': phone,
      'address': address ?? '',
      'age': age ?? 0,
    };
  }

  static UserModel getSampleUser() {
    return const UserModel(
      id: 'user_123',
      name: 'Default User',
      email: 'user@app.com',
      phone: '01000000002',
      bloodType: '',
      age: 25,
      gender: 'Male',
      address: 'Giza, Egypt',
      totalDonations: 0,
      pointsEarned: 0,
    );
  }
}
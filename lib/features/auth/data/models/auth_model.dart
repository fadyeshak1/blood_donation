import 'package:blood_donation/core/network/api_enums.dart';

// ─── Login ────────────────────────────────────────────────────────────────────

class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'Email': email,
        'Password': password,
      };
}

// ─── Register ─────────────────────────────────────────────────────────────────

class RegisterRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final int age;
  final String gender;   // display string — converted to int for API
  final String address;
  final String nationalId;
  final String bloodType; // display string — converted to int for API
  final double latitude;
  final double longitude;

  const RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
    required this.age,
    required this.gender,
    required this.address,
    required this.nationalId,
    required this.bloodType,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'phoneNumber': phoneNumber,
        'age': age,
        'gender': GenderEnum.toInt(gender),
        'address': address,
        'nationalId': nationalId,
        'bloodType': BloodTypeEnum.toInt(bloodType),
        'latitude': latitude,
        'longitude': longitude,
      };
}

// ─── Auth Response ────────────────────────────────────────────────────────────
// Returned by both login and register.

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;       // seconds (900 = 15 min)
  final AuthUserModel? user;
  final String? message;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.user,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
      user: json['user'] != null
          ? AuthUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }
}

class AuthUserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;

  const AuthUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
    );
  }
}

// ─── Refresh Token ─────────────────────────────────────────────────────────────

class RefreshTokenRequestModel {
  final String refreshToken;

  const RefreshTokenRequestModel({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}
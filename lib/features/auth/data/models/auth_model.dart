// ─── Login Request ────────────────────────────────────────────────────────────

class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

// ─── Register Request ─────────────────────────────────────────────────────────

class RegisterRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;
  final int age;
  final String gender;      // 'Male' | 'Female'
  final String bloodType;   // 'A+' | 'A-' | 'B+' | 'B-' | 'AB+' | 'AB-' | 'O+' | 'O-'
  final String address;
  final String location;    // From map picker / GPS
  final String nationalId;

  const RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.address,
    required this.location,
    required this.nationalId,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'age': age,
        'gender': gender,
        'bloodType': bloodType,
        'address': address,
        'location': location,
        'nationalId': nationalId,
      };
}

// ─── Auth Response (Login & Register both return this) ───────────────────────

class AuthResponseModel {
  final String token;
  final String userId;
  final String fullName;
  final String email;
  final String bloodType;
  final String role; // 'donor' | 'patient' | 'admin'

  const AuthResponseModel({
    required this.token,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.bloodType,
    required this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String,
      bloodType: json['bloodType'] as String? ?? '',
      role: json['role'] as String? ?? 'donor',
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'userId': userId,
        'fullName': fullName,
        'email': email,
        'bloodType': bloodType,
        'role': role,
      };
}
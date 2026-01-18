class AppConstants {
  // App Info
  static const String appName = 'Blood Donation';
  static const String appVersion = '1.0.0';
  
  // Blood Types
  static const List<String> bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];
  
  // Donation Rules
  static const int minDonationAgeDays = 56; // 8 weeks
  static const int minDonorAge = 18;
  static const int maxDonorAge = 65;
  static const double minDonorWeight = 50.0; // kg
  
  // Points System
  static const int pointsPerDonation = 100;
  static const int pointsPerUnit = 100;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
}

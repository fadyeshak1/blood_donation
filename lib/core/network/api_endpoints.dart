class ApiEndpoints {
  // Base
  static const String baseUrl = 'https://api.blooddonation.com/v1';
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  
  // Profile
  static String userProfile(String userId) => '/users/$userId';
  static String updateProfile(String userId) => '/users/$userId';
  static String donationHistory(String userId) => '/users/$userId/donations';
  
  // Requests
  static const String bloodRequests = '/blood-requests';
  static String requestDetails(String requestId) => '/blood-requests/$requestId';
  static String acceptRequest(String requestId) => '/blood-requests/$requestId/accept';
  
  // Donations
  static String userDonations(String userId) => '/users/$userId/donations';
  static String donationDetails(String donationId) => '/donations/$donationId';
  
  // Rewards
  static String userRewards(String userId) => '/users/$userId/rewards';
  static String redeemReward(String rewardId) => '/rewards/$rewardId/redeem';
  
  // Chat
  static const String sendMessage = '/chat/message';
  static String chatHistory(String userId) => '/chat/$userId/history';
  
  // Notifications
  static String userNotifications(String userId) => '/users/$userId/notifications';
}
class ApiEndpoints {
  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String changePassword = '/api/auth/change-password';

  // ── User Profile ───────────────────────────────────────────────────────────
  static const String profile = '/api/users/profile';
  static const String dashboard = '/api/users/dashboard';
  static const String myRewards = '/api/users/rewards';

  // ── Blood Requests ─────────────────────────────────────────────────────────
  static const String createRequest = '/api/requests';
  static const String myRequests = '/api/requests/my';
  static String requestById(int id) => '/api/requests/$id';
  static String deleteRequest(int id) => '/api/requests/$id';

  /// GET — generates QR for the requester to scan at blood pickup.
  /// Requires Hospital role — hospital staff uses this.
  static String requestPickupQr(int requestId) =>
      '/api/requests/$requestId/pickup-qr';

  /// POST {qrToken} — called by the requester to confirm blood received.
  /// Requires User (requester) role.
  static String pickupScan(int requestId) =>
      '/api/requests/$requestId/pickup-scan';

  /// AI-powered matching
  static const String matchRequests = '/api/ai/match-requests';

  // ── Hospitals ──────────────────────────────────────────────────────────────
  static const String hospitalsDropdown = '/api/hospitals/dropdown';

  // ── Donations ─────────────────────────────────────────────────────────────
  static const String createDonation = '/api/donations';
  static const String myDonations = '/api/donations/my';
  static String cancelDonation(int id) => '/api/donations/$id/cancel';

  /// GET — generates a fresh QR token for a Pending donation.
  /// Called by the donor; hospital staff scans it via the hospital app/role.
  static String donationQr(int id) => '/api/donations/$id/qr';

  // ── Rewards ────────────────────────────────────────────────────────────────
  static const String rewards = '/api/rewards';
  static String rewardById(int id) => '/api/rewards/$id';
  static const String redeemReward = '/api/rewards/redeem';

  // ── Notifications ──────────────────────────────────────────────────────────
  static const String notifications = '/api/notifications';
  static String readNotification(int id) => '/api/notifications/$id/read';
}
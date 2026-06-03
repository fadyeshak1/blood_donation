class ApiEndpoints {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login            = '/api/auth/login';
  static const String register         = '/api/auth/register';
  static const String logout           = '/api/auth/logout';
  static const String refreshToken     = '/api/auth/refresh-token';
  static const String forgotPassword   = '/api/auth/forgot-password';
  static const String resetPassword    = '/api/auth/reset-password';
  static const String changePassword   = '/api/auth/change-password';

  // ── User ──────────────────────────────────────────────────────────────────
  static const String profile          = '/api/users/profile';
  static const String dashboard        = '/api/users/dashboard';
  static const String myRewards        = '/api/users/rewards';

  // ── Requests ──────────────────────────────────────────────────────────────
  static const String createRequest    = '/api/requests';
  static const String myRequests       = '/api/requests/my';
  static const String matchRequests    = '/api/ai/match-requests';
  static const String pickupScan       = '/api/requests/pickup-scan';
  static String requestById(int id)    => '/api/requests/$id';
  static String deleteRequest(int id)  => '/api/requests/$id';

  // ── Hospitals ─────────────────────────────────────────────────────────────
  static const String hospitalsDropdown = '/api/hospitals/dropdown';

  // ── Donations ─────────────────────────────────────────────────────────────
  static const String createDonation   = '/api/donations';
  static const String myDonations      = '/api/donations/my';
  static String cancelDonation(int id) => '/api/donations/$id/cancel';
  static String donationQr(int id)     => '/api/donations/$id/qr';

  // ── Rewards ───────────────────────────────────────────────────────────────
  static const String rewards          = '/api/rewards';
  static const String redeemReward     = '/api/rewards/redeem';
  static String rewardById(int id)     => '/api/rewards/$id';

  // GET  /api/rewards/redemptions/{id}/qr  → QR token for a redeemed reward
  static String redemptionQr(int redemptionId) =>
      '/api/rewards/redemptions/$redemptionId/qr';

  // POST /api/hospital/rewards/scan  body:{qrToken} → marks reward as Used
  static const String rewardScan = '/api/hospital/rewards/scan';
}
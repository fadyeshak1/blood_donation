/// Response from GET /api/donations/{id}/qr
/// {
///   "qrToken": "4d14e4238f...",
///   "qrType": "Donation",
///   "referenceId": 2,
///   "expiresAt": "2026-05-24T10:28:12.493Z"   ← always UTC
/// }
class DonationQrModel {
  final String qrToken;
  final String qrType;
  final int referenceId;
  final DateTime expiresAt; // stored as UTC

  const DonationQrModel({
    required this.qrToken,
    required this.qrType,
    required this.referenceId,
    required this.expiresAt,
  });

  factory DonationQrModel.fromJson(Map<String, dynamic> json) {
    return DonationQrModel(
      qrToken: json['qrToken'] as String,
      qrType: json['qrType'] as String? ?? 'Donation',
      referenceId: (json['referenceId'] as num).toInt(),
      // toUtc() ensures the DateTime is stored in UTC regardless of
      // whether Dart parsed the trailing Z as local or UTC.
      expiresAt: _parseUtc(json['expiresAt'] as String),
    );
  }

  // Always compare UTC vs UTC — never mix local and UTC datetimes.
  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  Duration get remaining => expiresAt.difference(DateTime.now().toUtc());

  int get minutesRemaining => remaining.inMinutes;
  int get secondsRemaining => remaining.inSeconds;

  /// Parses a datetime string that may or may not have a timezone suffix.
  /// The API returns expiresAt without a Z suffix even though the value is UTC.
  /// Appending Z before parsing forces Dart to treat it as UTC.
  static DateTime _parseUtc(String raw) {
    final normalised =
        (raw.endsWith('Z') || raw.contains('+')) ? raw : '${raw}Z';
    return DateTime.parse(normalised).toUtc();
  }
}
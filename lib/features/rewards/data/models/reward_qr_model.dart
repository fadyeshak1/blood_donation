/// Response from GET /api/rewards/redemptions/{id}/qr
class RewardQrModel {
  final String qrToken;
  final String? qrType;
  final DateTime? expiresAt;

  const RewardQrModel({
    required this.qrToken,
    this.qrType,
    this.expiresAt,
  });

  factory RewardQrModel.fromJson(Map<String, dynamic> json) {
    return RewardQrModel(
      qrToken: json['qrToken'] as String? ?? '',
      qrType: json['qrType'] as String?,
      expiresAt: json['expiresAt'] != null
          ? _parseUtc(json['expiresAt'] as String)
          : null,
    );
  }

  bool get isExpired =>
      expiresAt != null && DateTime.now().toUtc().isAfter(expiresAt!);

  Duration get remaining =>
      expiresAt != null
          ? expiresAt!.difference(DateTime.now().toUtc())
          : const Duration(minutes: 15);

  /// Parses datetime string — appends Z if no timezone suffix
  /// because the API returns UTC datetimes without the Z suffix.
  static DateTime _parseUtc(String raw) {
    final normalised =
        (raw.endsWith('Z') || raw.contains('+')) ? raw : '${raw}Z';
    return DateTime.parse(normalised).toUtc();
  }
}
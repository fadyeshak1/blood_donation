class DonationHistoryModel {
  final String id;
  final DateTime date;
  final String hospitalName;
  final String location;
  final int unitsQuantity;
  final int pointsEarned;
  final String certificateUrl;

  const DonationHistoryModel({
    required this.id,
    required this.date,
    required this.hospitalName,
    required this.location,
    required this.unitsQuantity,
    required this.pointsEarned,
    required this.certificateUrl,
  });

  factory DonationHistoryModel.fromJson(Map<String, dynamic> json) {
    return DonationHistoryModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      hospitalName: json['hospitalName'] as String,
      location: json['location'] as String,
      unitsQuantity: (json['unitsQuantity'] as num).toInt(),
      pointsEarned: (json['pointsEarned'] as num).toInt(),
      certificateUrl: json['certificateUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'hospitalName': hospitalName,
      'location': location,
      'unitsQuantity': unitsQuantity,
      'pointsEarned': pointsEarned,
      'certificateUrl': certificateUrl,
    };
  }

  // Sample data for development/testing
  static List<DonationHistoryModel> getSampleHistory() {
    return [
      DonationHistoryModel(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 45)),
        hospitalName: 'Cairo University Hospital',
        location: 'Giza, Cairo',
        unitsQuantity: 1,
        pointsEarned: 100,
        certificateUrl: 'https://example.com/cert1',
      ),
      DonationHistoryModel(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 101)),
        hospitalName: 'Ain Shams Hospital',
        location: 'Nasr City, Cairo',
        unitsQuantity: 1,
        pointsEarned: 100,
        certificateUrl: 'https://example.com/cert2',
      ),
      DonationHistoryModel(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 157)),
        hospitalName: 'Kasr Al Ainy Hospital',
        location: 'Downtown, Cairo',
        unitsQuantity: 2,
        pointsEarned: 200,
        certificateUrl: 'https://example.com/cert3',
      ),
    ];
  }
}
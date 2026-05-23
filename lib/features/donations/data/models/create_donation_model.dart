/// Holds all data needed to call POST /api/donations.
///
/// Path 1 – Home Donate button:  bloodRequestId is null, hospitalId is required
/// Path 2 – Accept Request:      both bloodRequestId and hospitalId are set
class CreateDonationModel {
  final int? bloodRequestId;   // null when donating from Home
  final int hospitalId;
  final int age;
  final double weight;
  final bool hasTattoo;
  final DateTime? lastDonationDate; // null when neverDonated == true
  final bool medicalCondition;      // true = has chronic disease

  const CreateDonationModel({
    this.bloodRequestId,
    required this.hospitalId,
    required this.age,
    required this.weight,
    required this.hasTattoo,
    this.lastDonationDate,
    required this.medicalCondition,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'hospitalId': hospitalId,
      'age': age,
      'weight': weight,
      'hasTattoo': hasTattoo,
      // API expects a date string; "2000-01-01" is used when never donated
      'lastDonationDate': lastDonationDate != null
          ? '${lastDonationDate!.year.toString().padLeft(4, '0')}-'
              '${lastDonationDate!.month.toString().padLeft(2, '0')}-'
              '${lastDonationDate!.day.toString().padLeft(2, '0')}'
          : '2000-01-01',
      'medicalCondition': medicalCondition,
    };
    if (bloodRequestId != null) {
      map['bloodRequestId'] = bloodRequestId;
    }
    return map;
  }
}
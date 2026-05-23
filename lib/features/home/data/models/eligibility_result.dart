/// All data collected by CheckEligibilitySheet when the user is eligible.
/// Passed to the caller via the [onEligible] callback so the donation
/// API call can be made with the correct body.
class EligibilityResult {
  final int age;
  final double weight;
  final bool hasTattoo;
  final DateTime? lastDonationDate; // null when neverDonated
  final bool medicalCondition;      // true = has chronic disease
  final int hospitalId;
  final String hospitalName;

  const EligibilityResult({
    required this.age,
    required this.weight,
    required this.hasTattoo,
    this.lastDonationDate,
    required this.medicalCondition,
    required this.hospitalId,
    required this.hospitalName,
  });
}
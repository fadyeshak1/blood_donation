/// The API sends/receives gender and bloodType as integers.
/// These helpers convert between the app's string values and API integers.

class BloodTypeEnum {
  // API integer → display string
  static const Map<int, String> _toString = {
    1: 'A+',
    2: 'A-',
    3: 'B+',
    4: 'B-',
    5: 'AB+',
    6: 'AB-',
    7: 'O+',
    8: 'O-',
  };

  // Display string → API integer
  static const Map<String, int> _toInt = {
    'A+': 1,
    'A-': 2,
    'B+': 3,
    'B-': 4,
    'AB+': 5,
    'AB-': 6,
    'O+': 7,
    'O-': 8,
  };

  static String fromInt(int value) => _toString[value] ?? 'Unknown';
  static int toInt(String value) => _toInt[value] ?? 1;
}

class GenderEnum {
  // API integer → display string
  static const Map<int, String> _toString = {
    1: 'Male',
    2: 'Female',
  };

  // Display string → API integer
  static const Map<String, int> _toInt = {
    'Male': 1,
    'Female': 2,
  };

  static String fromInt(int value) => _toString[value] ?? 'Unknown';
  static int toInt(String value) => _toInt[value] ?? 1;
}
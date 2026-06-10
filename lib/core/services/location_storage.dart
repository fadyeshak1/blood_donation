import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's last known lat/lng locally.
/// Used as a fallback when the backend hasn't stored the user's location.
class LocationStorage {
  static const _keyLat = 'user_lat';
  static const _keyLng = 'user_lng';
  static const _keyAddress = 'user_address';

  LocationStorage._();
  static final LocationStorage instance = LocationStorage._();

  Future<void> saveLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLat, latitude);
    await prefs.setDouble(_keyLng, longitude);
    await prefs.setString(_keyAddress, address);
  }

  Future<({double lat, double lng, String address})?> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_keyLat);
    final lng = prefs.getDouble(_keyLng);
    final address = prefs.getString(_keyAddress) ?? '';
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng, address: address);
  }

  Future<bool> hasLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyLat);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLat);
    await prefs.remove(_keyLng);
    await prefs.remove(_keyAddress);
  }
}
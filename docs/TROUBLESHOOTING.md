# Troubleshooting Guide

Solutions to common issues encountered while developing or running the Blood Donation Smart Platform.

---

## Table of Contents

- [Build & Setup Issues](#build--setup-issues)
- [Runtime Crashes](#runtime-crashes)
- [API & Network Issues](#api--network-issues)
- [QR Code Issues](#qr-code-issues)
- [Location Issues](#location-issues)
- [State & UI Issues](#state--ui-issues)
- [Platform-Specific Issues](#platform-specific-issues)

---

## Build & Setup Issues

### `flutter pub get` fails

**Symptom:** Dependency resolution errors or network timeouts.

**Solutions:**
```bash
# Clear pub cache and retry
flutter pub cache repair
flutter pub get

# If behind a proxy
export PUB_HOSTED_URL=https://pub.dartlang.org
flutter pub get
```

---

### `flutter analyze` reports warnings

**Symptom:** Warnings about deprecated APIs, null safety, or unused imports.

**Solutions:**
- Remove unused imports at the top of each file
- Replace deprecated widget constructors (e.g., `withOpacity` → `withValues(alpha:)`)
- Run: `dart fix --apply` to auto-fix common issues

---

### Native splash not updating after changing `flutter_native_splash.yaml`

**Symptom:** Old splash screen still shows after editing the config.

**Solution:**
```bash
# Remove old generated files first
dart run flutter_native_splash:remove

# Regenerate
dart run flutter_native_splash:create

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

### Gradle build fails on Android

**Symptom:** Build errors mentioning Gradle, SDK version, or manifest issues.

**Solutions:**
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Clean the build
flutter clean
cd android && ./gradlew clean
cd ..
flutter run
```

For `minSdkVersion` errors, check `android/app/build.gradle`:
```gradle
defaultConfig {
    minSdkVersion 21  // mobile_scanner requires 21+
}
```

---

### CocoaPods error on iOS

**Symptom:** `CocoaPods could not find compatible versions for pod...`

**Solution:**
```bash
cd ios
pod repo update
pod install
cd ..
flutter run
```

---

## Runtime Crashes

### `type 'Null' is not a subtype of type 'String'`

**Cause:** A model is casting a JSON field as `String` but the API returned `null` or an integer.

**Fix:** Use null-safe casting in the model:
```dart
// ❌ Wrong
id: json['id'] as String,

// ✅ Correct
id: json['id']?.toString() ?? '',
name: json['name'] as String? ?? '',
count: (json['count'] as num?)?.toInt() ?? 0,
```

---

### `type 'int' is not a subtype of type 'String'`

**Cause:** API returns an integer ID where the model expects a String.

**Fix:**
```dart
id: json['id']?.toString() ?? '',
```

---

### `setState() called after dispose()`

**Cause:** An async operation completed after the widget was removed from the tree.

**Fix:** Always check `mounted` before calling `setState`:
```dart
if (!mounted) return;
setState(() { /* ... */ });
```

For timers:
```dart
_timer = Timer.periodic(Duration(seconds: 1), (t) {
  if (!mounted) { t.cancel(); return; }  // ← always check
  setState(() {});
});
```

---

### QR screen shows "expired" immediately on opening

**Cause:** The API returns `expiresAt` without a `Z` suffix. Dart parses it as local time, making Egyptian users (UTC+2) see a 2-hour-old timestamp.

**Fix:** Already applied in `DonationQrModel` and `RewardQrModel`:
```dart
static DateTime _parseUtc(String raw) {
  final normalised = (raw.endsWith('Z') || raw.contains('+')) ? raw : '${raw}Z';
  return DateTime.parse(normalised).toUtc();
}
```

If this appears again in a new model, apply the same pattern and always compare using:
```dart
DateTime.now().toUtc().isAfter(expiresAt)
```

---

### `DonationQrScreen` shows error after navigating back and reopening

**Cause:** Timer from the previous session was still running when `_fetchQr()` was called.

**Fix:** Already applied — `_fetchQr()` cancels the timer before starting:
```dart
Future<void> _fetchQr() async {
  _timer?.cancel();
  _timer = null;
  setState(() { _qr = null; _isExpired = false; _isLoading = true; });
  // ... fetch ...
}
```

---

## API & Network Issues

### All API calls return 401

**Cause:** Access token expired and refresh token is also expired or invalid.

**Fix:** Log out and log in again. The app should handle this automatically via `tryRefreshToken()`, but if both tokens are expired, a fresh login is required.

To force a fresh start in development:
```bash
# Clear app data on Android (emulator)
adb shell pm clear com.example.blood_donation
```

---

### `POST /api/donations/{id}/cancel` returns 400

**Cause:** Sending a JSON body with `Content-Type: application/json` causes the API to reject the request.

**Fix:** Already applied — the cancel endpoint uses raw `http.post` with no body:
```dart
final response = await http.post(
  uri,
  headers: {
    'Content-Length': '0',
    'Authorization': 'Bearer $token',
  },
);
```

---

### `GET /api/ai/match-requests` returns 400 with "location is not set"

**Cause:** The logged-in user's account has no latitude/longitude stored.

**Fix:**
1. Register a new account with location enabled (GPS step in registration)
2. Or use the emulator's location mock:
   - Extended Controls → Location → Set Lat: 30.0444, Long: 31.2357 → Send

---

### Hospital scan endpoints return 403

**Cause:** `POST /api/hospital/donations/scan` and `POST /api/hospital/rewards/scan` require a **Hospital** role. Regular users and admins don't have this role.

**Current status:** This is a backend limitation. The hospital scan flows work correctly in the app code but cannot be fully tested until Hospital-role accounts are provisioned by the backend team.

**Workaround:** None available for end-to-end testing. The donation QR display and reward QR display work correctly; only the hospital-side scan is blocked.

---

### Request status stays `Open` after a donor accepts

**Cause:** Backend bug — `POST /api/donations` with `bloodRequestId` does not auto-update the request status to `Fulfilled`.

**Current status:** Known backend issue. The app correctly sends the donation with `bloodRequestId`, but the backend doesn't propagate the status change.

---

### Reward description not showing in dialog

**Cause:** `GET /api/rewards` (list endpoint) does not include the `description` field.

**Fix:** Already applied — the redeem dialog uses `FutureBuilder` to call `GET /api/rewards/{id}` on demand when opened, which does include the description.

---

## QR Code Issues

### `torchState` not found / `TorchState` undefined

**Cause:** `mobile_scanner` v7 removed the `torchState` `ValueListenable` and `TorchState` enum.

**Fix:** Already applied — use local `bool _torchOn` state:
```dart
bool _torchOn = false;

// In AppBar action:
IconButton(
  icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
  onPressed: () {
    _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  },
)
```

---

### Camera permission denied on Android

**Symptom:** QR scanner shows black screen or permission error.

**Fix:** Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

The `mobile_scanner` package should add this automatically. If it doesn't, add it manually.

---

### QR code not scanning / camera not starting

**Fix:**
1. Ensure the app has camera permission (check device Settings → Apps → Blood Donation → Permissions)
2. Make sure only one `MobileScannerController` is active at a time
3. Call `_controller.dispose()` in the `dispose()` method
4. Don't create the controller inside `build()` — create it as a field

---

## Location Issues

### Geolocator returns null or throws on emulator

**Cause:** Android emulator has no real GPS — must mock a location.

**Fix:**
1. In Android Studio: Extended Controls (⋮) → Location
2. Set coordinates: Lat `30.0444`, Long `31.2357` (Cairo)
3. Click **Send**
4. Or use the Maps app in the emulator to set a location

---

### Geocoding returns empty/wrong address

**Cause:** Reverse geocoding uses an online service that may be slow or unavailable.

**Fix:** The app falls back to showing raw coordinates if geocoding fails:
```dart
try {
  final placemarks = await placemarkFromCoordinates(lat, lng)
      .timeout(const Duration(seconds: 10));
  // use address
} catch (_) {
  // fallback to "lat, lng" string
}
```

No code change needed — this is already implemented.

---

## State & UI Issues

### Profile doesn't update after editing

**Cause:** The edit screen pops without the profile screen reloading.

**Fix:** `EditProfileScreen` calls `profileProvider.updateProfile()` which updates the in-memory state via `_setState()`. The `ProfileScreen`'s `Consumer<ProfileProvider>` should rebuild automatically.

If not rebuilding, check that `EditProfileScreen` is wrapped with `ChangeNotifierProvider.value`:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<ProfileProvider>(),
      child: EditProfileScreen(user: provider.state.user!),
    ),
  ),
);
```

---

### "View All" button on home doesn't switch tabs

**Cause:** `HomeTab` is `const` (doesn't receive the callback) or the callback wasn't passed from `HomeScreen`.

**Fix:** `HomeTab` must NOT be `const` and must receive `onViewAllRequests`:
```dart
// In HomeScreen:
final screens = [
  HomeTab(onViewAllRequests: _goToRequests),  // ← not const
  const RequestsScreen(),
  // ...
];
```

---

### Rewards screen shows error after redeeming

**Cause:** `redeemRewardAndGetId()` returns null when the API doesn't return a redemption ID in the response body, and the fallback `getRedemptionHistory()` call also fails.

**Fix:** Check that the user has sufficient points. If points are sufficient and it still fails, check the console for the exact error message from `ApiClient.errorMessage(response)`.

---

## Platform-Specific Issues

### Android: App crashes on startup

**Common causes:**
1. Missing camera permission in manifest
2. `minSdkVersion` too low (must be 21+ for `mobile_scanner`)
3. ProGuard stripping necessary classes in release builds

**Fix for ProGuard:** Add to `android/app/proguard-rules.pro`:
```
-keep class io.flutter.** { *; }
-keep class com.google.mlkit.** { *; }
```

---

### iOS: App crashes when opening camera

**Fix:** Add camera usage description to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes for blood donation and reward confirmation.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses your location to show nearby blood requests.</string>
```

---

### iOS: `CocoaPods` install fails

```bash
cd ios
pod deintegrate
pod install
```

If that doesn't work:
```bash
sudo gem update --system
sudo gem install cocoapods
pod repo update
pod install
```

---

## Still Having Issues?

1. Check the [GitHub Issues](https://github.com/fadyeshak1/blood_donation/issues) for existing reports
2. Run `flutter doctor -v` and include the full output when reporting a bug
3. Open a new issue with the bug report template in [`CONTRIBUTING.md`](../CONTRIBUTING.md)
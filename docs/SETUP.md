# Development Setup Guide

This guide walks you through setting up the Blood Donation Smart Platform for local development from scratch.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Flutter Installation](#flutter-installation)
- [Project Setup](#project-setup)
- [Asset Setup](#asset-setup)
- [Native Splash Screen](#native-splash-screen)
- [Running the App](#running-the-app)
- [IDE Configuration](#ide-configuration)
- [Environment Notes](#environment-notes)
- [Building for Release](#building-for-release)

---

## Prerequisites

### Required

| Tool | Minimum Version | Download |
|---|---|---|
| Flutter SDK | 3.0.0 | https://flutter.dev/docs/get-started/install |
| Dart SDK | 3.0.0 | Bundled with Flutter |
| Git | Any | https://git-scm.com |
| Android Studio | 2023.x | https://developer.android.com/studio |

### For Android Development
- Android SDK (API 21+)
- Android Emulator or physical device with USB debugging

### For iOS Development (macOS only)
- Xcode 15+
- CocoaPods (`sudo gem install cocoapods`)
- iOS Simulator or physical device

---

## Flutter Installation

### macOS / Linux

```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/flutter/bin:$PATH"

# Verify installation
flutter doctor
```

### Windows

1. Download the Flutter SDK zip from https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your PATH environment variable
4. Run `flutter doctor` in a new terminal

### Verify Everything Works

```bash
flutter doctor -v
```

All items should show ✅. Common issues:
- **Android toolchain** — accept licenses: `flutter doctor --android-licenses`
- **Xcode** — install command line tools: `xcode-select --install`
- **VS Code** — install the Flutter extension

---

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/fadyeshak1/blood_donation.git
cd blood_donation
```

### 2. Install Dependencies

```bash
flutter pub get
```

This downloads all packages listed in `pubspec.yaml` including:
- `provider` for state management
- `mobile_scanner` for QR scanning
- `qr_flutter` for QR display
- `flutter_map` + `latlong2` for maps
- `geolocator` + `geocoding` for location

### 3. Verify Setup

```bash
flutter analyze
```

Should report zero issues.

---

## Asset Setup

The app requires these assets to be manually added (not included in the repository for size/licensing reasons):

### Splash Logo

Place the blood drop logo at:
```
assets/images/splash_logo.png
```

Requirements:
- Format: PNG with solid white background (NOT transparent)
- Size: 1024×1024px recommended
- Content: Blood drop shape with white medical cross

### Reward Images

Place reward images in:
```
assets/images/rewards/
├── medical_checkup.png        # Free Medical Checkup reward
├── pharmacy_discount.png      # Pharmacy Discount reward
├── blood_test.png             # Blood Test Package reward
├── hospital_priority.png      # Hospital Priority Service reward
└── health_package.png         # Full Health Package reward
```

Requirements:
- Format: PNG or JPG
- Recommended size: 800×600px (landscape)
- These images are shown as card headers in the Rewards screen

> 💡 **Tip:** If reward images are missing, the app gracefully falls back to themed icon illustrations — the app won't crash.

### Verify Asset Registration

Check `pubspec.yaml` includes:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/splash_logo.png
    - assets/images/rewards/
```

---

## Native Splash Screen

After adding `splash_logo.png`, generate the native splash:

```bash
dart run flutter_native_splash:create
```

This reads `flutter_native_splash.yaml` at the project root and generates:
- Android: XML drawables + launch screen layouts for all densities
- Android 12+: Adaptive icon splash using the new SplashScreen API
- iOS: LaunchScreen.storyboard + image assets at 1x/2x/3x

To regenerate after changing the logo or colors:
```bash
dart run flutter_native_splash:create
```

To remove the generated files:
```bash
dart run flutter_native_splash:remove
```

---

## Running the App

### On an Android Emulator

```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run the app
flutter run
```

### On a Physical Android Device

1. Enable **Developer Options** on the device
2. Enable **USB Debugging**
3. Connect via USB
4. Accept the debugging prompt on the device
5. Run:
```bash
flutter run
```

### On an iOS Simulator (macOS only)

```bash
# Open iOS Simulator
open -a Simulator

# Run the app
flutter run
```

### Hot Reload & Hot Restart

While the app is running:
- Press `r` in the terminal for hot reload (keeps state)
- Press `R` for hot restart (clears state)
- Press `q` to quit

---

## IDE Configuration

### VS Code

**Recommended extensions:**
- Flutter (by Dart Code)
- Dart (by Dart Code)
- Pubspec Assist
- Error Lens

**Useful VS Code tasks** (`.vscode/tasks.json`):
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Flutter: Get Packages",
      "type": "shell",
      "command": "flutter pub get"
    },
    {
      "label": "Flutter: Generate Splash",
      "type": "shell",
      "command": "dart run flutter_native_splash:create"
    },
    {
      "label": "Flutter: Analyze",
      "type": "shell",
      "command": "flutter analyze"
    }
  ]
}
```

### Android Studio / IntelliJ

1. Open the project folder (`File → Open`)
2. The Flutter plugin will auto-detect the project
3. Select a device from the device dropdown
4. Click the Run button (▶)

**Recommended plugins:**
- Flutter
- Dart

---

## Environment Notes

### Backend

The app connects to a shared development backend:
- **Base URL:** `https://blooddonationsys.runasp.net`
- **No local backend setup required** — the app works against the live server

### Test Accounts

| Role | Email | Password |
|---|---|---|
| Regular user | user@app.com | User@123456 |
| Admin | admin@app.com | Admin@123456 |

### Location Requirement

Some features require a location to be set on the user's account:
- AI-matched urgent requests on the home screen
- `GET /api/ai/match-requests` returns 400 if no location is set

To fix: register a new account with GPS location, or update an existing account's location via the profile API.

### Android Emulator Location

If testing on an emulator:
1. Open the emulator's **Extended Controls** (⋮ in the toolbar)
2. Go to **Location**
3. Set a location (e.g., Cairo: Lat 30.0444, Long 31.2357)
4. Click **Send**

---

## Building for Release

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS required)

```bash
flutter build ios --release
```

Then open Xcode to archive and distribute:
```bash
open ios/Runner.xcworkspace
```

### Build Flags

```bash
# With obfuscation (recommended for release)
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# Split APKs by ABI (smaller download size)
flutter build apk --release --split-per-abi
```

---

## Common Setup Issues

See [`docs/TROUBLESHOOTING.md`](TROUBLESHOOTING.md) for solutions to common setup problems.
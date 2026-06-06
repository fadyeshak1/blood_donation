# Changelog

All notable changes to the Blood Donation Smart Platform are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Push notifications for urgent blood requests
- AI chatbot connected to live backend API
- Dark mode support
- Multi-language support (Arabic / English)
- Hospital-role scan flows (pending backend Hospital role accounts)

---

## [1.0.0] — 2026-06

### 🎉 Initial Release — Graduation Project Submission

---

### ✨ Added

#### Authentication
- JWT login with access token + refresh token
- Silent token refresh on every 401 (no forced re-login)
- User registration with GPS location, blood type, national ID
- Forgot password via email reset token
- Reset password screen (token passed silently — never shown to user)
- Change password from profile settings

#### Onboarding
- 4-page animated onboarding shown once on first install
- Animated page dots, Skip/Next/Get Started controls
- Persists completion state in SharedPreferences

#### Native Splash Screen
- White background with blood drop logo
- Configured via `flutter_native_splash` for Android (all versions including API 31+) and iOS
- Transitions cleanly into the Flutter splash screen

#### Home
- Personalized welcome banner (first name only from dashboard API)
- Live stats grid (total donations + total points)
- Donation CTA card with 5-step eligibility check
- Urgent blood requests section (top 3 from AI matching)
- "View All" switches to Requests tab without navigation push

#### Blood Requests
- Browse requests using AI-powered matching endpoint
- Search by hospital name or location (600ms debounce, clear button)
- Filter by urgency (All / Urgent / Normal)
- Blood type filter removed (not supported server-side)
- Detailed request view showing patient/requester name, hospital, location, units, needed-by date
- Accept request flow → eligibility check → donation + QR navigation
- Create new blood request with map location picker (OpenStreetMap)
- Delete requests

#### Donations
- 5-step eligibility check: weight, tattoo, chronic disease, last donation, hospital
- QR code generation after donation (live countdown timer)
- UTC datetime fix: API returns datetimes without Z suffix — appended before parsing
- "Show QR Code" button on pending donations in history
- Cancel pending donations (requires `Content-Length: 0` header, no body)
- Donation history with expand/collapse (shows 2 initially)

#### Profile
- Full profile header with avatar placeholder
- Stats section (donations count + points)
- Personal information (phone, age, address, national ID)
- Edit profile (4 fields: name, phone, age, address)
- Blood pickup QR scanner for blood requesters
- Donation history section with show more/less
- Request history section with live status from API
- Request status descriptions (Open / Fulfilled / Completed / Closed)
- Logout with token cleanup

#### Rewards
- Points header showing available points + redeemed count
- Rewards grid (2-column) with real images
- Two-tier image assignment: keyword match → ID-based fallback
- Reward description fetched on demand (list endpoint doesn't include it)
- Redeem reward → navigate to QR screen with redemption ID
- Reward QR screen with Unused/Used status display
- Redemption history with QR icon button on every card

#### QR Code Systems
- **Donation QR**: donor shows QR to hospital staff; fetched fresh each time; expires in ~15 minutes
- **Pickup Scan**: requester scans hospital's QR; `POST /api/requests/pickup-scan` with `{qrToken}` only (no request ID in URL)
- **Reward QR**: user shows QR to redeem reward at hospital

#### Chat
- AI chatbot assistant with keyword-based responses
- Quick reply chips on first load
- Typing indicator animation
- Topics: eligibility, donation centers, blood type compatibility, history

---

### 🔧 Fixed

- **UTC timezone crash**: QR codes showed "expired" immediately on Egyptian devices (UTC+2) because API returns datetimes without Z suffix — fixed by appending Z before `DateTime.parse()`
- **Blood type format**: API sometimes returns `"A+Positive"` instead of `"A+"` — normalized via `_normaliseBloodType()`
- **Integer ID casting**: Reward/redemption IDs returned as `int` by API, cast as `String` in models → fixed with `.toString()`
- **Donation cancel 400 error**: `POST /api/donations/{id}/cancel` requires `Content-Length: 0` with no body; sending a JSON body causes 400 — fixed by using raw `http.post`
- **QR timer race condition**: Cancelling and restarting timers during `_fetchQr()` could flip `_isExpired = true` on fresh QR tokens — fixed by null-checking and ordered state resets
- **Welcome name showing full name**: Split `fullName` on space to show only first name in banner
- **Request status never updating**: Request history was populated from in-memory state only — fixed by fetching live from `GET /api/requests/my` on every profile load
- **`torchState` API removed**: `mobile_scanner` v7 removed `torchState` and `TorchState` enum — replaced with local `bool _torchOn` state variable
- **"Patient" showing as Unknown**: `GET /api/requests/{id}` returns `createdBy`, not `requesterName` — both field names now checked in `fromApiJson`
- **Reset token visible in UI**: Token was previously shown in a text field — removed from UI, passed silently via constructor
- **Search firing on every keystroke**: Added 600ms debounce to `SearchBarWidget`
- **Profile update failing**: `PUT /api/users/profile` requires all 4 fields always — ensured all are pre-filled from existing data

---

### 🗑 Removed

- Blood type filter from Requests screen (API does not filter by blood type in `match-requests`)
- Confirm Password field from Change Password screen (API doesn't require it)
- Reset Token field from Reset Password screen (handled silently)
- Scan QR button from Request Details screen (moved to Profile)
- Request ID dependency from pickup scan (API endpoint changed to no-ID path)

---

### 🏗 Architecture

- Clean Architecture with feature-first folder structure
- Provider state management with `ChangeNotifier`
- `ApiResult<T>` sealed class (`ApiSuccess` / `ApiFailure`) for error handling
- `ChangeNotifierProxyProvider` wires `RequestsProvider` → `ProfileProvider`
- `TokenStorage` singleton for all JWT read/write operations
- `ApiClient` with automatic silent token refresh on 401

---

## Links

- [Repository](https://github.com/fadyeshak1/blood_donation)
- [Backend API](https://blooddonationsys.runasp.net)
- [Issues](https://github.com/fadyeshak1/blood_donation/issues)
# Architecture Documentation

This document explains the architectural decisions, patterns, and data flow used throughout the Blood Donation Smart Platform.

---

## Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Layer Responsibilities](#layer-responsibilities)
- [State Management](#state-management)
- [Network Layer](#network-layer)
- [Data Flow Diagrams](#data-flow-diagrams)
- [Provider Dependency Graph](#provider-dependency-graph)
- [Key Design Decisions](#key-design-decisions)

---

## Overview

The app uses **Clean Architecture** organized by feature, not by layer. This means each feature (`auth`, `home`, `requests`, etc.) is a self-contained module with its own data, domain, and presentation layers. Shared infrastructure lives in `lib/core/`.

**Guiding principles:**
- UI knows nothing about the network — it only reads from providers
- Providers know nothing about widgets — they only expose state
- Repositories wrap datasources in `ApiResult<T>` — no raw exceptions reach the UI
- Models are dumb data containers — they parse JSON and nothing else

---

## Folder Structure

```
lib/
├── core/
│   ├── network/
│   │   ├── api_client.dart         # Single HTTP client, JWT lifecycle
│   │   ├── api_endpoints.dart      # All endpoint strings as constants
│   │   ├── api_enums.dart          # BloodType & Gender int ↔ string
│   │   └── api_result.dart         # Sealed ApiSuccess<T> | ApiFailure<T>
│   ├── services/
│   │   └── token_storage.dart      # SharedPreferences JWT singleton
│   ├── theme/
│   │   └── app_theme.dart          # Colors, ThemeData, ElevatedButton styles
│   ├── utils/
│   │   ├── constants.dart          # Blood types list, min/max values
│   │   ├── date_formatter.dart     # formatDate, formatTime, getRelativeTime
│   │   └── validators.dart         # Email, phone, name, password validators
│   └── widgets/
│       ├── custom_app_bar.dart     # AppBar with optional notification dot
│       ├── empty_state.dart        # Centred icon + title + subtitle
│       ├── error_view.dart         # Error icon + message + retry button
│       └── loading_indicator.dart  # Centred CircularProgressIndicator
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/auth_remote_datasource.dart
    │   │   ├── models/auth_model.dart
    │   │   └── repositories/auth_repository_impl.dart
    │   └── presentation/
    │       ├── providers/auth_provider.dart
    │       ├── providers/auth_state.dart
    │       └── screens/ (login, register, splash, onboarding, forgot/reset password)
    │
    ├── home/
    │   ├── data/
    │   │   ├── datasources/home_remote_datasource.dart
    │   │   ├── models/ (dashboard_stats, urgent_request, eligibility_result)
    │   │   └── repositories/home_repository_impl.dart
    │   └── presentation/
    │       ├── providers/home_provider.dart + home_state.dart
    │       ├── screens/ (home_screen, home_tab)
    │       └── widgets/ (welcome_banner, stats_grid, donation_cta_card,
    │                      urgent_requests_section, check_eligibility_sheet)
    │
    ├── requests/
    │   ├── data/
    │   │   ├── datasources/requests_remote_datasource.dart
    │   │   ├── models/ (blood_request_model, create_request_model)
    │   │   └── repositories/requests_repository_impl.dart
    │   └── presentation/
    │       ├── providers/requests_provider.dart + requests_state.dart
    │       ├── screens/ (requests_screen, request_details_screen,
    │       │             create_request_screen, map_location_picker_screen,
    │       │             pickup_scan_screen)
    │       └── widgets/ (request_card, filter_section, search_bar_widget)
    │
    ├── donations/
    │   ├── data/
    │   │   ├── datasources/donation_remote_datasource.dart
    │   │   └── models/ (create_donation_model, qr_model)
    │   └── presentation/
    │       └── donation_qr_screen.dart
    │
    ├── profile/
    │   ├── data/
    │   │   ├── datasources/profile_remote_datasource.dart
    │   │   ├── models/ (user_model, donation_history_model, request_history_model)
    │   │   └── repositories/profile_repository_impl.dart
    │   └── presentation/
    │       ├── providers/profile_provider.dart + profile_state.dart
    │       ├── screens/ (profile_screen, edit_profile_screen, qr_scanner_screen)
    │       └── widgets/ (profile_header, stats_section, info_section,
    │                      qr_code_section, donation_history_section,
    │                      request_history_section, settings_section)
    │
    ├── rewards/
    │   ├── data/
    │   │   ├── datasources/rewards_remote_datasource.dart
    │   │   ├── models/ (reward_model, redemption_model, reward_qr_model,
    │   │   │            user_points_model, redemption_history_model)
    │   │   └── repositories/rewards_repository_impl.dart
    │   └── presentation/
    │       ├── providers/rewards_provider.dart + rewards_state.dart
    │       ├── screens/ (rewards_screen, reward_qr_screen)
    │       └── widgets/ (points_header, rewards_grid, reward_card,
    │                      redemption_history_section)
    │
    └── chat/
        ├── data/
        │   ├── datasources/chat_remote_datasource.dart
        │   ├── models/chat_message_model.dart
        │   └── repositories/chat_repository_impl.dart
        └── presentation/
            ├── providers/chat_provider.dart + chat_state.dart
            ├── screens/chat_screen.dart
            └── widgets/ (chat_message_bubble, chat_input_field,
                           quick_reply_chips, typing_indicator)
```

---

## Layer Responsibilities

### 1. Remote DataSource
**Responsibility:** Make HTTP calls and return raw parsed data or throw exceptions.

```dart
class DonationRemoteDataSourceImpl implements DonationRemoteDataSource {
  Future<DonationHistoryModel> createDonation(CreateDonationModel d) async {
    final response = await apiClient.post(ApiEndpoints.createDonation, body: d.toJson());
    if (response.statusCode == 200) {
      return DonationHistoryModel.fromJson(ApiClient.decode(response));
    }
    throw Exception(ApiClient.errorMessage(response)); // ← throw here
  }
}
```

**Rules:**
- Never return null for collections — return empty list
- Never put business logic here — just HTTP + JSON parsing
- Always use `ApiClient.errorMessage(response)` for error messages

### 2. Repository
**Responsibility:** Wrap datasource calls in `ApiResult<T>` — no exceptions escape.

```dart
class DonationRepositoryImpl implements DonationRepository {
  Future<ApiResult<DonationHistoryModel>> createDonation(model) async {
    try {
      final result = await remoteDataSource.createDonation(model);
      return ApiSuccess(result); // ← success
    } catch (e) {
      return ApiFailure('Failed: ${e.toString()}'); // ← failure — never throws
    }
  }
}
```

**Rules:**
- Always catch exceptions and return `ApiFailure`
- Strip "Exception: " prefix from error messages for cleaner UI display
- Never add network logic — that belongs in the datasource

### 3. Model
**Responsibility:** Convert JSON to Dart objects safely.

```dart
factory RequestHistoryModel.fromJson(Map<String, dynamic> json) {
  return RequestHistoryModel(
    id: json['id']?.toString() ?? '',           // ← null-safe toString
    status: json['status'] as String? ?? 'Open', // ← typed null-safe cast
    bloodQuantity: (json['quantity'] as num?)?.toInt() ?? 1, // ← num to int
  );
}
```

**Rules:**
- Every cast must be null-safe: `as String?` not `as String`
- IDs from API may be `int` — always `.toString()`
- Integer quantities use `(json['field'] as num?)?.toInt() ?? default`
- UTC datetimes without Z — always append Z before parsing

### 4. Provider
**Responsibility:** Hold state, expose it to the UI, orchestrate operations.

```dart
class RewardsProvider extends ChangeNotifier {
  RewardsState _state = const RewardsState();
  RewardsState get state => _state;

  void _setState(RewardsState s) { _state = s; notifyListeners(); }

  Future<void> loadRewards(String userId) async {
    _setState(_state.copyWith(status: RewardsStatus.loading));
    final result = await repository.getRewards();
    switch (result) {
      case ApiSuccess(data: final d): _setState(_state.copyWith(rewards: d, status: RewardsStatus.success));
      case ApiFailure(message: final m): _setState(_state.copyWith(status: RewardsStatus.error, errorMessage: m));
    }
  }
}
```

**Rules:**
- State is immutable — always use `copyWith()` to create new instances
- Call `notifyListeners()` only via `_setState()`
- Never expose mutable internal state directly
- All async operations update loading state first

### 5. State Class
**Responsibility:** Immutable data container for a single feature's UI state.

```dart
class RewardsState {
  final RewardsStatus status;
  final List<RewardModel> rewards;
  // ...

  RewardsState copyWith({RewardsStatus? status, List<RewardModel>? rewards}) {
    return RewardsState(
      status: status ?? this.status,
      rewards: rewards ?? this.rewards,
    );
  }

  bool get isLoading => status == RewardsStatus.loading;
  bool get hasRewards => rewards.isNotEmpty;
}
```

---

## State Management

### Provider Registration (`main.dart`)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider(...)),
    ChangeNotifierProvider.value(value: profileProvider), // ← pre-built
    ChangeNotifierProvider(create: (_) => HomeProvider(...)),

    // ← ProxyProvider wires RequestsProvider to ProfileProvider
    ChangeNotifierProxyProvider<ProfileProvider, RequestsProvider>(
      create: (_) => RequestsProvider(requestsRepo),
      update: (_, prof, req) {
        req!.setProfileProvider(prof);
        return req;
      },
    ),

    ChangeNotifierProvider(create: (_) => ChatProvider(...)),
    ChangeNotifierProvider(create: (_) => RewardsProvider(...)),
  ],
)
```

### Cross-Provider Communication

`RequestsProvider` needs to update `ProfileProvider`'s history when:
- A new request is created → `profileProvider.addRequest()`
- A donation is accepted → `profileProvider.addDonationFromApi()`

This is done via a setter injected through `ChangeNotifierProxyProvider`. The `RequestsProvider` holds a nullable reference `ProfileProvider? _profileProvider` and checks for null before calling.

---

## Network Layer

### ApiClient

Single HTTP client that every datasource uses:

```dart
class ApiClient {
  static const String baseUrl = 'https://blooddonationsys.runasp.net';

  Future<http.Response> get(String path) => _executeWithRefresh(...);
  Future<http.Response> post(String path, {Map<String, dynamic>? body}) => ...;
  Future<http.Response> put(String path, {Map<String, dynamic>? body}) => ...;
  Future<http.Response> delete(String path) => ...;
}
```

### JWT Lifecycle

```
Request made
    ↓
_authHeaders() reads token from TokenStorage
    ↓
Request sent with Authorization: Bearer <token>
    ↓
Response 401?
    ├── No  → return response as-is
    └── Yes → tryRefreshToken()
                  ↓
              POST /api/auth/refresh-token
                  ↓
              Success? → save new tokens → retry original request
              Failure? → return 401 (caller handles logout)
```

### Donation Cancel — Special Case

`POST /api/donations/{id}/cancel` **cannot use ApiClient** because it requires:
- `Content-Length: 0` header
- Absolutely no body

Sending a body changes the `Content-Type` header, which the API rejects with 400. This endpoint uses raw `http.post` directly:

```dart
final response = await http.post(
  uri,
  headers: {'Content-Length': '0', 'Authorization': 'Bearer $token'},
);
```

---

## Data Flow Diagrams

### Standard API Call Flow

```
Widget (tap button)
    │
    ▼
context.read<Provider>().loadData()
    │
    ▼
Provider calls Repository
    │
    ▼
Repository calls RemoteDataSource
    │
    ▼
RemoteDataSource calls ApiClient.get(path)
    │
    ▼
ApiClient sends HTTP GET with JWT
    │
    ▼
API returns JSON response
    │
    ▼
ApiClient.decode(response) → Map<String, dynamic>
    │
    ▼
Model.fromJson(data) → typed Dart object
    │
    ▼
RemoteDataSource returns typed object
    │
    ▼
Repository wraps in ApiSuccess(data)
    │
    ▼
Provider updates state via copyWith()
    │
    ▼
notifyListeners()
    │
    ▼
Consumer<Provider> rebuilds
    │
    ▼
Widget shows updated UI
```

### QR Code Flow (Donation)

```
User taps "Donate"
    │
    ▼
CheckEligibilitySheet (5 steps)
    │
    ▼ eligible
DonationRemoteDataSource.createDonation()
POST /api/donations → {id, hospitalName, status: "Pending"}
    │
    ▼
ProfileProvider.addDonationFromApi(created)  ← optimistic UI update
    │
    ▼
Navigator.push(DonationQrScreen(donationId: created.id))
    │
    ▼
DonationQrScreen._fetchQr()
GET /api/donations/{id}/qr → {qrToken, expiresAt}
    │
    ▼
QrImageView(data: qrToken)  ← displays QR
    │
    ▼
Timer.periodic(1 second) updates countdown
    │
    ▼ hospital scans (hospital-side action)
POST /api/hospital/donations/scan {qrToken}
    │
    ▼
Donation status → Confirmed
Points awarded to donor
```

---

## Provider Dependency Graph

```
AuthProvider
    └── AuthRepository
            └── AuthRemoteDataSource

HomeProvider
    └── HomeRepository
            └── HomeRemoteDataSource

ProfileProvider ◄──────────────────────┐
    └── ProfileRepository              │
            └── ProfileRemoteDataSource│
                                       │ setProfileProvider()
RequestsProvider ──────────────────────┘
    └── RequestsRepository
            └── RequestsRemoteDataSource

RewardsProvider
    └── RewardsRepository
            └── RewardsRemoteDataSource

ChatProvider
    └── ChatRepository
            └── ChatRemoteDataSource
```

All providers share the same `ApiClient` instance (passed via `const ApiClient()` — it's stateless so sharing is safe).

---

## Key Design Decisions

### 1. Feature-First vs Layer-First

**Decision:** Feature-first folder structure  
**Reason:** All code for a feature (models, datasources, providers, screens) lives together. Changing a feature doesn't require navigating across the entire project. Cross-feature imports are intentional and visible.

### 2. Sealed ApiResult vs Exceptions

**Decision:** `ApiResult<T>` sealed class at the repository layer  
**Reason:** UI code should never `try-catch`. The `switch (result)` pattern forces the developer to handle both success and failure at compile time. Exceptions are implementation details that belong at the datasource layer.

### 3. Single ApiClient Instance

**Decision:** `const ApiClient()` — effectively a singleton via const constructor  
**Reason:** `ApiClient` is stateless — all state (tokens) lives in `TokenStorage`. Multiple instances are safe and cost nothing. Using `const` avoids the boilerplate of a manual singleton.

### 4. Immutable State + copyWith

**Decision:** All provider state classes are immutable with `copyWith()`  
**Reason:** Immutability prevents subtle bugs where part of the state is updated without notifying listeners. `copyWith()` makes every state transition explicit and traceable.

### 5. ProfileProvider + RequestsProvider Cross-Dependency

**Decision:** Inject `ProfileProvider` into `RequestsProvider` via `ChangeNotifierProxyProvider`  
**Reason:** When a user creates a request or accepts one, both the requests list AND the profile history need to update. Rather than having each re-fetch the full profile (expensive), the providers share references and update each other's in-memory state optimistically.

### 6. UTC Datetime Parsing

**Decision:** Always append Z if no timezone suffix before parsing  
**Reason:** The backend returns UTC datetimes without a Z suffix (e.g., `"2026-05-24T11:10:06"`). Dart's `DateTime.parse()` treats these as local time, making Egyptian users (UTC+2) see QR codes as expired 2 hours before they actually expire. The fix is applied at the model layer so it's centralised.

### 7. Live Request History on Profile Load

**Decision:** `loadUserProfile()` always fetches request history from `GET /api/requests/my`  
**Reason:** Request statuses change on the backend (donor accepts → Fulfilled, pickup confirmed → Completed) but the app had no way to know. Fetching live on every profile open ensures statuses are always current. Three parallel fetches (`Future.wait`) keep it performant.
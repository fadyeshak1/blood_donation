# Contributing to Blood Donation Smart Platform

Thank you for your interest in contributing! This document explains how to set up the development environment, submit changes, and follow the project's coding standards.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Requesting Features](#requesting-features)

---

## Code of Conduct

Be respectful, constructive, and collaborative. All contributors are expected to maintain a welcoming environment for everyone regardless of experience level, background, or identity.

---

## Getting Started

### 1. Fork & Clone

```bash
git clone https://github.com/YOUR_USERNAME/blood_donation.git
cd blood_donation
git remote add upstream https://github.com/fadyeshak1/blood_donation.git
```

### 2. Set Up the Environment

```bash
flutter pub get
dart run flutter_native_splash:create
```

### 3. Create a Branch

Always branch from `main`:

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### Branch Naming Conventions

| Type | Pattern | Example |
|---|---|---|
| Feature | `feature/description` | `feature/push-notifications` |
| Bug fix | `fix/description` | `fix/qr-timer-expiry` |
| Refactor | `refactor/description` | `refactor/profile-provider` |
| Docs | `docs/description` | `docs/api-reference` |
| Chore | `chore/description` | `chore/update-dependencies` |

---

## Development Workflow

### Project Architecture

This project uses **Clean Architecture** with Provider. Every feature lives in `lib/features/<feature_name>/` and has three layers:

```
feature/
├── data/
│   ├── datasources/    # API calls only — no business logic
│   ├── models/         # JSON ↔ Dart conversion
│   └── repositories/  # Wraps datasources in ApiResult<T>
└── presentation/
    ├── providers/      # ChangeNotifier — all state lives here
    ├── screens/        # StatefulWidget / StatelessWidget screens
    └── widgets/        # Reusable feature-specific widgets
```

### Adding a New Feature

1. Create the folder structure under `lib/features/new_feature/`
2. Define the model(s) in `data/models/`
3. Add endpoints to `lib/core/network/api_endpoints.dart`
4. Implement the datasource in `data/datasources/`
5. Wrap it in a repository in `data/repositories/`
6. Create the state class + provider in `presentation/providers/`
7. Build screens and widgets in `presentation/`
8. Register the provider in `main.dart`

### State Management Rules

- All state lives in **Providers** — screens never call APIs directly
- Screens read state via `Consumer<T>` or `context.watch<T>()`
- Screens trigger actions via `context.read<T>().method()`
- Providers return `ApiResult<T>` from repositories — never throw raw exceptions to UI

---

## Coding Standards

### Dart / Flutter

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before submitting — zero warnings required
- Use `const` constructors wherever possible
- Prefer named parameters for widget constructors with more than 2 parameters

### Naming

```dart
// Files: snake_case
donation_qr_screen.dart

// Classes: PascalCase
class DonationQrScreen extends StatefulWidget {}

// Variables & methods: camelCase
final String qrToken;
Future<void> fetchQrCode() async {}

// Constants: camelCase (or SCREAMING_SNAKE_CASE for true constants)
static const String baseUrl = 'https://...';
```

### API Models

Always use null-safe casting with defaults:
```dart
// ✅ Correct
id: json['id']?.toString() ?? '',
points: (json['points'] as num?)?.toInt() ?? 0,
name: json['name'] as String? ?? '',

// ❌ Wrong — will crash if API returns null or wrong type
id: json['id'] as String,
points: json['points'] as int,
```

### DateTime Parsing

The API returns UTC datetimes **without** a timezone suffix. Always use the UTC parser helper:
```dart
// ✅ Correct — handles missing Z suffix
static DateTime _parseUtc(String raw) {
  final normalised = (raw.endsWith('Z') || raw.contains('+')) ? raw : '${raw}Z';
  return DateTime.parse(normalised).toUtc();
}

// ✅ Always compare UTC vs UTC
bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);
```

### Error Handling

```dart
// In datasources — throw with descriptive message
if (response.statusCode == 200) {
  return parseResult(response);
}
throw Exception(ApiClient.errorMessage(response));

// In repositories — wrap in ApiResult
try {
  final data = await remoteDataSource.fetchSomething();
  return ApiSuccess(data);
} catch (e) {
  return ApiFailure('Failed to fetch: ${e.toString().replaceFirst("Exception: ", "")}');
}

// In providers — switch on result
switch (result) {
  case ApiSuccess(data: final d): // handle success
  case ApiFailure(message: final m): // handle error
}
```

### Widgets

- Keep `build()` methods clean — extract complex sub-widgets into private classes
- Prefer `StatelessWidget` over `StatefulWidget` unless state is truly local
- Never put API calls directly in `build()` — use `initState` + `WidgetsBinding.instance.addPostFrameCallback`

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<MyProvider>().loadData();
  });
}
```

---

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <description>

[optional body]
[optional footer]
```

### Types

| Type | Description |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `style` | Formatting, whitespace (no logic change) |
| `docs` | Documentation changes |
| `test` | Adding or updating tests |
| `chore` | Build process, dependencies |
| `perf` | Performance improvement |

### Examples

```
feat(rewards): add QR code display after redemption

fix(qr): handle missing Z suffix in UTC datetime from API

refactor(profile): extract donation card into separate widget

docs(readme): add screenshots section

chore(deps): update mobile_scanner to v7.2.0
```

---

## Pull Request Process

### Before Submitting

- [ ] Code compiles with zero errors
- [ ] `flutter analyze` passes with zero warnings
- [ ] Tested on a real device or emulator (Android + iOS if possible)
- [ ] Edge cases handled (empty states, loading states, error states)
- [ ] No hardcoded strings that should be constants
- [ ] API models use null-safe casting

### PR Template

When opening a PR, fill in:

```markdown
## What does this PR do?
Brief description of the change.

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Refactor
- [ ] Documentation

## How to test
Step-by-step instructions to test the change.

## Screenshots (if UI change)
Before / After screenshots.

## Checklist
- [ ] `flutter analyze` passes
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] No breaking changes
```

### Review Process

1. At least one approval is required before merging
2. Address all review comments before re-requesting review
3. Squash commits if the branch has many small fix-up commits
4. PRs are merged via **Squash and Merge**

---

## Reporting Bugs

Use [GitHub Issues](https://github.com/fadyeshak1/blood_donation/issues/new) with the following information:

```markdown
**Describe the bug**
A clear and concise description.

**Steps to reproduce**
1. Go to '...'
2. Tap on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Actual behavior**
What actually happened.

**Device info**
- Device: [e.g. Pixel 7]
- OS: [e.g. Android 14]
- Flutter version: [e.g. 3.22.0]
- App version: [e.g. 1.0.0]

**Screenshots / Logs**
If applicable, add screenshots or the error log.
```

---

## Requesting Features

Open a [Feature Request](https://github.com/fadyeshak1/blood_donation/issues/new) with:

```markdown
**Feature description**
What feature would you like to see?

**Problem it solves**
What problem does this feature address?

**Proposed solution**
How do you imagine this working?

**Alternatives considered**
Any alternative solutions you've thought of?
```

---

## Questions?

Open a [Discussion](https://github.com/fadyeshak1/blood_donation/discussions) for general questions that aren't bugs or feature requests.
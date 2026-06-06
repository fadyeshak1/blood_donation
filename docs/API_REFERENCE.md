# API Reference

**Base URL:** `https://blooddonationsys.runasp.net`

All authenticated requests require:
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

---

## Table of Contents

- [Authentication](#authentication)
- [User / Profile](#user--profile)
- [Blood Requests](#blood-requests)
- [Donations](#donations)
- [Rewards](#rewards)
- [Hospitals](#hospitals)
- [AI Matching](#ai-matching)
- [Hospital-Role Endpoints](#hospital-role-endpoints)
- [Enum Reference](#enum-reference)
- [Known Issues](#known-issues)

---

## Authentication

### POST /api/auth/login
Login with email and password.

**Request:**
```json
{
  "Email": "user@example.com",
  "Password": "Password@123"
}
```

**Response 200:**
```json
{
  "accessToken": "eyJhbGci...",
  "refreshToken": "dGhpcyBp...",
  "expiresIn": 900,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "Ahmed Hassan",
    "role": "User"
  }
}
```

---

### POST /api/auth/register
Register a new user account.

**Request:**
```json
{
  "fullName": "Ahmed Hassan",
  "email": "ahmed@example.com",
  "password": "Password@123",
  "confirmPassword": "Password@123",
  "phoneNumber": "01012345678",
  "age": 25,
  "gender": 1,
  "address": "Giza, Cairo",
  "nationalId": "12345678901234",
  "bloodType": 1,
  "latitude": 30.0444,
  "longitude": 31.2357
}
```

**Response 200:** Same shape as login.

---

### POST /api/auth/refresh-token
Exchange a refresh token for a new access token.

**Request:**
```json
{ "refreshToken": "dGhpcyBp..." }
```

**Response 200:**
```json
{
  "accessToken": "eyJhbGci...",
  "refreshToken": "bmV3cmVm..."
}
```

---

### POST /api/auth/logout
Invalidate the refresh token.

**Request:**
```json
{ "refreshToken": "dGhpcyBp..." }
```

**Response 200:** `{ "message": "Logged out successfully" }`

---

### POST /api/auth/forgot-password
Send a password reset token to the user's email.

**Request:**
```json
{ "email": "ahmed@example.com" }
```

**Response 200:**
```json
{
  "message": "Reset token sent",
  "resetToken": "abc123def456..."
}
```

> ⚠️ **Note:** The `resetToken` is in the response body — the app reads it and passes it silently to the reset screen. It is never shown to the user.

---

### POST /api/auth/reset-password
Set a new password using the reset token.

**Request:**
```json
{
  "email": "ahmed@example.com",
  "token": "abc123def456...",
  "newPassword": "NewPassword@123"
}
```

**Response 200:** `{ "message": "Password reset successfully" }`

---

### POST /api/auth/change-password
Change password while logged in.

**Request:**
```json
{
  "currentPassword": "OldPassword@123",
  "newPassword": "NewPassword@123"
}
```

**Response 200:** `{ "message": "Password changed successfully" }`

> ✅ **Note:** No `confirmNewPassword` field is required by the API.

---

## User / Profile

### GET /api/users/profile
Get the current user's profile.

**Response 200:**
```json
{
  "id": "uuid-string",
  "fullName": "Ahmed Hassan",
  "email": "ahmed@example.com",
  "phoneNumber": "01012345678",
  "age": 25,
  "gender": 1,
  "address": "Giza, Cairo",
  "nationalId": "12345678901234",
  "createdAt": "2026-01-01T00:00:00"
}
```

---

### PUT /api/users/profile
Update the current user's profile.

> ⚠️ **All 4 fields are required** even if only one changed.

**Request:**
```json
{
  "fullName": "Ahmed Hassan",
  "phoneNumber": "01012345678",
  "address": "New Address, Cairo",
  "age": 26
}
```

**Response 200:** `{ "message": "Profile updated" }`

---

### GET /api/users/dashboard
Get dashboard stats for the current user.

**Response 200:**
```json
{
  "fullName": "Ahmed Hassan",
  "totalDonations": 5,
  "totalPoints": 500
}
```

---

### GET /api/users/rewards
Get the current user's redemption history.

**Response 200:**
```json
[
  {
    "id": 3,
    "rewardTitle": "Free Medical Checkup",
    "pointsSpent": 50,
    "redeemedAt": "2026-05-24T10:00:00",
    "status": "Unused"
  }
]
```

> **Status values:** `"Unused"` | `"Used"`

---

## Blood Requests

### GET /api/ai/match-requests
Get blood requests matched to the current user (requires location set on account).

**Query Parameters:**
| Parameter | Type | Description |
|---|---|---|
| `Priority` | string | `"Emergency"` or `"Normal"` |
| `Search` | string | Matches hospital name or hospital address only |

**Response 200:**
```json
{
  "results": [
    {
      "requestId": 5,
      "requestedByUserId": "uuid",
      "requesterName": "Fady Eshak",
      "hospitalName": "Al Galaa Military Hospital",
      "hospitalAddress": "Cairo Governorate",
      "bloodType": "A+",
      "quantity": 2,
      "priority": "Emergency",
      "neededBy": "2026-05-26",
      "status": "Open",
      "distance": "Near you",
      "compatibilityNote": "مطابق تام"
    }
  ]
}
```

> ⚠️ **Note:** If the user has no location set, returns `{"message": "Your location is not set..."}` with status 400.

---

### GET /api/requests/{id}
Get a single request by ID.

**Response 200:**
```json
{
  "id": 5,
  "hospitalId": 6,
  "hospitalName": "Al Galaa Military Hospital",
  "bloodType": "A+Positive",
  "quantity": 2,
  "priority": "Emergency",
  "status": "Open",
  "hospitalLocation": "Cairo Governorate",
  "createdBy": "Fady Eshak",
  "createdAt": "2026-05-23T15:56:13",
  "neededBy": "2026-05-26T00:00:00"
}
```

> **Note:** This endpoint uses `createdBy` for the requester name, while `match-requests` uses `requesterName`.

---

### GET /api/requests/my
Get all requests created by the current user.

**Response 200:**
```json
[
  {
    "id": 2,
    "hospitalId": 2,
    "hospitalName": "Abu El Reesh Children Hospital",
    "bloodType": "A+Positive",
    "quantity": 2,
    "priority": "Emergency",
    "status": "Open",
    "hospitalLocation": "Nasr City, Cairo",
    "createdAt": "2026-05-20T18:34:12",
    "neededBy": "2026-05-30T00:00:00"
  }
]
```

**Status values:**
| Status | Meaning |
|---|---|
| `Open` | Active, waiting for a donor |
| `Fulfilled` | Donor confirmed — blood ready for pickup |
| `Completed` | Blood received by patient |
| `Closed` | Cancelled or expired |

---

### POST /api/requests
Create a new blood request.

**Request:**
```json
{
  "bloodType": 1,
  "quantity": 2,
  "hospitalId": 3,
  "hospitalLocation": "Nasr City, Cairo",
  "latitude": 30.0629,
  "longitude": 31.3394,
  "neededBy": "2026-06-30"
}
```

> **Note:** `bloodType` is sent as an integer (see [Enum Reference](#enum-reference)). `neededBy` is date-only: `"YYYY-MM-DD"`.

**Response 201:** `{ "message": "Request created successfully" }`

---

### DELETE /api/requests/{id}
Delete a blood request.

**Response 200/204:** Empty or `{ "message": "Deleted" }`

---

### POST /api/requests/pickup-scan
Confirm blood pickup (called by the blood requester at the hospital).

> ⚠️ **No request ID in the URL** — the backend identifies the request from the QR token.

**Request:**
```json
{ "qrToken": "abc123..." }
```

**Response 200:** `{ "message": "Pickup confirmed" }`

---

## Donations

### POST /api/donations
Create a new donation.

**Request:**
```json
{
  "hospitalId": 2,
  "age": 25,
  "weight": 70,
  "hasTattoo": false,
  "lastDonationDate": "2025-01-01",
  "medicalCondition": false,
  "bloodRequestId": 5
}
```

> `bloodRequestId` is optional — omit when donating from the Home screen without a specific request.

**Response 200:**
```json
{
  "id": 28,
  "bloodRequestId": 5,
  "hospitalId": 2,
  "hospitalName": "Abu El Reesh Children Hospital",
  "bloodType": "A+Positive",
  "status": "Pending",
  "donorData": {
    "age": 25,
    "weight": 70,
    "hasTattoo": false,
    "lastDonationDate": "2025-01-01T00:00:00",
    "medicalCondition": false
  },
  "createdAt": "2026-05-28T18:25:16Z",
  "message": "Donation created successfully"
}
```

---

### GET /api/donations/my
Get all donations for the current user.

**Response 200:**
```json
[
  {
    "id": 4,
    "hospitalName": "Cairo University Hospital",
    "bloodType": "A+Positive",
    "status": "Confirmed",
    "createdAt": "2026-05-20T15:00:00"
  }
]
```

**Status values:** `Pending` | `Confirmed` | `Cancelled` | `Rejected` | `Withdrawn`

---

### POST /api/donations/{id}/cancel
Cancel a pending donation.

> ⚠️ **Special requirement:** Must send `Content-Length: 0` with NO body. Sending a body causes a 400 error.

**Headers required:**
```
Content-Length: 0
Authorization: Bearer <token>
```

**Response 200/204:** Empty

---

### GET /api/donations/{id}/qr
Generate a QR code for a pending donation.

> Only works for donations with status `Pending`.

**Response 200:**
```json
{
  "qrToken": "4b0d925c1e0f4141990472eb84d13bee...",
  "qrType": "Donation",
  "referenceId": 1,
  "expiresAt": "2026-05-24T11:10:06.23706"
}
```

> ⚠️ `expiresAt` is UTC but has **no timezone suffix** (no `Z`). The app appends `Z` before parsing.

---

## Rewards

### GET /api/rewards
List all available rewards.

> ⚠️ Does **not** include the `description` field.

**Response 200:**
```json
[
  {
    "id": 1,
    "title": "Free Medical Checkup",
    "pointsRequired": 50,
    "isAvailable": true
  }
]
```

---

### GET /api/rewards/{id}
Get a single reward including description.

**Response 200:**
```json
{
  "id": 1,
  "title": "Free Medical Checkup",
  "description": "Comprehensive health checkup at partner clinics including blood pressure, BMI, and basic blood tests.",
  "pointsRequired": 50,
  "isAvailable": true
}
```

---

### POST /api/rewards/redeem
Redeem a reward using points.

**Request:**
```json
{ "rewardId": 1 }
```

> `rewardId` must be an **integer** not a string.

**Response 200:**
```json
{
  "id": 7,
  "message": "Reward redeemed successfully"
}
```

> The `id` in the response is the redemption ID, used to fetch the QR code.

---

### GET /api/rewards/redemptions/{id}/qr
Generate a QR code for a specific redemption.

**Response 200:**
```json
{
  "qrToken": "rewqr_abc123def456...",
  "qrType": "Reward",
  "expiresAt": "2026-05-24T12:00:00"
}
```

---

## Hospitals

### GET /api/hospitals/dropdown
Get all hospitals for selection dropdowns.

**Response 200:**
```json
[
  { "id": 1, "name": "Cairo University Hospital" },
  { "id": 2, "name": "Abu El Reesh Children Hospital" }
]
```

---

## AI Matching

### GET /api/ai/match-requests
*(See [Blood Requests](#blood-requests) section above)*

The AI matching endpoint ranks blood requests by compatibility with the current donor's blood type and geographic proximity. The `compatibilityNote` field contains an Arabic compatibility description.

---

## Hospital-Role Endpoints

These endpoints require a **Hospital** role which is not available through regular user or admin accounts. They are implemented in the app for future use when hospital accounts are provisioned.

### POST /api/hospital/donations/scan
Confirm a blood donation by scanning the donor's QR code.

**Request:**
```json
{ "qrToken": "4b0d925c1e0f4141..." }
```

**Response 200:** Marks donation as Confirmed, awards points to donor.  
**Response 403:** Hospital role required.

---

### POST /api/hospital/rewards/scan
Mark a reward as Used by scanning the user's QR code.

**Request:**
```json
{ "qrToken": "rewqr_abc123..." }
```

**Response 200:** Marks redemption status as Used.  
**Response 403:** Hospital role required.

---

### GET /api/hospital/donations/{id}/pickup-qr
Generate a QR code for blood pickup (shown to blood requester).

**Response 200:** QR token for the requester to scan.  
**Response 403:** Hospital role required.

---

## Enum Reference

### Blood Type

| API Integer | Display String |
|---|---|
| 1 | A+ |
| 2 | A- |
| 3 | B+ |
| 4 | B- |
| 5 | AB+ |
| 6 | AB- |
| 7 | O+ |
| 8 | O- |

Blood type is sent as an integer in POST requests (`bloodType: 1`) but returned as a string in GET responses (`"bloodType": "A+Positive"`). The app normalises `"A+Positive"` → `"A+"` via `_normaliseBloodType()`.

### Gender

| API Integer | Display String |
|---|---|
| 1 | Male |
| 2 | Female |

### Request Status

| Value | Description |
|---|---|
| `Open` | Request is active, waiting for a donor |
| `Fulfilled` | A donor confirmed — blood is ready for pickup |
| `Completed` | Blood received by the patient |
| `Closed` | Request was cancelled or expired |

### Donation Status

| Value | Description |
|---|---|
| `Pending` | Created but not yet scanned by hospital |
| `Confirmed` | Hospital scanned — donation confirmed |
| `Cancelled` | Cancelled by the donor |
| `Rejected` | Rejected by hospital |
| `Withdrawn` | Withdrawn by the system |

### Redemption Status

| Value | Description |
|---|---|
| `Unused` | Redeemed but not yet used at hospital |
| `Used` | Hospital scanned — reward has been used |

---

## Known Issues

| Endpoint | Issue |
|---|---|
| `POST /api/donations` with `bloodRequestId` | Does NOT auto-update the request status from `Open` to `Fulfilled` — backend bug |
| `POST /api/hospital/donations/scan` | Returns 403 — no hospital accounts available |
| `POST /api/hospital/rewards/scan` | Returns 403 — no hospital accounts available |
| `GET /api/hospital/donations/{id}/pickup-qr` | Returns 403 — no hospital accounts available |
| All datetime fields | Missing timezone `Z` suffix — must append Z before parsing |
| `GET /api/rewards` | Missing `description` field — fetch individually via `/api/rewards/{id}` |
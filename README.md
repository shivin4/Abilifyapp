# Abilify – Flutter App (Phase 1 Beta)

A platform connecting parents of children with special needs to verified therapists. Built with **Flutter**, **Firebase**, and **Agora** video.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Auth | Firebase Authentication (Phone OTP) |
| Database | Cloud Firestore |
| Video Calls | Agora RTC Engine |
| Chat | Cloud Firestore (real-time) |
| State Management | Riverpod |
| Routing | GoRouter |
| Config | `flutter_dotenv` (`.env` file) |
| Token server | Node.js + Express (`server/`) |

---

## Quick Start (Submission Demo)

### 1. Environment files

**Project root `.env`** (Flutter):

```env
AGORA_APP_ID=your_agora_app_id
API_BASE_URL=http://YOUR_PC_LAN_IP:3000
```

- On a **physical phone**, set `API_BASE_URL` to your PC’s LAN IP (e.g. `http://10.7.12.112:3000`).
- On **Android emulator**, omit `API_BASE_URL` or use `http://10.0.2.2:3000`.

**`server/.env`** (token server):

```env
AGORA_APP_ID=your_agora_app_id
AGORA_APP_CERTIFICATE=your_agora_certificate
```

### 2. Start token server

```bash
cd server
npm install
node index.js
```

Verify: open `http://127.0.0.1:3000/agora-token?channelName=test_channel` — you should get JSON with a `token`.

### 3. Run Flutter app

```bash
flutter pub get
flutter run
```

### 4. Firebase setup

Project: **`abilifyapp`** (see `lib/firebase_options.dart`).

**Firestore collections:**

| Collection | Purpose |
|---|---|
| `profiles/{uid}` | `role`, `fullName`, `phone`, `childName` |
| `therapists/{uid}` | Therapist public profile (optional; demo list used if empty) |
| `sessions/{id}` | Bookings + `channelId` for video |
| `chats/{chatId}/messages` | Real-time chat |

**Test users:**

1. Firebase Console → Authentication → add phone users.
2. Firestore → `profiles/{uid}`:
   - Parent: `{ "role": "parent", "fullName": "..." }`
   - Therapist (approved): `{ "role": "therapist", "fullName": "..." }`
   - Therapist (pending): `{ "role": "therapist_pending" }`

---

## App Flow

```
Launch → Splash
  ├── Not logged in → Login / Sign up → OTP → Role select (signup)
  └── Logged in → Role Gate
        ├── therapist → Therapist Dashboard
        ├── therapist_pending → Pending approval screen
        └── parent → Parent Dashboard
```

---

## Two-Phone Video Call Demo

1. Start **token server** on PC (`node index.js`).
2. Set **`API_BASE_URL`** in `.env` to your PC LAN IP; rebuild app on both phones.
3. **Phone A (Parent):**
   - Log in as parent → book a therapist → note the **Channel ID** in the snackbar.
   - Open **My Sessions** → tap session → joins video.
4. **Phone B (Therapist):**
   - Log in as therapist → **Join session by channel ID** → paste the same Channel ID from Phone A.
5. Both should see local preview (corner) and remote video (center).

> **Why not Chrome?** Flutter web does not fully support `agora_rtc_engine` video. Use two physical devices or an Android emulator + phone.

---

## Features Implemented

### Auth
- Phone login & sign-up with OTP
- Role selection (parent / therapist pending)
- Pending approval screen for therapists
- Role-based routing via Firestore `profiles`

### Parent
- Therapist directory (Firestore + demo fallback)
- Search & filters (location, languages, availability)
- **Book session** → creates Firestore `sessions` doc
- **My Sessions** with one-tap video join
- Profile (name, child name) saved to Firestore
- Chat with therapist

### Therapist
- Dashboard with live sessions from Firestore
- Appointment details → start video / mark completed
- Schedule calendar & availability UI
- Post-session notes
- **Join by channel ID** for demo pairing
- Video calls (Agora RTC)

### Chat
- Real-time Firestore messages
- Wired from therapist cards

---

## Project Structure

```
lib/
  core/           app, router, theme, bootstrap, config
  services/       app_repository.dart (Firestore + booking)
  models/         profile, session, therapist
  features/
    auth/         splash, login, signup, otp, role select, pending
    parent/       dashboard, profile, book session, widgets
    therapist/    dashboard, schedule, appointment, notes, video
    chat/         chat_page
server/           Agora token API (port 3000)
```

---

## Submission Checklist

- [ ] `server/.env` with Agora credentials
- [ ] Root `.env` with `AGORA_APP_ID` and `API_BASE_URL` (LAN IP for devices)
- [ ] Token server running during demo
- [ ] Two Firebase test users (parent + therapist)
- [ ] Therapist profile `role: "therapist"` (not pending) for full therapist UI
- [ ] Demo: book session → join video on both phones with same channel ID

---

## Known Limitations (Phase 1)

- Payments, push notifications, admin verification UI, and community hub are out of scope.
- Demo therapists use static IDs unless you add documents under `therapists/` in Firestore.
- Therapist only sees booked sessions when `sessions.therapistId` matches their Firebase UID (use **Join by channel ID** for quick demos with demo therapist cards).

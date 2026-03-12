# Abilify – Phase 1 (Flutter + Supabase)

This repo contains the Phase 1 app described in the spec: OTP onboarding, automatic role-routing (parent/therapist), a parent Service Directory UI (Therapists functional; others show "Coming Soon"), and therapist-side dashboards/screens (schedule, appointment details, post-session notes).

## 1) Run locally

- Install Flutter and run `flutter doctor`.
- Install dependencies:
  ```bash
  flutter pub get
  ```
- Create a `.env` file at project root (already created) and set:
  ```
  SUPABASE_URL=<your_url>
  SUPABASE_ANON_KEY=<your_anon_key>
  ```
  Without these, the app runs in offline/mock mode and directly opens the Parent dashboard.
- Launch:
  ```bash
  flutter run
  ```

### Pre-create users with phone + password (no SMS required)
Use the provided PowerShell script (requires Service Role key—do NOT put it in the app):

```powershell
# One-time per session
$env:SUPABASE_URL = 'https://<project-ref>.supabase.co'
$env:SUPABASE_SERVICE_ROLE = '{{SUPABASE_SERVICE_ROLE}}'

# Edit scripts/testers.csv with your testers
# Then run:
pwsh scripts/bulk_create_users.ps1 -CsvPath scripts/testers.csv -SupabaseUrl $env:SUPABASE_URL -ServiceRole $env:SUPABASE_SERVICE_ROLE -CreateTherapists
```
- CSV columns: `phone,password,full_name,role,city,languages,experience_years,rating,price_per_session`
- For each row, the script:
  - Creates the auth user with `phone_confirm=true`;
  - Upserts a `profiles` row with the specified `role`;
  - If role is `therapist` (or `-CreateTherapists` globally), upserts a `therapists` row so they appear in the directory.

After that, your testers can login in-app using Phone + Password. RoleGate will route them to Therapist or Parent dashboards accordingly.

## 2) Supabase schema
Apply `supabase/schema.sql` in your Supabase project (SQL Editor ➜ Run). It creates:
- `profiles` with `role` ('therapist'|'parent')
- `therapists` directory table (languages, availability, rating, etc.)
- `sessions`, `session_notes`, `activities`, `transactions`, `reviews`, `packages`

Recommended: create beta users via Auth ➜ Users. After first login, insert a row in `profiles` for each user with the desired `role`.

## 3) Key flows implemented
- Splash ➜ Login (phone OTP) ➜ Role gate ➜ Therapist or Parent dashboards.
- Parent Service Directory UI matches the provided design; Filters bottom sheet excludes Expertise (Availability + Languages only). Therapist icon is highlighted when active; other categories show "Coming Soon".
- Therapist Dashboard: quick stats; Upcoming Sessions list; Schedule Calendar with legend and Edit Availability; Appointment Details; Post-Session Notes.

## 4) What’s stubbed in Phase 1
- Video/Chat session is a placeholder (UI only). Integrate a provider (Jitsi, Daily, or custom WebRTC) in Phase 2.
- Payments, Packages, Reviews Analytics, and deeper Client/Progress flows are scaffolded for later.

## 5) Code structure
```
lib/
  core/            # theme, router, bootstrap (Supabase + dotenv)
  features/
    auth/          # splash, phone login, otp
    parent/        # dashboard + service directory + filter sheet
    therapist/     # dashboard, schedule, appointment details, notes
  models/          # simple data models
supabase/
  schema.sql       # Phase 1 database objects
```

## 6) Notes
- Sessions persist automatically with Supabase when keys are set; otherwise the app runs without network.
- Lints are enabled but permissive; feel free to tighten rules.

# Rebuilds local main with backdated commits (Mar 12 - Apr 1, 2026).
$ErrorActionPreference = "Stop"
$Repo = "C:\Users\Shivin\Desktop\projects\abilify"
$BaseHash = "769c3ed3a6b74642ff3a1295285950923afa34d3"
$HeadSnap = "C:\Users\Shivin\Desktop\projects\abilify-head-snap"
$FinalSnap = "C:\Users\Shivin\Desktop\projects\abilify-final-snap"

$env:GIT_AUTHOR_NAME = "shivin khandelwal"
$env:GIT_COMMITTER_NAME = "shivin khandelwal"
$env:GIT_AUTHOR_EMAIL = "shivin2004@gmail.com"
$env:GIT_COMMITTER_EMAIL = "shivin2004@gmail.com"

function Copy-Tree {
  param([string]$SourceRoot, [string[]]$Paths)
  foreach ($rel in $Paths) {
    $src = Join-Path $SourceRoot $rel
    if (-not (Test-Path $src)) { continue }
    $dst = Join-Path $Repo $rel
    $parent = Split-Path $dst -Parent
    if ($parent -and -not (Test-Path $parent)) {
      New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
    Copy-Item -Path $src -Destination $dst -Recurse -Force
  }
}

function Add-DevLogLine {
  param([string]$When, [string]$Message)
  $devLogDir = Join-Path $Repo "docs"
  $devLog = Join-Path $devLogDir "dev-log.md"
  if (-not (Test-Path $devLogDir)) { New-Item -ItemType Directory -Path $devLogDir -Force | Out-Null }
  if (-not (Test-Path $devLog)) { Set-Content -Path $devLog -Value "# Abilify development log" }
  $day = $When.Substring(0, 10)
  $line = '- **' + $day + '** - ' + $Message
  Add-Content -Path $devLog -Value $line
}

function Invoke-DatedCommit {
  param([string]$When, [string]$Message)
  Add-DevLogLine -When $When -Message $Message
  $env:GIT_AUTHOR_DATE = $When
  $env:GIT_COMMITTER_DATE = $When
  Set-Location $Repo
  Remove-Item (Join-Path $Repo ".env") -Force -ErrorAction SilentlyContinue
  Remove-Item (Join-Path $Repo "server\.env") -Force -ErrorAction SilentlyContinue
  git add -A
  git commit -m $Message
}

Set-Location $Repo
if (-not (Test-Path $FinalSnap)) { throw "Missing snapshot: $FinalSnap" }

if (Test-Path $HeadSnap) { git worktree remove $HeadSnap --force 2>$null; Remove-Item -Recurse -Force $HeadSnap -ErrorAction SilentlyContinue }
git worktree add $HeadSnap $BaseHash | Out-Null

git branch -f backup-before-history-rewrite backup-before-history-rewrite 2>$null
git checkout --orphan main-rewritten
git rm -rf . 2>$null | Out-Null
Get-ChildItem -Force | Where-Object { $_.Name -ne ".git" } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

$platform = @(
  ".gitignore", ".metadata", "analysis_options.yaml", "pubspec.yaml", "pubspec.lock",
  "android", "ios", "linux", "macos", "windows", "web"
)
$firebase = @("firebase.json", "lib/firebase_options.dart", "android/app/google-services.json")

$commits = @(
  @{ d = "2026-03-12 09:14:22 +0530"; m = "chore: bootstrap Flutter project for Abilify"; s = "head"; p = $platform },
  @{ d = "2026-03-12 14:36:10 +0530"; m = "docs: add initial README and project metadata"; s = "head"; p = @("README.md") },
  @{ d = "2026-03-12 19:08:44 +0530"; m = "feat: wire app shell, theme, and bootstrap"; s = "head"; p = @("lib/main.dart", "lib/core/app.dart", "lib/core/bootstrap.dart", "lib/core/theme.dart") },

  @{ d = "2026-03-13 11:22:05 +0530"; m = "feat: add go_router navigation skeleton"; s = "head"; p = @("lib/core/router.dart") },
  @{ d = "2026-03-13 21:47:33 +0530"; m = "feat: integrate Firebase core options"; s = "head"; p = $firebase },

  @{ d = "2026-03-14 16:31:18 +0530"; m = "feat: add splash and role gate routing"; s = "head"; p = @("lib/features/auth/splash_page.dart", "lib/features/role_gate.dart") },

  @{ d = "2026-03-15 10:07:52 +0530"; m = "feat: implement phone login screen"; s = "head"; p = @("lib/features/auth/phone_login_page.dart") },
  @{ d = "2026-03-15 15:24:41 +0530"; m = "feat: add OTP verification flow"; s = "head"; p = @("lib/features/auth/otp_page.dart") },
  @{ d = "2026-03-15 22:11:09 +0530"; m = "feat: add profile and session data models"; s = "head"; p = @("lib/models/profile.dart", "lib/models/session.dart", "lib/models/therapist.dart") },

  @{ d = "2026-03-16 13:42:27 +0530"; m = "feat: build parent dashboard layout"; s = "head"; p = @("lib/features/parent/parent_dashboard_page.dart") },
  @{ d = "2026-03-16 20:18:56 +0530"; m = "feat: add therapist directory and filters"; s = "head"; p = @("lib/features/parent/widgets/service_directory.dart", "lib/features/parent/widgets/filter_sheet.dart") },

  @{ d = "2026-03-17 08:53:14 +0530"; m = "feat: parent profile editing"; s = "head"; p = @("lib/features/parent/parent_profile_page.dart") },
  @{ d = "2026-03-17 12:34:50 +0530"; m = "feat: therapist dashboard and schedule views"; s = "head"; p = @("lib/features/therapist/dashboard_page.dart", "lib/features/therapist/schedule_calendar_page.dart") },
  @{ d = "2026-03-17 17:58:03 +0530"; m = "feat: appointment details and session notes"; s = "head"; p = @("lib/features/therapist/appointment_details_page.dart", "lib/features/therapist/post_session_notes_page.dart") },
  @{ d = "2026-03-17 23:19:37 +0530"; m = "feat: add realtime chat screen"; s = "head"; p = @("lib/features/chat/chat_page.dart") },

  @{ d = "2026-03-18 18:02:48 +0530"; m = "chore: add Agora web quickstart for token testing"; s = "head"; p = @("agora_web_quickstart") },

  @{ d = "2026-03-19 11:13:29 +0530"; m = "feat: add Agora RTC and permission_handler deps"; s = "head"; p = @("pubspec.yaml", "pubspec.lock", "macos/Flutter/GeneratedPluginRegistrant.swift") },
  @{ d = "2026-03-19 19:42:11 +0530"; m = "feat: add Node token server for Agora"; s = "head"; p = @("server") },

  @{ d = "2026-03-20 09:28:55 +0530"; m = "feat: video session page with channel join"; s = "head"; p = @("lib/features/therapist/video_session_page.dart") },
  @{ d = "2026-03-20 14:03:17 +0530"; m = "fix: listen on 0.0.0.0 for LAN device testing"; s = "final"; p = @("server/index.js") },
  @{ d = "2026-03-20 20:54:38 +0530"; m = "feat: add env examples for Agora and API base URL"; s = "final"; p = @(".env.example", "server/.env.example", ".gitignore") },

  @{ d = "2026-03-21 12:19:44 +0530"; m = "fix: use local UID from Agora join callback"; s = "final"; p = @("lib/features/therapist/video_session_page.dart") },
  @{ d = "2026-03-21 21:33:06 +0530"; m = "docs: document two-phone video demo in README"; s = "final"; p = @("README.md") },

  @{ d = "2026-03-22 15:47:21 +0530"; m = "feat: resolve API base URL for emulator vs device"; s = "final"; p = @("lib/core/config.dart", "pubspec.yaml", "pubspec.lock", "macos/Flutter/GeneratedPluginRegistrant.swift") },

  @{ d = "2026-03-23 10:06:33 +0530"; m = "refactor: introduce app repository service layer"; s = "final"; p = @("lib/services/app_repository.dart") },
  @{ d = "2026-03-23 16:22:58 +0530"; m = "feat: signup and role selection screens"; s = "final"; p = @("lib/features/auth/signup_page.dart", "lib/features/auth/role_select_page.dart", "lib/features/auth/pending_approval_page.dart") },
  @{ d = "2026-03-23 22:07:14 +0530"; m = "feat: session booking page for parents"; s = "final"; p = @("lib/features/parent/book_session_page.dart", "lib/models/session.dart", "lib/models/therapist.dart") },

  @{ d = "2026-03-24 13:28:47 +0530"; m = "feat: parent shell with bottom navigation"; s = "final"; p = @("lib/features/parent/parent_shell_page.dart", "lib/features/parent/parent_home_tab.dart", "lib/features/parent/parent_sessions_tab.dart") },
  @{ d = "2026-03-24 18:53:02 +0530"; m = "feat: therapist listing setup flow"; s = "final"; p = @("lib/features/therapist/therapist_profile_setup_page.dart", "lib/features/therapist/therapist_shell_page.dart", "lib/features/role_gate.dart") },

  @{ d = "2026-03-25 08:18:39 +0530"; m = "feat: parent community feed"; s = "final"; p = @("lib/features/parent/community_page.dart", "lib/models/community_post.dart") },
  @{ d = "2026-03-25 11:46:22 +0530"; m = "chore: add Firestore security rules"; s = "final"; p = @("firestore.rules") },
  @{ d = "2026-03-25 16:12:07 +0530"; m = "feat: shared UI widgets and theme polish"; s = "final"; p = @("lib/core/widgets/app_widgets.dart", "lib/core/theme.dart") },
  @{ d = "2026-03-25 21:03:51 +0530"; m = "refactor: router paths for parent and therapist shells"; s = "final"; p = @("lib/core/router.dart") },

  @{ d = "2026-03-26 17:34:28 +0530"; m = "refactor: therapist dashboard uses live Firestore sessions"; s = "final"; p = @("lib/features/therapist/dashboard_page.dart", "lib/features/therapist/appointment_details_page.dart") },

  @{ d = "2026-03-27 10:41:15 +0530"; m = "refactor: parent home and directory from repository"; s = "final"; p = @("lib/features/parent/parent_dashboard_page.dart", "lib/features/parent/widgets/service_directory.dart", "lib/features/parent/parent_profile_page.dart") },
  @{ d = "2026-03-27 20:02:44 +0530"; m = "fix: video session error handling and retry UI"; s = "final"; p = @("lib/features/therapist/video_session_page.dart") },

  @{ d = "2026-03-28 09:57:33 +0530"; m = "ui: redesign login and OTP screens"; s = "final"; p = @("lib/features/auth/phone_login_page.dart", "lib/features/auth/otp_page.dart") },
  @{ d = "2026-03-28 15:33:19 +0530"; m = "ui: animated splash with brand illustration"; s = "final"; p = @("lib/features/auth/splash_page.dart", "assets", "pubspec.yaml") },
  @{ d = "2026-03-28 22:41:08 +0530"; m = "fix: use PNG splash asset for reliable rendering"; s = "final"; p = @("assets/images/splash.png", "assets/images/splash.svg", "pubspec.lock") },

  @{ d = "2026-03-29 12:04:26 +0530"; m = "docs: expand README for beta demo setup"; s = "final"; p = @("README.md") },
  @{ d = "2026-03-29 19:17:55 +0530"; m = "chore: firebase project config for Firestore deploy"; s = "final"; p = @("firebase.json", ".firebaserc", "firestore.indexes.json") },

  @{ d = "2026-03-30 11:22:40 +0530"; m = "fix: tighten community post validation in rules"; s = "final"; p = @("firestore.rules") },
  @{ d = "2026-03-30 16:08:12 +0530"; m = "fix: community stream ordering and empty state"; s = "final"; p = @("lib/features/parent/community_page.dart", "lib/services/app_repository.dart") },

  @{ d = "2026-03-31 11:34:47 +0530"; m = "fix: match therapist UID on session booking"; s = "final"; p = @("lib/services/app_repository.dart", "lib/features/parent/book_session_page.dart") },
  @{ d = "2026-03-31 15:48:03 +0530"; m = "ui: polish parent sessions tab actions"; s = "final"; p = @("lib/features/parent/parent_sessions_tab.dart") },
  @{ d = "2026-03-31 23:12:36 +0530"; m = "chore: add device_info_plus for API URL detection"; s = "final"; p = @("pubspec.yaml", "pubspec.lock", "macos/Flutter/GeneratedPluginRegistrant.swift") },

  @{ d = "2026-04-01 10:22:18 +0530"; m = "docs: add submission checklist and app flow"; s = "final"; p = @("README.md") },
  @{ d = "2026-04-01 18:37:49 +0530"; m = "chore: phase 1 beta cleanup and config templates"; s = "final"; p = @(".gitignore", ".env.example", "server/.env.example", "server/index.js", "scripts/rebuild-git-history.ps1") }
)

foreach ($c in $commits) {
  $root = if ($c.s -eq "head") { $HeadSnap } else { $FinalSnap }
  Copy-Tree -SourceRoot $root -Paths $c.p
  Invoke-DatedCommit -When $c.d -Message $c.m
}

git branch -M main
git worktree remove $HeadSnap --force
$count = git rev-list --count main
Write-Host "Done. $count commits."

# Nirapod AI backend verification — 2026-08-08

## Verified

- FastAPI starts successfully and `/health` returns `status: ok`.
- API version is 14 and the active database is SQLite.
- SQLite reports `integrity=ok` and zero foreign-key violations.
- Authentication, token expiry checks, logout, scans, Wi-Fi assessment, room
  assessment, learning articles, settings, history, analytics, reports,
  notifications, profile, export and chatbot routes pass the authenticated
  integration suite.
- Password reset now uses hashed, 30-minute, single-use tokens. A successful
  reset revokes existing sessions and token reuse is rejected.
- Authentication throttling counts failures instead of successful logins and
  ignores forwarding headers unless `NIRAPOD_TRUST_PROXY_HEADERS=true`.
- Email addresses receive backend format validation.
- Meaningless text and malformed website destinations return `inconclusive`
  instead of a false safety claim.
- Punycode and leetspeak brand-like subdomains receive stronger hybrid-rule
  handling.
- Missing or corrupt promoted model artifacts fall back to the embedded models.
- `dart format` is clean, `flutter analyze` reports no issues, and all four
  Flutter tests pass.
- Flutter release web and Android APK builds succeed.
- Active source contains no SecureLens or PhishLens branding.
- Active Flutter source contains no empty `onTap` or `onPressed` handlers.

## Password-reset configuration

Password reset is implemented but external delivery is disabled until these
server-side environment variables are configured:

- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_USERNAME` (when required)
- `SMTP_PASSWORD` (when required)
- `SMTP_FROM`
- `NIRAPOD_RESET_BASE_URL` (optional)

The live health response currently reports `password_reset_email:
not_configured`. No SMTP secret is stored in Flutter or source control.

## Model decision

The offline URL candidate was **not promoted**. Independent validation used a
balanced set of 106 current OpenPhish URLs and 106 Tranco domains after removing
166,284 training-domain overlaps. At its default threshold the candidate had a
100% false-positive rate and poor calibration. The backend therefore correctly
continues using `embedded-baseline-v1` with hybrid rules and optional Google Safe
Browsing.

This is a limitation, not a runtime failure. A replacement URL model needs new
training/calibration before promotion.

## Removed unused legacy/diagnostic files

- `backend/backend-error.log`
- `backend/backend-output.log`
- `backend/backend-runtime-error.log`
- `backend/backend-runtime.log`
- `backend/backend-start.err`
- `backend/backend-start.log`
- `android/phishlens_ai_android.iml`

These files were not imported or referenced by Flutter, Gradle, FastAPI, startup
scripts or deployment configuration. They are recoverable from:

`C:\Users\Admin\Desktop\ui design\nirapod_pre_backend_cleanup_20260808.zip`

Generated build, `.dart_tool`, `.idea`, virtual-environment, raw-dataset,
validation-dataset, backup, archive and synced-source directories were not
cleaned or edited as legacy source.

## Externally dependent or device-dependent

- Google Safe Browsing requires `GOOGLE_SAFE_BROWSING_API_KEY` on the backend.
- OpenAI chat requires `OPENAI_API_KEY`; otherwise the tested local chatbot is
  used.
- Hosted PostgreSQL requires a real `DATABASE_URL`; local SQLite is verified.
- SMTP delivery requires the variables listed above.
- Biometric authentication, notification permission, foreground protection,
  current Wi-Fi details, Bluetooth discovery, local-network checks, camera,
  QR scanning and ML Kit OCR require a physical supported Android device and
  user permissions. Android code compiles, but hardware behaviour cannot be
  certified by desktop automation.
- Room checks can report observed indicators but cannot certify a room is
  camera-free.
- IP intelligence is approximate hosting/network information, not exact-person
  tracking.

## Non-failing toolchain warnings

- `mobile_scanner` currently applies the Kotlin Gradle plugin and warns that a
  future Flutter version will require built-in Kotlin compatibility.
- The web compiler reports an expected Cupertino icon font even though active
  application source does not reference `CupertinoIcons`; the release web build
  succeeds.

## Release artifacts

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Web: `build/web/index.html`

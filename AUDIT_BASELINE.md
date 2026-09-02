# Nirapod AI audit and accuracy baseline

Date: 2026-08-06

## Verified baseline

- Python backend modules compile successfully.
- Authenticated integration checks pass for registration, settings, URL, QR,
  text, SMS, email, OCR-result analysis, room checks, Wi-Fi checks, learning
  articles, history, analytics, and local chatbot fallback.
- The local database is SQLite (`backend/nirapod.db`). PostgreSQL is selected
  only when `DATABASE_URL` starts with `postgres://` or `postgresql://`.
- Flutter formatting is clean, `flutter analyze` reports no issues, and all
  four Flutter tests pass.
- Android release build succeeds. The verified APK was 98.1 MB.
- `mobile_scanner` emits a future Flutter/Kotlin compatibility warning; it is
  not a current build failure.

## Current architecture

- FastAPI routes cover authentication, scans, Wi-Fi/room assessment, history,
  analytics, reports, profile, export, settings, chat, learning articles,
  support, and notifications.
- OCR runs on-device on Android using Google ML Kit's Latin recognizer. Web OCR
  delegates to `nirapodExtractText` from the web host.
- Android native integrations include biometrics, foreground notification,
  current Wi-Fi metadata, user-authorized local-network checks, Bluetooth
  discovery, clipboard reading, and capability reporting.
- URL intelligence resolves public hosting IP data and returns approximate
  infrastructure location. It is not person tracking or exact geolocation.
- Google Safe Browsing is optional and reports `not_configured` when its server
  key is absent. OpenAI chat is optional and falls back to local responses.

## Accuracy limitation found

The production fallback models were trained during backend import from only 20
embedded URL samples and 16 embedded English message samples. They remain as a
startup-safe fallback, but they are not sufficient evidence for a scientific
accuracy claim.

Content-free input such as `kjsbijsbfjfb` now returns `inconclusive` with zero
confidence instead of being presented as safely understood. Flutter renders
this as a neutral state and analytics do not count it as a threat.

## Offline candidate experiment

The experiment uses:

- UCI PhiUSIIL Phishing URL (CC BY 4.0)
- UCI SMS Spam Collection (CC BY 4.0)

Raw data is kept under the ignored `backend/datasets/raw/` directory. Training
is offline and never runs during FastAPI startup. Candidate artifacts are saved
under `backend/models/candidate/` and are not used unless a reviewed manifest
explicitly promotes them.

### Same-holdout comparison

| Task/model | Accuracy | Precision | Recall | F1 | False-positive rate | False-negative rate | Test samples |
|---|---:|---:|---:|---:|---:|---:|---:|
| URL candidate | 0.9940 | 0.9991 | 0.9827 | 0.9908 | 0.0005 | 0.0173 | 39,326 |
| URL embedded baseline | 0.7535 | 0.9539 | 0.2638 | 0.4133 | 0.0063 | 0.7362 | 39,326 |
| Message candidate | 0.9884 | 0.9603 | 0.9453 | 0.9528 | 0.0055 | 0.0547 | 1,032 |
| Message embedded baseline | 0.3847 | 0.1288 | 0.6875 | 0.2170 | 0.6582 | 0.3125 | 1,032 |

URL holdout splitting is grouped by registered-domain approximation to reduce
domain leakage. Exact normalized duplicates and conflicting labels are removed.
The message experiment combines word and character TF-IDF features.

## What these metrics do not prove

- SMS Spam Collection is English spam-versus-ham data. It does not validate all
  phishing, scam, banking-fraud, Bangla, or Bahasa Melayu messages.
- No native Bangla or Malay candidate has been promoted or claimed.
- OCR extraction accuracy, room safety, Wi-Fi rules, chatbot responses, and IP
  intelligence require separate evaluation protocols.
- A random historical dataset does not guarantee performance against future
  zero-day or adversarial threats.
- No-threat-list match and successful DNS resolution are not proof of safety.

## Promotion decision

Status: **not promoted**.

The candidates clearly beat the embedded learners on these two datasets, but a
production switch should wait for native Bangla/Malay holdouts, phishing subtype
labels, calibration review, latency measurements, and regression tests against
the rule-based hybrid behaviour.

## Protected checkpoint

The pre-change source checkpoint is stored outside the application directory at:

`C:\Users\Admin\Desktop\ui design\nirapod_phase1_checkpoint_20260806.zip`

Generated output, virtual environments, caches, and protected historical/source
copies were excluded. No folder named synced sources, backup, or archive was
edited.

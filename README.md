# Nirapod AI

Flutter implementation of the Nirapod AI mobile cybersecurity application.

## Implemented screens

- Dark splash/welcome screen
- Light onboarding/features screen
- Animated transition from **Get Started** to onboarding
- Responsive layouts for different phone heights
- Custom-drawn Nirapod logo and cybersecurity background

## Run locally

1. Install Flutter and Android Studio.
2. From this folder, run `flutter create .` to generate platform folders.
3. Run `flutter pub get`.
4. Start an Android emulator or connect a phone.
5. Run `flutter run`.

## Run the complete system

The app now requires the local Python backend for machine-learning predictions
and SQLite history.

1. Open Command Prompt in this folder and run `start_backend.bat`.
2. Keep that window open.
3. Open a second Command Prompt in this folder and run `start_app.bat`.

The backend includes a Random Forest URL model, a TF-IDF message model, and a
SQLite database stored at `backend/nirapod.db`.

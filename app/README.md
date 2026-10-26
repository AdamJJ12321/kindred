# Kindred Beta setup

## Firebase project

The Flutter app is configured for Firebase project `my1stapp-b4b47`.

Platform configuration is stored in:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Firestore configuration is stored in `firebase.json`, `firestore.rules`, and `firestore.indexes.json`.

## Local checks

From this directory:

```bash
flutter pub get
flutter test
```

## Firebase deployment

After authenticating with Firebase CLI and selecting `my1stapp-b4b47`, deploy the Beta rules and indexes from this directory:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## Email/password authentication

Enable **Authentication → Sign-in method → Email/Password** in the Firebase console for `my1stapp-b4b47`. The app supports registration, sign-in, sign-out, and password reset from Profile. A `users/{uid}` profile is created or merged after registration and sign-in.

To refresh platform configuration after changing Firebase apps:

```bash
flutterfire configure --project=my1stapp-b4b47
```

## Emulator Suite

Install the Firebase CLI, then run from `app/`:

```bash
firebase emulators:start --only auth,firestore,storage
```

The emulator UI is available at `http://127.0.0.1:4000`. Load representative records from `../docs/slice-0/seed-data.json` using the Firebase console or a local seed script; never commit service-account credentials or production secrets. Use separate Firebase projects for local, staging, and production.

Rules tests live in `rules-tests/` and use the Firebase Emulator Suite:

```bash
cd rules-tests
npm install
npm test
```

The Firestore story repository is in `lib/data/story_repository.dart`. It intentionally keeps the Alpha mock data available while the Explore screen is migrated to live streams in the next Beta step.

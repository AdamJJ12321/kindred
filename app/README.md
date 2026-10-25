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
firebase deploy --only firestore:rules,firestore:indexes
```

The Firestore story repository is in `lib/data/story_repository.dart`. It intentionally keeps the Alpha mock data available while the Explore screen is migrated to live streams in the next Beta step.

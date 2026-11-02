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

## Email/password authentication

Enable **Authentication → Sign-in method → Email/Password** in the Firebase console for `my1stapp-b4b47`. The app supports registration, sign-in, sign-out, and password reset from Profile. A `users/{uid}` profile is created or merged after registration and sign-in.

To refresh platform configuration after changing Firebase apps:

```bash
flutterfire configure --project=my1stapp-b4b47
```

## Emulator Suite

Install the Firebase CLI, then run from `app/`:

```bash
firebase emulators:start --only auth,firestore
```

This starts only the Auth and Firestore emulators on ports 9099 and 8080; the Emulator UI is at `http://127.0.0.1:4000`. The checked-in local seed is `../docs/slice-0/seed-data.json`. Import it through the Emulator UI or a local, disposable seed script while the emulators are running. Do not point local development at the production project, and do not add service-account credentials.

Run the Flutter app against those emulators with `flutter run --dart-define=USE_FIREBASE_EMULATORS=true`.

The emulator UI is available at `http://127.0.0.1:4000`. Start Auth and Firestore for the current Beta scope:

```bash
firebase emulators:start --only auth,firestore
```

Load representative records from `../docs/slice-0/seed-data.json` using the Firebase console or a local seed script; never commit service-account credentials or production secrets. Use separate Firebase projects for local, staging, and production. Binary media storage is deferred; current evidence fields remain Firestore metadata only.

Rules tests live in `rules-tests/` and use the Firebase Emulator Suite:

```bash
cd rules-tests
npm install
npm test
```

Start `firebase emulators:start --only auth,firestore` in another terminal before `npm test` (the tests target Firestore at `127.0.0.1:8080`).

The Jest rules tests start an in-process Firestore rules test environment, so no production Firestore data is touched. They cover allowed and denied reads/writes for stories, evidence ownership, profiles, families, daily questions, and timeline events.

Evidence is metadata-only under `stories/{storyId}/evidence/{evidenceId}` (`kind`, optional `fileName`, `caption`, `sourceNote`, and `uploadedBy`). Binary photo, document, audio, and video support remains deferred.

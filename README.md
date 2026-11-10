# Kindred Beta C

Kindred is a Flutter app for preserving and exploring oral, family, cultural, local, and personal histories. This repository is the Flutter app root and uses Firebase Auth and Firestore. Binary media uploads remain deferred in Beta; evidence is currently Firestore metadata under `stories/{storyId}/evidence/{evidenceId}`.

## Local emulator development

Install Flutter, Node.js, the Firebase CLI, and a Java runtime required by the emulators. From this directory:

```bash
firebase emulators:start --only auth,firestore
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

Auth runs on `9099`, Firestore on `8080`, and the Emulator UI on `http://127.0.0.1:4000`. The app connects to Auth and Firestore emulators only when the dart define is enabled.

The checked-in `seed-data.json` is a local, disposable Firestore seed. With emulators running, install Rules-test dependencies and load it with:

```bash
cd rules-tests
npm install
node seed-emulator.js
```

The Emulator UI at `http://127.0.0.1:4000` can then be used to inspect or clear the seeded Firestore data. Auth users can be created through the Auth emulator UI; the seed contains Firestore profile records only. Do not use production credentials or secrets for local seeding.

## Checks

Start the emulators in one terminal, then run:

```bash
cd rules-tests
npm install
npm test
cd ..
flutter analyze
flutter test
```

The Rules tests target `127.0.0.1:8080` and cover stories, evidence ACLs, families/members, users, daily questions, and timeline events. Deploy reviewed Firestore changes with:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## Environments and security

Local uses Auth/Firestore emulators and disposable synthetic seed data. Staging must use an isolated Firebase project with synthetic or consented data. Production requires reviewed Rules/index deployment, restricted access, backups, monitoring, and no committed service credentials. Firebase client configuration is non-secret; never commit service-account keys, API secrets, or binary media.

Auth flows and repository patterns already exist. The app preserves the Pastport-inspired parchment, teal, terracotta, editorial/sans visual direction and dark mode. Storage, recording, AI, and later slices are intentionally out of scope.

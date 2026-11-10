# Kindred Beta C

Kindred is a Flutter app for preserving and exploring oral, family, cultural, local, and personal histories. This repository is the Flutter app root and uses Firebase Auth, Firestore, and Firebase Storage for Slice 1 photo/document evidence. Audio/video uploads remain deferred. Evidence metadata lives under `stories/{storyId}/evidence/{evidenceId}`.

## Local development

Use a dedicated non-production Firebase project with synthetic data. The Firebase Emulator Suite is not configured or used by this app. Do not use production credentials or real user data for local testing.

## Checks

```bash
flutter analyze
flutter test
```

Rules tests require a separately managed Firebase test environment. Deploy reviewed Firestore and Storage changes with:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## Environments and security

Local and staging use isolated Firebase projects with synthetic or consented data. Production requires reviewed Rules/index deployment, restricted access, backups, monitoring, and no committed service credentials. Firebase client configuration is non-secret; never commit service-account keys, API secrets, or binary media.

Auth flows and repository patterns already exist. The app preserves the Pastport-inspired parchment, teal, terracotta, editorial/sans visual direction and dark mode. Storage, recording, AI, and later slices are intentionally out of scope.

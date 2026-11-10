# Next work brief — Kindred Slice 1 Part B

## Product context

Kindred is a Flutter app for preserving and exploring oral, family, cultural, local, and personal histories. Stories support provenance, evidence, dates, locations, family relationships, and privacy. Preserve the Pastport-inspired parchment, teal, terracotta/gold, editorial/sans visual direction and full dark mode.

## Current repository state

The Flutter and Git repository root is `/Users/ying/Desktop/kindred/app`. Existing functionality includes Firebase Auth, user/story/family/question/timeline repositories, realtime Firestore listeners, story drafts/publishing, public/private/family/invited visibility, Firebase Storage photo/document uploads, Firestore evidence metadata, Firestore/Storage Rules, automated Rules tests, and existing widget tests.

The Firebase Emulator Suite has been removed from project configuration. Do not add emulator setup back. Use repository interfaces and mock/local fixtures for new pre-MVP behavior where practical. Firebase integration is planned for MVP hardening in `PLAN.md`.

Read before coding:

```text
PLAN.md
README.md
docs/slice-0/data-contracts.md
docs/slice-0/privacy-and-access.md
docs/slice-0/environments.md
docs/slice-0/navigation.md
docs/slice-0/quality-requirements.md
lib/data/*
lib/main.dart
firestore.rules
storage.rules
firebase.json
rules-tests/
seed-data.json
```

## Scope — Part B only

Complete the remaining Slice 1 story/evidence workflow. Do not implement Slice 2–6, recording intelligence, speech recognition, AI, translation, summaries, notifications, or a broad UI redesign.

Deliver:

- Approximate, exact, and range dates with visible date confidence; never invent precision.
- Multiple story/evidence locations with labels, coordinates, and precision for sensitive locations.
- Evidence previews showing filename, type, MIME type, caption, and source note.
- Evidence metadata editing and deletion, including associated Storage cleanup for the owner.
- Stable evidence ordering and reordering.
- Failed-upload, retry, offline, missing-media, and permission-error states.
- Reopen/edit existing drafts or owned stories while preserving creator attribution.
- Smallest contract-aligned edit-history/original-content support; no generalized audit platform.

## Constraints

- Preserve Pastport UI, dark mode, Auth, realtime behavior, and repository patterns.
- Preserve public-default stories, public family groups, per-story privacy, invited access, and deny-by-default Rules.
- Do not restore the Firebase Emulator Suite.
- Do not add production secrets, service-account credentials, or generated dependency directories.
- Commit only if explicitly requested.

## Acceptance checks

- Drafts can be created, edited, reloaded, and published without losing metadata.
- Stories can contain multiple locations and ordered evidence items.
- Owners can preview, edit, reorder, retry, and delete evidence; unauthorized users cannot.
- Storage and Firestore permissions match the privacy contract.
- Public stories/families remain readable while private/family/invited access remains restricted.
- Live story/family surfaces still update from repository streams.
- Light/dark mode, text scaling, loading, empty, offline, and permission-error states remain usable.

## Verification

From `/Users/ying/Desktop/kindred/app`:

```bash
flutter pub get
flutter analyze
flutter test
```

Run Rules tests only against the separately managed Firebase test environment; do not add local emulator configuration. Manually test with two authenticated users: draft/publish, public/private/family/invited access, multiple locations, evidence order/edit/delete, failed upload/retry, and dark mode.

## Copy-pasteable next-session prompt

```text
Work in /Users/ying/Desktop/kindred/app. Read prompt.md, PLAN.md, README.md, the Slice 0 contract/privacy/environment/navigation/quality docs, lib/data/*, lib/main.dart, firestore.rules, storage.rules, firebase.json, seed-data.json, and rules-tests/ before editing.

Implement Kindred Slice 1 Part B only: approximate/exact/range date confidence, multiple locations with precision, evidence previews, stable evidence ordering/reordering, evidence metadata edit/delete, associated Storage cleanup, retry/offline/permission-error states, draft/story editing, creator attribution, and the smallest contract-aligned edit-history/original-content support. Preserve the Pastport-inspired UI, dark mode, Auth, realtime behavior, repository interfaces, public-default visibility, public family groups with per-story privacy, and deny-by-default Rules. Do not implement Slice 2–6, recording, microphone capture, speech recognition, AI, translation, summaries, notifications, broad redesign, or the Firebase Emulator Suite. Use mock/local fixtures for new pre-MVP behavior where practical, update contracts/Rules/tests together, run flutter analyze and flutter test, and report files changed, commands/results, manual tests, and known gaps. Commit only if explicitly requested.
```

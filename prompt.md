# Next work brief — Kindred Slice 1 Part B

Kindred is a Flutter mobile app backed by Firebase where people preserve and explore oral, family, cultural, local, and personal histories. Stories can include media, evidence classification, dates, locations, and relationships to other stories. People discover history spatially through a map, chronologically through a timeline, or personally through family collections. The product favors complementary oral and documented history, visible provenance, original evidence beside generated text, public-by-default stories with author privacy control, public family groups with per-story privacy, and gentle progress without ranking sensitivity or popularity.

## Current status

Beta 5–7 is complete in this repository: Firestore Rules and automated Rules tests, realtime snapshot streams, and checked-in seed data. Existing code includes Firebase Auth UX, repositories for stories/users/families/daily questions/timeline, Firebase Storage photo/document evidence, Explore and Families live surfaces, dark mode, and the Pastport-inspired UI. The Firebase Emulator Suite has been removed from the project configuration; local/staging work uses an isolated Firebase project.

## Next scope: Slice 1 Part B only

Continue the real story creation and evidence workflow. Part A now covers draft/publish, photo/document Storage uploads, source notes, and owner ACLs. Do not implement Slice 2–6 features, AI, recording intelligence, or a broad visual redesign.

Deliver:

- Story drafts and publishing flow.
- Multi-file photo/document upload plus audio/video attachments through Firebase Storage.
- Evidence classification and source notes.
- Approximate dates and multiple locations.
- Evidence preview, ordering, editing, and deletion.
- Creator attribution and edit history/original content preservation.

Preserve the Pastport theme and dark mode, keep the repository pattern and feature boundaries, default new stories to public, and keep family groups public with privacy controlled per story. Storage was deferred in Beta; Slice 1 is the point where real media upload and story/evidence association lands. Do not add AI yet.

## Acceptance and testing

Verify authenticated users can save drafts, publish stories, attach and manage multiple evidence items, see attribution/edit history, and preserve metadata after reload. Verify public/private/family/invited Rules behavior, owner-only edits/deletes, Storage authorization, offline/error states, and live updates from a second client. Add repository/widget tests, Rules tests against a separately managed Firebase test project, upload metadata tests, and a manual device test for large files, interrupted uploads, retry, ordering, and deletion. Run `flutter analyze`, `flutter test`, and Rules tests before release.

## Next-session agent prompt

```text
Work in /Users/ying/Desktop/kindred/app. Read prompt.md, README.md, PLAN.md if present, firestore.rules, firebase.json, lib/data, lib/main.dart, and rules-tests before changing code.

Implement Slice 1 only: real story drafts/publishing and evidence workflow with Firebase Storage media association. Add multi-file photo/document upload, audio/video attachments, evidence classification/source notes, approximate dates, multiple locations, evidence preview/order/edit/delete, creator attribution, and edit history/original content preservation. Preserve the Pastport-inspired UI and dark mode, repository patterns, public-default visibility, public family groups with per-story privacy, and existing Auth/realtime behavior. Do not implement Slice 2–6, AI, speech recognition, or a large redesign. Update Rules/tests and documentation, use a separately managed Firebase test project for verification, and report exact files changed and test results. Commit only if explicitly requested.
```

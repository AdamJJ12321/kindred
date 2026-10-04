# Kindred iterative product and technical plan

Kindred is a Flutter mobile app backed by Firebase where people preserve and explore oral, family, cultural, local, and personal histories. Each story can include media, evidence classification, dates, locations, and relationships to other stories. Users discover history spatially through an interactive map, chronologically through an interactive timeline, or personally through family collections.

## Product principles

- Treat oral accounts and documented records as complementary forms of history.
- Make provenance visible: every story identifies whether it is a firsthand memory, oral account, documented fact, or unverified story.
- Preserve original evidence alongside generated or edited text.
- Keep family histories private by default, with explicit public-sharing controls.
- Build in vertical slices so every milestone produces a usable experience.

## Shared technical foundation

### Flutter application

Organize the app by feature rather than by screen:

- `core`: theme, routing, permissions, connectivity, local persistence, and error handling.
- `auth`: accounts, profiles, and access state.
- `stories`: story creation, editing, evidence, and discovery.
- `recording`: microphone permissions, recording, playback, and upload state.
- `map`: location-based exploration.
- `timeline`: chronological exploration and event grouping.
- `families`: private and public family-history collections.
- `daily_questions`: prompts and answers.
- `processing`: transcription, summaries, translation, and job status.

Use repository interfaces between UI and data services. Alpha repositories use mock data; Beta repositories use Firebase without requiring a rewrite of the screens.

### Firebase backend

- Firebase Authentication for accounts and sign-in.
- Cloud Firestore for users, stories, events, family collections, questions, and permissions.
- Firebase Storage for photographs, audio, video, documents, and other evidence.
- Cloud Functions for media processing, transcription orchestration, metadata extraction, daily-question scheduling, notifications, and moderation hooks.
- Firebase App Check, Security Rules, and audit logging for access control.
- Firebase Analytics and Crashlytics for usage and reliability.

### Core story model

Each story should support:

- Title, description, creator, and story type: oral, local, family, cultural, or personal.
- Evidence classification: firsthand memory, oral account, documented fact, or unverified story.
- Exact or approximate dates and one or more locations with coordinates and readable place names.
- Photographs, recordings, documents, and other evidence.
- Related people, families, events, and stories.
- Visibility: private, family-only, invited users, or public.
- Review status, edit history, and original content alongside any generated text.

## Iterative development slices

### Slice 0: Product and technical preparation

Define the visual language, information architecture, permission model, and Firebase schema before feature implementation.

Deliverables:

- Navigation map and screen inventory.
- Story, evidence, location, timeline, family, and question data contracts.
- Privacy and visibility rules.
- Development, staging, and production Firebase environments.
- Representative seed data for family memories, local events, documented facts, and unverified stories.
- Accessibility, media-retention, consent, and deletion requirements.

### Alpha: designed app with mock data

The first complete milestone is an interactive prototype that demonstrates the product without depending on Firebase.

Include:

- Onboarding and profile creation using local mock state.
- Home feed showing featured and recent stories.
- Story detail with text, creator, evidence classification, dates, location, and attachments.
- Create-story flow with mock photograph, document, and recording attachments.
- Interactive mock history map with tappable story markers.
- Interactive mock timeline with chronological story cards.
- Family-history view showing private and public collections.
- Recording screen with simulated recording and playback states.
- Daily-question card with a locally stored answer flow.
- Search and filters for story type, evidence type, date, family, and location.
- Visibility controls represented in the interface, even while enforcement is mocked.

Alpha acceptance criteria:

- A user can navigate from discovery to a story, map location, timeline event, family collection, and daily question.
- A user can create and edit a mock story with all core metadata.
- Map and timeline provide two distinct paths to the same story.
- The interface clearly distinguishes memory, oral account, documented fact, and unverified story.
- Empty, loading, error, and no-results states are designed.
- Widget and golden tests cover primary navigation and story creation.

### Beta: Firebase connection and persistence

Replace mock repositories with Firebase while preserving the Alpha UI.

Implement:

- Firebase Authentication.
- Firestore repositories for users, stories, families, questions, and timeline events.
- Firebase Storage references and upload handling.
- Security Rules for private, family-only, invited, and public content.
- Real-time story and collection updates.
- Development seed data and Firebase Emulator Suite support.
- Environment configuration for development, staging, and production.

Beta acceptance criteria:

- A user can register, sign in, sign out, and recover access.
- Stories persist across sessions and devices.
- Uploaded media is stored in Firebase Storage and associated with the correct story.
- Unauthorized users cannot read private or family-only content.
- Map and timeline render Firestore data.
- Automated Rules tests cover ownership, family roles, invitations, and public access.

### Slice 1: Real story creation and evidence

Replace mocked creation with a complete evidence workflow:

- Story metadata form and draft saving.
- Multi-file upload for photographs and documents.
- Audio and video attachments.
- Evidence classification and source notes.
- Approximate dates and multiple locations.
- Evidence preview, ordering, editing, and deletion.
- Creator attribution and edit history.

### Slice 2: Recording and oral-history workflow

Implement direct recording of someone telling their story:

- Microphone permission and consent explanation.
- Start, pause, resume, stop, and playback.
- Background interruption recovery and long-recording resilience.
- Upload progress, retry, and local recovery.
- Recording linked to a story or interview session.
- Original audio preservation and manual transcript correction.

### Slice 3: Map and timeline exploration

Make the two core discovery experiences production-ready.

Map capabilities:

- Story markers with clustering and location detail cards.
- Filters by date, story type, evidence type, family, and visibility.
- Marker-to-story navigation.
- Approximate-location handling for sensitive stories.
- Accessible list alternative to the map.

Timeline capabilities:

- Chronological event grouping with approximate dates and date ranges.
- Multiple stories attached to one event.
- Family and community timeline modes.
- Filters, search, and links between timeline events and map locations.

### Slice 4: Family histories and sharing

Implement private and public family-history collections:

- Create family or community collections.
- Invite members and assign owner, editor, contributor, and viewer roles.
- Add or remove stories from collections.
- Private, invite-only, and public collection visibility.
- Contribution approval, access revocation, and story removal.
- Export or archive family-history data.

### Slice 5: Daily questions

Introduce recurring prompts as an engagement layer:

- Cloud Function scheduling with time-zone support.
- Questions about childhood, recipes, work, migration, local places, and celebrations.
- Text, photo, and recording answers.
- Save as a private draft or convert to a story.
- Question history, reminders, moderation, and reporting.

### Slice 6: AI enrichment and advanced discovery

Add AI after evidence, permissions, and review workflows are stable:

- Original-language speech transcription.
- Clean summaries that preserve uncertainty and attribution.
- Translation into the selected language.
- Suggested dates, places, people, and topics.
- Related-story recommendations and search across transcripts, summaries, people, places, and dates.
- Human review before generated content is published.
- Provider, model, version, and processing timestamp recorded for each artifact.

AI-generated text must remain distinguishable from the original account and editable by the user.

## MVP scope

The MVP is the full feature set: authenticated accounts, story creation, photographs, recordings, documents, evidence classification, Firebase persistence and security, map, timeline, private and public family histories, daily questions, transcription, summaries, translation, search, filtering, sharing, deletion, privacy controls, accessibility support, analytics, crash reporting, and comprehensive testing.

## Testing strategy

- Flutter unit tests for models, repositories, validation, upload queues, and state transitions.
- Widget and golden tests for every primary user flow.
- Integration tests using the Firebase Emulator Suite.
- Firebase Security Rules tests for ownership, family roles, invitations, and public access.
- Media tests for permissions, interrupted recording, large uploads, retries, and offline recovery.
- Map and timeline tests for date ranges, approximate locations, clustering, filters, and privacy.
- AI evaluation tests for transcript fidelity, translation quality, names, dates, accents, code-switching, and hallucination avoidance.
- Accessibility tests for screen readers, text scaling, contrast, captions, and non-map alternatives.
- Performance tests for long recordings, low storage, weak connectivity, and older phones.

## Release sequence

1. Product foundation and data contracts.
2. Alpha: mock-data app with complete navigation and visual design.
3. Beta: Firebase authentication, database, storage, and Security Rules.
4. Real story and evidence creation.
5. Recording and upload workflow.
6. Map and timeline experiences.
7. Family histories and sharing.
8. Daily questions.
9. AI enrichment and advanced search.
10. MVP hardening, privacy review, accessibility, performance testing, and pilot release.

## Assumptions and defaults

- Flutter targets iOS and Android first.
- Firebase is the required backend; Firebase Emulator Suite is used during development.
- Stories are private by default and become public only through explicit user action.
- The app supports approximate dates and locations for uncertain or sensitive histories.
- Public archives, classroom dashboards, collaborative editing, and broad multilingual support can follow the MVP unless pilot requirements elevate them.

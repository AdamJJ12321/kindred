# Navigation and screen inventory

## Primary navigation

The Alpha app uses four top-level destinations:

1. **Explore** — featured stories, search, filters, map, and timeline.
2. **Create** — start a story, answer a daily question, or record an interview.
3. **Families** — family and community history collections.
4. **Profile** — account, language, privacy, storage, and help.

Authentication and consent are entry flows, not top-level destinations.

## Core journeys

### Discover a story

`Explore → Map or Timeline → Story detail → Creator / evidence / related stories`

The map and timeline are alternate entry points to the same story detail. Every story detail must show its evidence classification, creator, date confidence, location confidence, visibility, and attached evidence.

### Create a story

`Create → Story setup → Metadata → Add evidence → Review → Save draft or publish`

Metadata includes title, story type, evidence classification, dates, locations, people, and visibility. A draft may be incomplete; publishing requires a title, creator, evidence classification, and visibility choice.

### Record an oral history

`Create → Record interview → Consent → Prompt pack → Recording → Review → Attach to story`

The recording flow must communicate who is being recorded, what will happen to the audio, and how sharing can be revoked before recording begins.

### Build a family history

`Families → Create collection → Invite members → Add stories → Collection map/timeline`

Collections can be private, invite-only, or public. Collection membership never overrides a story’s more restrictive visibility.

### Answer the daily question

`Create or Home card → Daily question → Text/photo/recording answer → Keep private or turn into story`

An answer retains its original question and creator when converted into a story.

## Required screen states

Every data-backed screen has loading, empty, error, offline, and permission-denied states. Forms also have unsaved-changes and upload-failure states.

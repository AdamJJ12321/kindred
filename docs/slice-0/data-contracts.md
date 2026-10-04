# Firestore data contracts

These are first-pass contracts for the Firebase repositories. IDs are generated document IDs. Timestamps use Firebase server timestamps. Fields may gain optional properties without breaking clients; changing meaning or removing fields requires a migration note.

## Collections

### `users/{userId}`

```text
displayName: string
photoUrl?: string
preferredLanguage: string
timeZone: string
createdAt: timestamp
updatedAt: timestamp
```

### `stories/{storyId}`

```text
creatorId: string
title: string
description?: string
storyType: oral | local | family | cultural | personal
evidenceType: firsthand_memory | oral_account | documented_fact | unverified_story
visibility: public | private | family | invited
status: draft | published | archived | deleted
date?: { kind: exact | approximate | range, start: timestamp, end?: timestamp }
location?: { label: string, latitude: number, longitude: number, precision: exact | neighborhood | city | region }
familyIds: string[]
relatedStoryIds: string[]
createdAt: timestamp
updatedAt: timestamp
publishedAt?: timestamp
```

### `stories/{storyId}/evidence/{evidenceId}`

```text
kind: photograph | audio | video | document | other
storagePath: string
mimeType: string
fileName: string
caption?: string
sourceNote?: string
uploadedBy: string
```

### `families/{familyId}`

```text
name: string
description?: string
visibility: public
ownerId: string
```

### `families/{familyId}/members/{userId}`

```text
role: owner | editor | contributor
status: invited | active | removed
invitedBy: string
```

### `timelineEvents/{eventId}`

```text
storyIds: string[]
title: string
description?: string
date: { kind: exact | approximate | range, start: timestamp, end?: timestamp }
location?: { label: string, latitude: number, longitude: number, precision: exact | neighborhood | city | region }
createdBy: string
createdAt: timestamp
updatedAt: timestamp
```

### `dailyQuestions/{questionId}`

```text
prompt: string
category: childhood | food | work | migration | local_place | celebration | other
language: string
activeDate: string # YYYY-MM-DD in the target time zone
```

### `answers/{answerId}`

```text
questionId: string
creatorId: string
kind: text | photograph | audio | recording
content?: string
evidenceId?: string
visibility: public | private | family | invited
storyId?: string
```

Generated transcript, summary, translation, and extraction results belong in `stories/{storyId}/artifacts/{artifactId}` with only `kind`, `sourceLanguage`, `targetLanguage?`, `provider`, `modelVersion`, `status`, `content`, and `reviewedBy?`. Do not add timestamps to evidence, memberships, questions, answers, or artifacts unless a shipped feature displays or relies on them. Users, stories, and timeline events retain timestamps for profile age, chronology, and event ordering.

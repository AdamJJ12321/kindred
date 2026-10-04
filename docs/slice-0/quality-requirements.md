# Quality requirements

## Accessibility

- Support screen readers and semantic labels for controls, map markers, media, and recording state.
- Support text scaling without clipped or inaccessible content.
- Meet platform contrast and touch-target guidance.
- Provide a list-based alternative for map exploration.
- Provide captions or transcripts for audio and video where available.

## Visual theme

- The default appearance is a restrained light theme using familiar Material components and modest accent colors.
- Profile settings provide `System`, `Light`, and `Dark` choices.
- Persist the choice locally before sign-in and with the user profile after sign-in.
- Test every primary screen and state in both light and dark modes, including map markers, timeline cards, dialogs, upload progress, and errors.
- Do not use color alone to communicate evidence type, visibility, recording state, or processing status.

## Consent and safety

- Explain recording, storage, AI processing, and sharing in plain language before consent.
- Make consent revocable and show the current consent state.
- Distinguish the storyteller’s words from summaries, translations, and inferred metadata.
- Provide reporting and removal paths for public or invited content.

## Media and reliability

- Preserve local recordings through temporary connectivity loss and app interruption.
- Make uploads resumable and retryable.
- Never discard original evidence when derived processing fails.
- Show progress and actionable errors for recording, upload, and processing.

## Alpha quality bar

Alpha must have complete navigation, representative content, and designed states for loading, empty, offline, errors, permissions, drafts, and unsaved changes. It does not need production authentication, real uploads, or real AI processing.

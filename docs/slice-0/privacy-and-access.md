# Privacy and access rules

## Visibility

- **Public:** stories are public by default. The author can change visibility before posting or at any time afterward.
- **Private:** only the creator and explicitly authorized service operations can read the story and its evidence.
- **Family:** active members of a referenced family collection can read it; the creator retains access.
- **Invited:** only accepted invitees can read it; invitation access can be revoked.
- **Public:** any authenticated or anonymous reader allowed by the product surface can read the published story. The creator must explicitly publish it.

Family groups are always public and cannot be changed to private. A story inside a family group keeps its own visibility, so a private story remains private even when its family group is public.

## Ownership and roles

- The creator owns a story and controls its visibility, edits, and deletion.
- Family owners manage membership and collection settings.
- Editors can curate collection stories but cannot change another creator’s story visibility without creator authorization.
- Contributors can add stories subject to the collection’s approval policy.

## Consent

Recording requires a clear confirmation from both the person operating the app and the person being recorded. Recording consent and sharing consent are separate. Consent records include participant IDs, scope, timestamp, and revocation timestamp if applicable.

## Deletion and retention

- A creator can delete a story and its derived artifacts.
- Deleting a story removes or tombstones its evidence, timeline references, map results, and generated artifacts according to the retention policy.
- Account deletion begins a documented deletion workflow for personal data and owned media.
- Original media is retained only while the story or its archive policy requires it.
- AI-generated content never replaces the original recording or source evidence.

## Security requirements

- Enforce access with Firestore Security Rules and Storage Rules; client-side hiding is not authorization.
- Validate creator, family membership, visibility, and status on every read/write path.
- Protect sensitive or approximate locations by storing the precision explicitly and rendering only the permitted precision.
- Keep provider credentials and privileged processing operations in Cloud Functions, never in the Flutter client.

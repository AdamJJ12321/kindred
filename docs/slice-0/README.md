# Slice 0: Product and technical preparation

Slice 0 establishes the contracts that Alpha, Beta, and the later feature slices build on. It is complete when the navigation, data model, access rules, environments, seed data, and quality requirements are reviewable without relying on implementation details.

## Deliverables

- [Navigation and screen inventory](./navigation.md)
- [Firestore data contracts](./data-contracts.md)
- [Privacy and visibility rules](./privacy-and-access.md)
- [Environment and Firebase setup](./environments.md)
- [Seed data](./seed-data.json)
- [Quality requirements](./quality-requirements.md)

## Completion checklist

- [x] Define the primary user journeys and screens.
- [x] Define the first-pass Firestore document shapes and relationships.
- [x] Define visibility, ownership, family roles, and deletion behavior.
- [x] Define development, staging, and production environment boundaries.
- [x] Provide representative seed data for Alpha and the Firebase Emulator Suite.
- [x] Record accessibility, consent, retention, and deletion requirements.
- [ ] Review contracts with product and engineering before Slice 1 implementation.

# Environments and Firebase setup

## Environments

| Environment | Purpose | Data policy |
| --- | --- | --- |
| Local | Flutter development and automated tests | Firebase Emulator Suite only; disposable seed data |
| Staging | QA, device testing, and pilot rehearsal | Isolated Firebase project; synthetic or consented test data only |
| Production | Real users and stories | Restricted access, backups, monitoring, and reviewed deployments |

The Flutter app selects an environment through build configuration. No production project ID, service credential, or AI provider secret is committed to the repository.

## Local development

Use the Firebase Emulator Suite for Authentication, Firestore, Storage, and Functions. Seed the emulators from `seed-data.json` and reset them between automated test runs.

## Required configuration

Configuration should provide project identifiers and non-secret client settings per environment. Privileged credentials belong in deployment secrets. Add a checked-in example configuration with placeholder values when implementation begins.

## Deployment gates

- Run Flutter unit, widget, and integration tests.
- Run Firestore and Storage Rules tests.
- Verify no production credentials are present in the build artifact or repository.
- Deploy Functions and Rules before clients that depend on new fields or permissions.
- Record schema or Rules changes in the release notes.

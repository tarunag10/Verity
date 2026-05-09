# Contributing to Verity

Thanks for your interest in improving Verity.

## Development Setup

1. Install Xcode 16 or newer.
2. Clone the repository.
3. Build and test:

```bash
swift build
swift test
```

For local app runs:

```bash
./script/build_and_run.sh
```

## Pull Requests

Before opening a pull request:

- Keep changes focused and easy to review.
- Add or update tests for behavior changes.
- Run `swift test`.
- Run `git diff --check`.
- Avoid committing generated user data, local model caches, logs, or signing credentials.

## Architecture Notes

- `VerityCore` owns deterministic parsing, retrieval, templates, persistence, and tests.
- `Verity` owns the native SwiftUI macOS interface.
- `VerityMLX` is the integration surface for local model runtimes.
- Prefer local-first behavior and explicit citations over speculative answers.

## Accessibility

UI contributions should preserve keyboard access, VoiceOver labels, clear focus states, and high-contrast readable surfaces.

## Security and Privacy

Do not include real documents, credentials, tokens, private keys, provisioning profiles, or notarization secrets in commits. Report vulnerabilities using the process in `SECURITY.md`.

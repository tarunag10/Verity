# Security Policy

## Reporting a Vulnerability

Please do not open public issues for security vulnerabilities.

Report suspected security issues privately by contacting the repository owner through GitHub. Include:

- A clear description of the issue.
- Steps to reproduce.
- Impact and affected versions or commits, if known.
- Any suggested remediation.

## Scope

Security-sensitive areas include:

- Local document storage and deletion.
- Citation and source preview behavior.
- Model, OCR, or telemetry integrations.
- Release signing, notarization, and distribution scripts.
- Handling of local files and security-scoped resources.

## Data Handling

Verity is local-first, but contributors should still treat test files, sample documents, logs, and model artifacts as potentially sensitive. Do not commit private user data or credentials.

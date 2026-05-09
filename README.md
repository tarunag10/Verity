# Verity

Verity is a local-first private document assistant for macOS. It helps you import, search, summarize, and extract structured answers from local documents while keeping the document workflow on your machine by default.

The app is built with Swift, SwiftUI, Swift Package Manager, and an Xcode project generated from `project.yml`.

## Features

- Native SwiftUI macOS app.
- Local document library and folder import.
- Text extraction for PDF, Markdown, plain text, and RTF files.
- Local chunking, lexical retrieval, extractive Q&A, summaries, and citations.
- Source previews with citation snippets and highlight ranges.
- Built-in templates for invoices, contract review, manuals, research papers, policies, key dates, and document comparison.
- Structured extraction with field-level citations and CSV export.
- Collections for scoping searches and workflows.
- Local evaluation checks for cited answers and honest not-found behavior.
- Privacy dashboard with local-only defaults.
- Accessibility-focused UI surfaces and keyboard/VoiceOver-friendly controls.
- Extension points for MLX embeddings/generation, OCR, and custom templates.

## Current Status

Verity is an early-stage native macOS project. The deterministic retrieval engine is intentionally local and transparent so the app works without cloud services or required model downloads.

Production MLX embeddings/generation and OCR can be implemented behind the existing core interfaces when those integrations are selected.

## Requirements

- macOS 14 or later.
- Xcode 16 or newer recommended.
- Swift 6.2 toolchain.

## Run

```bash
./script/build_and_run.sh
```

You can also open `Verity.xcodeproj` in Xcode and run the `Verity` scheme.

## Test

```bash
swift test
```

## Build

```bash
swift build
```

## Project Structure

```text
Sources/
  Verity/        SwiftUI macOS app target
  VerityCore/    Core models, parsing, retrieval, templates, persistence
  VerityMLX/     MLX runtime integration surface
Tests/
  VerityCoreTests/
docs/
  distribution/  Packaging and notarization notes
script/          Local build/run helpers
scripts/         Release and validation helpers
```

## Privacy

Verity is designed around local-first document workflows. The current deterministic retrieval path does not require a hosted API. Review any future model, OCR, telemetry, or distribution integrations before enabling them for sensitive documents.

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## Security

Please report security issues privately. See [SECURITY.md](SECURITY.md).

## License

Verity is released under the [MIT License](LICENSE).

# Verity

Verity is a local-first private document assistant for macOS, based on the PRD in `verity_local_private_document_assistant_prd.md`.

This scaffold implements the MVP foundation:

- Native SwiftUI macOS app.
- Local document library and import.
- Text extraction for PDFs, Markdown, plain text, and RTF.
- Local chunking, search, extractive Q&A, summaries, and citations.
- Local JSON persistence.
- Privacy dashboard with local-only defaults.
- Extension points for MLX embeddings/generation, OCR, sync, licensing, and templates.

## Run

```bash
./script/build_and_run.sh
```

## Test

```bash
swift test
```

## Build

```bash
swift build
```

## MVP Boundaries

The current RAG engine is intentionally local and deterministic. It uses lexical retrieval and extractive answer assembly so the app is usable without cloud services or bundled model downloads. Production MLX embeddings and local answer generation should replace `LocalRAGEngine` behind the same domain interfaces.

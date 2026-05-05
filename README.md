# Verity

Verity is a local-first private document assistant for macOS, based on the PRD in `verity_local_private_document_assistant_prd.md`.

This scaffold implements the MVP foundation:

- Native SwiftUI macOS app.
- Local document library and import.
- Text extraction for PDFs, Markdown, plain text, and RTF.
- Local chunking, search, extractive Q&A, summaries, and citations.
- Local JSON persistence.
- Privacy dashboard with local-only defaults.
- In-app citation preview and PDF/text source viewer.
- Built-in templates for invoice extraction, contract review, manuals, research papers, policies, key dates, and document comparison.
- Structured extraction with field-level citations and CSV export.
- Recursive folder import for supported local document types.
- Local evaluation checks for cited answers and honest not-found behavior.
- Product settings surfaces for local AI engine status, document processing, telemetry, and data deletion.
- Extension points for MLX embeddings/generation, OCR, and templates.

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

The current RAG engine is intentionally local and deterministic. It uses lexical retrieval, deterministic extraction, and extractive answer assembly so the app is usable without cloud services or bundled model downloads.

Production MLX embeddings/generation and OCR should be implemented behind the existing core interfaces when those integrations are selected.

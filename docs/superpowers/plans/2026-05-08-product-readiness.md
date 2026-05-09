# Product Readiness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a coherent product-readiness pass for Verity covering native UI polish, template history/source review, evaluation metrics, and local AI readiness.

**Architecture:** Add small derived models and source-resolution helpers in `VerityCore`, then consume them from focused SwiftUI views. Keep deterministic local behavior honest and avoid fake MLX download flows until the runtime exposes that state.

**Tech Stack:** Swift 6.2, SwiftPM, SwiftUI, AppKit, PDFKit, Swift Testing.

---

## File Structure

- Modify `Sources/VerityCore/Models/VerityModels.swift`: Add model readiness and derived summary helpers.
- Modify `Sources/VerityCore/Stores/LibraryStore.swift`: Add template result selection helpers and extracted-field citation source resolution.
- Modify `Tests/VerityCoreTests/DocumentPipelineTests.swift`: Add tests for model readiness, evaluation metrics, and template source resolution.
- Modify `Sources/Verity/Views/TemplatesView.swift`: Add template run history, result metadata, selected run state, and clickable field citations.
- Modify `Sources/Verity/Views/EvaluationView.swift`: Add answer-rate dashboard and cleaner item rows.
- Modify `Sources/Verity/Views/SettingsCenterView.swift`: Add local AI readiness panel and clearer grouped product settings.
- Modify `Sources/Verity/Views/ChatView.swift`: Polish chat empty and citation presentation while keeping current behavior.
- Modify `Sources/Verity/App/VerityApp.swift`: Add native commands for import-adjacent and workflow actions where store APIs exist.

## Task 1: Core Product State

- [ ] Write Swift Testing tests for `ModelSettings.readiness`, `EvaluationReport` summary metrics, and `LibraryStore.sourceReference(for:)` using extracted field citations.
- [ ] Run focused tests and verify they fail before production changes.
- [ ] Add `ModelReadiness`, `ModelSettings.readiness`, `EvaluationReport` count/rate helpers, and `LibraryStore.sourceReference(for:)` overload for `ExtractedField`.
- [ ] Run focused tests and verify they pass.

## Task 2: Template Workflow UI

- [ ] Add selected result state to `TemplatesView`.
- [ ] Render a native run-history sidebar section from `store.templateResults`.
- [ ] Show selected run metadata and cited-field count above the field table.
- [ ] Make citation cells buttons when a citation can resolve to a source.
- [ ] Reuse `DocumentViewerView` in an `HSplitView` inspector area for selected field citations.

## Task 3: Evaluation and Settings UI

- [ ] Add evaluation summary cards for total checks, answered checks, not-found checks, and answer rate.
- [ ] Improve evaluation rows with compact status and citation snippets.
- [ ] Replace thin local-engine settings with a readiness panel showing status, runtime, language model, embedding model, hardware, and fallback guidance.
- [ ] Preserve privacy/data controls and destructive delete behavior.

## Task 4: Chat and App Chrome Polish

- [ ] Refine chat empty state, scope status, message cards, and citation cards using semantic SwiftUI colors/materials.
- [ ] Add command entries for New Chat, Summarize, Run Evaluation, and Open Settings where supported by current store state.
- [ ] Keep keyboard shortcuts discoverable and non-conflicting.

## Task 5: Verification

- [ ] Run focused Swift tests for the new core behavior.
- [ ] Run `swift build`.
- [ ] If feasible, run `swift test`; if SwiftPM hangs, capture the process evidence and report the blocker clearly.

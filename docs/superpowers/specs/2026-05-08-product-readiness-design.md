# Verity Product Readiness Design

## Goal

Turn Verity from a working local-first scaffold into a more product-grade native macOS document assistant by improving premium UI states, template workflow depth, evaluation review, and local AI setup visibility.

## Scope

This pass keeps the current architecture intact. `VerityCore` owns durable workflow state, summaries, and source-resolution helpers. SwiftUI views consume those models through the existing `LibraryStore` and remain native macOS surfaces built around `NavigationSplitView`, `HSplitView`, `List`, `Table`, `Form`, and `ContentUnavailableView`.

## Product Behavior

The app should feel clear and trustworthy before any production cloud or paid integrations exist. Empty states should explain the next local action. Loading/error states should be visible where existing asynchronous work exists, especially imports. Template runs should be reviewable after creation rather than immediately replaced by the latest table. Citations in extracted fields should open the same in-app source viewer used by chat citations. Evaluation should show a quick answer-rate summary before listing individual checks. Local AI settings should be honest about whether Verity is using deterministic fallback behavior or a configured MLX runtime.

## Feature Areas

### Premium macOS UI

- Refine chat, document library, template, evaluation, and settings surfaces with native materials, compact status cards, and better empty states.
- Add command and keyboard paths for common actions where the existing store supports them.
- Keep sidebar rows native and lightweight.
- Avoid fake activity indicators for synchronous deterministic work.

### Workflow Depth

- Template runs become selectable history.
- Each run shows metadata: template name, document count, field count, cited field count, and timestamp.
- Extracted field citations can resolve to `SourceReference`.
- CSV export should still export all retained runs.

### Local AI Setup

- `ModelSettings` should expose a readiness status derived from runtime/mode fields.
- Settings should clearly show fallback, MLX-ready, needs-model, and unavailable states without pretending to download models.
- The default state should be honest: lexical retrieval and deterministic extraction are available, MLX is an extension path.

### Evaluation Review

- `EvaluationReport` should expose answered count, not-found count, total count, and answer rate.
- Evaluation UI should show those metrics above the detailed questions.

## Acceptance Criteria

- Core model helpers are covered by Swift tests.
- Template history can be selected in the UI and field citations can open the source viewer.
- Evaluation view shows summary metrics and preserves detailed item review.
- Settings view shows model readiness with explicit fallback/extension language.
- The app builds with `swift build`.

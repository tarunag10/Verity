# Feature Wave Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up the next Verity feature wave: local model setup readiness, OCR scaffolding, custom templates, citation passage highlighting, and document collections/projects.

**Architecture:** Add new Codable domain models in `VerityCore`, persist them through `LibraryStore`, cover the logic with Swift Testing tests, and expose first native macOS setup surfaces in SwiftUI. Production integrations remain honest scaffolds until real OCR/model-download services are wired.

**Tech Stack:** Swift 6.2, SwiftPM, SwiftUI, Swift Testing, existing VerityCore/Verity app targets.

---

## Task 1: Core Feature Models

- [x] Add tests for collections, custom templates, source highlights, OCR settings, and model setup readiness in `Tests/VerityCoreTests/DocumentPipelineTests.swift`.
- [x] Add `DocumentCollection`, `CustomTemplateDefinition`, `SourceHighlight`, `OCRSettings`, `OCRStatus`, `ModelSetupState`, and `ModelSetupStatus` in `Sources/VerityCore/Models/VerityModels.swift`.
- [x] Add `TemplateRunResult.customTemplateID` so custom workflow runs remain distinguishable from built-in template runs.
- [x] Typecheck VerityCore directly with `swiftc -typecheck`.

## Task 2: Store Persistence and Workflow APIs

- [x] Persist collections, custom templates, OCR settings, and model setup state in `LibraryStore`.
- [x] Add collection APIs: create, add/remove document, resolve document scope.
- [x] Add custom template APIs: save and run custom templates.
- [x] Add citation highlight computation in `sourceReference(for:)`.
- [x] Typecheck VerityCore directly with `swiftc -typecheck`.

## Task 3: Native Setup Surfaces

- [x] Add Collections navigation and a native `CollectionsView`.
- [x] Add custom template creation/selection to `TemplatesView`.
- [x] Add model download/cache and OCR adapter readiness to `SettingsCenterView`.
- [x] Add highlight metadata display to `DocumentViewerView`.

## Task 4: Verification

- [x] Run direct VerityCore typecheck with `swiftc`.
- [x] Run direct SwiftUI app-layer typecheck with a locally emitted `VerityCore` module.
- [x] Run a temporary feature-wave smoke executable that imports documents, creates a collection, runs a custom template, resolves citation highlight metadata, and checks OCR/model setup defaults.
- [ ] Run SwiftPM focused tests if the local SwiftPM runner is not stalled.
- [ ] Run app build if the local SwiftPM/Xcode build runner is available.

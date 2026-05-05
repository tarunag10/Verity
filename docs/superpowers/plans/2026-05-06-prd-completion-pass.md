# PRD Completion Pass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the remaining PRD surfaces into the Verity app as a complete local-first product scaffold: templates, structured extraction, CSV export, folder import, OCR/sync/model/license settings, and evaluation tooling.

**Architecture:** Keep real local functionality in `VerityCore` and product workflow surfaces in SwiftUI. Production-only integrations from the PRD, such as MLX generation, paid licensing, OCR engines, and encrypted sync, are represented by durable settings, statuses, and extension points without pretending external services exist.

**Tech Stack:** Swift 6.2, SwiftPM, SwiftUI, AppKit, PDFKit, Swift Testing.

---

## File Structure

- Modify `Sources/VerityCore/Models/VerityModels.swift`: Add template, extraction, evaluation, sync, license, and model settings models.
- Create `Sources/VerityCore/Services/TemplateEngine.swift`: Built-in templates, deterministic field extraction with citations, CSV export.
- Create `Sources/VerityCore/Services/EvaluationEngine.swift`: Local retrieval quality checks for sample questions.
- Modify `Sources/VerityCore/Stores/LibraryStore.swift`: Add template results, folder import, template runs, CSV export, settings persistence, and evaluation methods.
- Modify `Tests/VerityCoreTests/DocumentPipelineTests.swift`: Add TDD tests for built-in templates, extraction with citations, CSV export, folder import, and evaluation.
- Modify `Sources/Verity/Views/ContentView.swift`: Add navigation destinations for templates, evaluation, and settings.
- Modify `Sources/Verity/Views/SidebarView.swift`: Add native sidebar rows for Templates, Evaluation, and Settings.
- Modify `Sources/Verity/Views/DocumentListView.swift`: Add folder import support.
- Create `Sources/Verity/Views/TemplatesView.swift`: Template picker, document selector, extraction table, CSV export.
- Create `Sources/Verity/Views/EvaluationView.swift`: Local evaluation screen for PRD quality checks.
- Create `Sources/Verity/Views/SettingsCenterView.swift`: Model, sync, OCR, license, privacy, data controls, and trust/safety settings in one dashboard.
- Modify `README.md`: Update feature coverage and explicit integration boundaries.

## Task 1: Template and Extraction Core

- [ ] **Step 1: Write failing tests**

Add tests named `builtInTemplatesIncludeInvoiceAndContract`, `invoiceTemplateExtractsFieldsWithCitations`, and `templateResultExportsCSV`.

- [ ] **Step 2: Verify RED**

Run: `swift test --filter DocumentPipelineTests/builtInTemplatesIncludeInvoiceAndContract`

Expected: FAIL because `TemplateEngine` does not exist.

- [ ] **Step 3: Implement models and engine**

Add built-in templates for invoice, contract, manual, research paper, policy review, key dates, and compare documents. Implement deterministic field extraction from chunks and CSV export with proper escaping.

- [ ] **Step 4: Verify GREEN**

Run the three new template tests and expect PASS.

## Task 2: Store Workflows

- [ ] **Step 1: Write failing store tests**

Add tests named `folderImportIndexesSupportedFiles` and `evaluationFlagsAnsweredAndUnansweredQuestions`.

- [ ] **Step 2: Verify RED**

Run the two tests and expect missing API failures.

- [ ] **Step 3: Implement store methods**

Add recursive folder import for supported file types, template run storage, CSV export, and local evaluation methods.

- [ ] **Step 4: Verify GREEN**

Run the two store tests and expect PASS.

## Task 3: App Surfaces

- [ ] **Step 1: Add navigation**

Add Templates, Evaluation, and Settings rows to the sidebar and route them in `ContentView`.

- [ ] **Step 2: Build Templates UI**

Create a template workflow with built-in template picker, selected-document picker, extraction result table, citation snippets, and CSV export button.

- [ ] **Step 3: Build Evaluation UI**

Create a local quality dashboard that runs sample questions against the current library and shows answered/unanswered status.

- [ ] **Step 4: Build Settings Center**

Create a grouped settings dashboard for privacy, model management, OCR, sync, licensing, and data controls.

- [ ] **Step 5: Build**

Run: `swift build`

Expected: PASS.

## Task 4: Verification

- [ ] **Step 1: Run full tests**

Run: `swift test`

Expected: PASS.

- [ ] **Step 2: Run build**

Run: `swift build`

Expected: PASS.

- [ ] **Step 3: Smoke launch**

Run `./script/build_and_run.sh` briefly, then stop it.

Expected: product builds and launches without setup errors.

# Citation Source Viewer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users click a citation and inspect the original source in an in-app side-by-side document viewer with page/context metadata and an external-open fallback.

**Architecture:** Add a small core `SourceReference` model and `LibraryStore` resolver so citation click behavior is testable outside SwiftUI. The macOS app keeps chat state in `ChatView`, shows a side-by-side `HSplitView`, and renders PDF files through `PDFKit` while text-like documents show citation context plus searchable source text.

**Tech Stack:** Swift 6.2, SwiftPM, SwiftUI, AppKit, PDFKit, XCTest/Swift Testing.

---

## File Structure

- Modify `Sources/VerityCore/Models/VerityModels.swift`: Add `SourceReference` for document URL, file type, page number, citation snippet, and display title.
- Modify `Sources/VerityCore/Stores/LibraryStore.swift`: Add `sourceReference(for:)` and clear selected citations when deleting documents.
- Modify `Tests/VerityCoreTests/DocumentPipelineTests.swift`: Add tests for resolving citation sources and returning nil after document deletion.
- Create `Sources/Verity/Views/DocumentViewerView.swift`: Native source viewer with PDFKit-backed PDF display, text preview, citation context, search within document, and external-open button.
- Modify `Sources/Verity/Views/ChatView.swift`: Replace external-only citation opening with in-app source selection and side-by-side chat/viewer layout.

## Task 1: Source Reference Model

**Files:**
- Modify: `Tests/VerityCoreTests/DocumentPipelineTests.swift`
- Modify: `Sources/VerityCore/Models/VerityModels.swift`
- Modify: `Sources/VerityCore/Stores/LibraryStore.swift`

- [ ] **Step 1: Write failing resolver test**

Add a Swift Testing test named `resolvesCitationSourceReference` that imports a temporary text file, asks a question, extracts the first assistant citation, calls `store.sourceReference(for:)`, and expects the source title, file URL, page number, and snippet to match the citation.

- [ ] **Step 2: Verify RED**

Run: `swift test --filter DocumentPipelineTests/resolvesCitationSourceReference`

Expected: FAIL because `sourceReference(for:)` and `SourceReference` do not exist.

- [ ] **Step 3: Implement model and resolver**

Add `SourceReference` to `VerityModels.swift`. Add `LibraryStore.sourceReference(for:) -> SourceReference?` that finds the cited document and returns its URL, title, file type, page, and snippet.

- [ ] **Step 4: Verify GREEN**

Run: `swift test --filter DocumentPipelineTests/resolvesCitationSourceReference`

Expected: PASS.

## Task 2: Deletion Safety

**Files:**
- Modify: `Tests/VerityCoreTests/DocumentPipelineTests.swift`
- Modify: `Sources/VerityCore/Stores/LibraryStore.swift`

- [ ] **Step 1: Write failing deletion test**

Add a test named `deletedDocumentCitationCannotResolve` that imports a document, creates a citation, deletes the document, and expects `sourceReference(for:)` to return nil.

- [ ] **Step 2: Verify RED**

Run: `swift test --filter DocumentPipelineTests/deletedDocumentCitationCannotResolve`

Expected: FAIL until deletion and resolver behavior are correct.

- [ ] **Step 3: Implement deletion-safe resolver**

Ensure `sourceReference(for:)` only resolves existing documents and `deleteDocument(id:)` removes related chunks.

- [ ] **Step 4: Verify GREEN**

Run: `swift test --filter DocumentPipelineTests/deletedDocumentCitationCannotResolve`

Expected: PASS.

## Task 3: In-App Document Viewer

**Files:**
- Create: `Sources/Verity/Views/DocumentViewerView.swift`
- Modify: `Sources/Verity/Views/ChatView.swift`

- [ ] **Step 1: Implement viewer surface**

Create a `DocumentViewerView` that accepts `SourceReference` and includes a header, page/snippet context card, search field, external-open button, and body renderer.

- [ ] **Step 2: Implement PDF renderer**

Use `NSViewRepresentable` around `PDFView`; load `PDFDocument(url:)`, enable auto-scaling, and navigate to `pageNumber - 1` when present.

- [ ] **Step 3: Implement text renderer**

For non-PDF files, read UTF-8 or attributed RTF text, filter by search query when provided, and show citation snippet prominently above the full text.

- [ ] **Step 4: Wire chat citation clicks**

In `ChatView`, store a selected `SourceReference`, switch the detail body to `HSplitView`, and set the selected source when a citation button is clicked. Provide a close button so users can return to chat without losing state.

- [ ] **Step 5: Build**

Run: `swift build`

Expected: PASS.

## Task 4: Full Verification

**Files:**
- All modified files.

- [ ] **Step 1: Run full test suite**

Run: `swift test`

Expected: PASS.

- [ ] **Step 2: Run full build**

Run: `swift build`

Expected: PASS.

- [ ] **Step 3: Smoke run launch**

Run: `./script/build_and_run.sh` briefly and stop after confirming the product builds and launches.

Expected: executable starts without setup errors.

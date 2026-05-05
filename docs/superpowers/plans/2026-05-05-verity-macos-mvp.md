# Verity macOS MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a working local-first macOS MVP scaffold for Verity with document import, local parsing/chunking, search/retrieval, cited chat responses, privacy settings, and a reproducible SwiftPM setup.

**Architecture:** The project is a SwiftPM package with a reusable `VerityCore` library and a SwiftUI `Verity` executable. Core owns document models, parsing, chunking, local retrieval, answer generation, and persistence; the app layer owns native macOS navigation, import, chat, citations, settings, and run integration.

**Tech Stack:** Swift 6.2, SwiftPM, SwiftUI, AppKit, PDFKit, XCTest.

---

## File Structure

- Create `Package.swift`: Defines `VerityCore`, `Verity`, and `VerityCoreTests`.
- Create `Sources/VerityCore/Models/VerityModels.swift`: Codable domain models for documents, chunks, citations, chat, privacy, and model settings.
- Create `Sources/VerityCore/Services/DocumentParser.swift`: Extracts text from PDF, TXT, Markdown, and RTF-like files with metadata.
- Create `Sources/VerityCore/Services/DocumentChunker.swift`: Splits parsed pages into citation-preserving chunks.
- Create `Sources/VerityCore/Services/LocalRAGEngine.swift`: Builds an in-memory local index, searches chunks, summarizes documents, and creates cited extractive answers.
- Create `Sources/VerityCore/Stores/LibraryStore.swift`: Main-actor observable library state with import, delete, chat, search, and JSON persistence.
- Create `Sources/Verity/App/VerityApp.swift`: SwiftUI app entry point, commands, and settings scene.
- Create `Sources/Verity/Views/ContentView.swift`: Root `NavigationSplitView` app shell.
- Create `Sources/Verity/Views/SidebarView.swift`: Library/document/chats/settings navigation.
- Create `Sources/Verity/Views/DocumentListView.swift`: Import, document status, search, and selected document controls.
- Create `Sources/Verity/Views/ChatView.swift`: Cited chat interface with scope controls and prompt composer.
- Create `Sources/Verity/Views/PrivacySettingsView.swift`: Local-first privacy and model setup dashboard.
- Create `Sources/Verity/Support/AppEnvironment.swift`: Shared app storage path helper.
- Create `Tests/VerityCoreTests/DocumentPipelineTests.swift`: Tests for parsing, chunking, search, cited chat, and deletion.
- Create `script/build_and_run.sh`: Builds and runs the SwiftPM executable.
- Create `.codex/environments/environment.toml`: Codex app run-button integration.
- Create `.gitignore`: SwiftPM and macOS ignored files.
- Create `README.md`: Setup, run, test, and MVP boundary documentation.

## Task 1: Package Scaffold

**Files:**
- Create: `Package.swift`
- Create: `.gitignore`
- Create: `README.md`
- Create: `script/build_and_run.sh`
- Create: `.codex/environments/environment.toml`

- [ ] **Step 1: Write package manifest**

Create a package with `VerityCore` as a library target, `Verity` as an executable target, and `VerityCoreTests` as a test target. Require macOS 14 or newer and use Swift 6 language mode.

- [ ] **Step 2: Add local run wiring**

Add a shell script that runs `swift run Verity` from the project root and make it executable. Add the Codex environment file pointing to that script.

- [ ] **Step 3: Verify package graph**

Run: `swift package describe`

Expected: output lists `VerityCore`, `Verity`, and `VerityCoreTests`.

## Task 2: Core Models and Parser Tests

**Files:**
- Create: `Sources/VerityCore/Models/VerityModels.swift`
- Create: `Sources/VerityCore/Services/DocumentParser.swift`
- Create: `Tests/VerityCoreTests/DocumentPipelineTests.swift`

- [ ] **Step 1: Write failing parser test**

Add a test that writes a temporary Markdown file, parses it, and expects document metadata, one parsed page, selectable text status, and ready status.

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter DocumentPipelineTests/parsesMarkdownFileWithMetadata`

Expected: FAIL because `DocumentParser` and models do not exist yet.

- [ ] **Step 3: Implement models and parser**

Implement document identifiers, metadata, parsed pages, parsed documents, document status, and `DocumentParser.parse(fileURL:)`. TXT and Markdown should read UTF-8 text. RTF should use `NSAttributedString`. PDF should use PDFKit and preserve page numbers.

- [ ] **Step 4: Run parser test**

Run: `swift test --filter DocumentPipelineTests/parsesMarkdownFileWithMetadata`

Expected: PASS.

## Task 3: Chunking and Search

**Files:**
- Create: `Sources/VerityCore/Services/DocumentChunker.swift`
- Create: `Sources/VerityCore/Services/LocalRAGEngine.swift`
- Modify: `Tests/VerityCoreTests/DocumentPipelineTests.swift`

- [ ] **Step 1: Write failing chunk/search tests**

Add tests that chunk a parsed document with page references and search for a query that should rank the matching chunk first.

- [ ] **Step 2: Run tests to verify they fail**

Run: `swift test --filter DocumentPipelineTests/chunksPreservePageReferences`

Run: `swift test --filter DocumentPipelineTests/searchRanksRelevantChunksFirst`

Expected: FAIL because chunking and search do not exist yet.

- [ ] **Step 3: Implement chunker and local retrieval**

Implement paragraph-aware chunking, tokenization, stopword filtering, term overlap scoring, and result snippets with citation metadata.

- [ ] **Step 4: Run chunk/search tests**

Run: `swift test --filter DocumentPipelineTests/chunksPreservePageReferences`

Run: `swift test --filter DocumentPipelineTests/searchRanksRelevantChunksFirst`

Expected: PASS.

## Task 4: Cited Answers, Summaries, and Store

**Files:**
- Create: `Sources/VerityCore/Stores/LibraryStore.swift`
- Modify: `Sources/VerityCore/Services/LocalRAGEngine.swift`
- Modify: `Tests/VerityCoreTests/DocumentPipelineTests.swift`

- [ ] **Step 1: Write failing answer/store tests**

Add tests that asking a question returns an answer with citations, unknown answers say the documents do not contain enough information, and deleting a document removes its chunks.

- [ ] **Step 2: Run tests to verify they fail**

Run: `swift test --filter DocumentPipelineTests/answersQuestionsWithCitations`

Run: `swift test --filter DocumentPipelineTests/unknownAnswersAreHonest`

Run: `swift test --filter DocumentPipelineTests/deletingDocumentRemovesIndexData`

Expected: FAIL because answer generation and store behavior are incomplete.

- [ ] **Step 3: Implement answer generation and store**

Implement extractive answer generation from top chunks, citations, summary creation, import/delete, search, chat state, and JSON persistence.

- [ ] **Step 4: Run answer/store tests**

Run: `swift test --filter DocumentPipelineTests/answersQuestionsWithCitations`

Run: `swift test --filter DocumentPipelineTests/unknownAnswersAreHonest`

Run: `swift test --filter DocumentPipelineTests/deletingDocumentRemovesIndexData`

Expected: PASS.

## Task 5: SwiftUI macOS App

**Files:**
- Create: `Sources/Verity/App/VerityApp.swift`
- Create: `Sources/Verity/Views/ContentView.swift`
- Create: `Sources/Verity/Views/SidebarView.swift`
- Create: `Sources/Verity/Views/DocumentListView.swift`
- Create: `Sources/Verity/Views/ChatView.swift`
- Create: `Sources/Verity/Views/PrivacySettingsView.swift`
- Create: `Sources/Verity/Support/AppEnvironment.swift`

- [ ] **Step 1: Implement app shell**

Create a `WindowGroup` app with a shared `LibraryStore`, `NavigationSplitView`, sidebar selection, document list, chat detail, toolbar import command, settings scene, and native adaptive macOS colors.

- [ ] **Step 2: Implement chat and citation UX**

Add a scope picker, prompt composer, cited answer cards, copy/export affordance, citation buttons that open source files through `NSWorkspace`, and an empty state.

- [ ] **Step 3: Implement privacy dashboard**

Show local-only status, storage location, sync disabled by default, telemetry opt-in state, OCR Pro placeholder, and model runtime placeholder for MLX integration.

- [ ] **Step 4: Build app**

Run: `swift build`

Expected: PASS.

## Task 6: Full Verification

**Files:**
- All project files.

- [ ] **Step 1: Run full tests**

Run: `swift test`

Expected: PASS.

- [ ] **Step 2: Run package build**

Run: `swift build`

Expected: PASS.

- [ ] **Step 3: Smoke run app executable briefly**

Run: `timeout 5 ./script/build_and_run.sh` if `timeout` exists, otherwise `swift run Verity` and stop after confirming it launches.

Expected: executable starts without compile/runtime setup errors.

- [ ] **Step 4: Review MVP coverage**

Confirm the app implements the PRD MVP foundations: local library, import, parsing, chunking, local retrieval, cited chat, summaries, search, privacy controls, and extension points for MLX/OCR/sync/licensing.

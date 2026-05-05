# PRD: Verity

## Recommended App Name

**Verity**

**Why it works:** Verity means truth and accuracy, which fits a private document assistant that answers from source material with citations. It sounds trustworthy, polished, and professional without feeling too technical.

### Backup Name Options

1. **Docwise** — clear, approachable, and document-focused.
2. **Papertrail AI** — strong fit for cited answers and document traceability.
3. **Vaultnote** — emphasizes private, local knowledge.
4. **Citewise** — highlights citation-backed answers.
5. **Folio** — simple, elegant, and document-native.
6. **Clause** — great if the product leans heavily into contracts and business documents.
7. **Ledgerly** — strong if invoices, receipts, and business records become the main wedge.

---

# Product Requirements Document: Verity

## 1. Product Summary

### Product Name
Verity

### Product Category
Local-first private document assistant for macOS.

### One-line Description
Verity is a privacy-first Mac app that lets users chat with PDFs, notes, documents, invoices, contracts, manuals, and scanned files using a local, open-source RAG engine optimized for Apple Silicon with MLX.

### Product Concept
Verity turns a user’s private document collection into a local AI assistant. Users can import files, ask natural-language questions, receive cited answers, summarize documents, extract structured information, compare files, and search across their knowledge base without sending private content to third-party servers by default.

The product combines two layers:

1. **Open-source RAG engine for MLX**
   - Local document processing.
   - Local embeddings.
   - Local retrieval.
   - Local answer generation.
   - Citation mapping.
   - CLI and SDK for developers.

2. **Paid Mac app**
   - Native document library.
   - Chat interface.
   - PDF viewer.
   - Search.
   - Summaries.
   - OCR.
   - Sync.
   - Templates.
   - Structured extraction.
   - Polished onboarding and billing.

The Standard paid app focuses on private local document chat. The Pro plan unlocks advanced OCR, optional encrypted sync, reusable templates, batch workflows, and advanced extraction.

---

## 2. Background and Opportunity

People store valuable information in scattered private documents: PDFs, contracts, invoices, product manuals, receipts, research papers, policies, forms, notes, meeting exports, and local folders.

Existing AI document tools are useful, but many require users to upload sensitive files to cloud services. That creates privacy, confidentiality, compliance, and trust concerns.

Verity addresses this by offering a local-first document assistant that runs on the user’s Mac. It gives users the usefulness of AI document chat while keeping private files under their control.

The open-source RAG engine creates trust and developer credibility. The paid Mac app packages that engine into a polished product that non-technical users can use immediately.

---

## 3. Product Vision

Verity becomes the trusted private AI layer for personal and professional documents on the Mac.

The product should help users answer:

> “What do my documents say, and where exactly do they say it?”

Long term, Verity can evolve from local document chat into a private document workflow platform with local automations, structured extraction, private search, document monitoring, and team-ready privacy controls.

---

## 4. Target Platforms

### Primary Platform
macOS desktop app.

### Initial Device Focus
Apple Silicon Macs, because MLX is optimized for Apple hardware and provides strong local inference performance.

### Future Platforms
- iOS companion app for capture, reading, and lightweight chat.
- iPadOS app for document review and annotation.
- Windows desktop app if the RAG engine supports additional runtimes.
- Web companion only if privacy guarantees remain clear and optional.

---

## 5. Product Goals

## 5.1 Business Goals

1. Build a high-trust paid Mac productivity app for private document AI.
2. Convert privacy-conscious professionals into paid users.
3. Establish the open-source MLX RAG engine as a credible local AI infrastructure project.
4. Create a sustainable Pro plan through high-value features: OCR, sync, templates, batch workflows, and structured extraction.
5. Build defensibility through privacy, local performance, source citations, native UX, and open-source adoption.

## 5.2 User Goals

1. Ask questions across private documents without uploading them to cloud AI tools.
2. Get answers with citations back to exact document pages or passages.
3. Summarize long documents quickly.
4. Extract key information from invoices, contracts, manuals, notes, and forms.
5. Organize files into searchable private libraries.
6. Use AI on scanned documents through OCR.
7. Reuse templates for repeated document workflows.
8. Trust that private files remain under user control.

## 5.3 Technical Goals

1. Deliver reliable local RAG using MLX on supported Macs.
2. Provide fast ingestion, chunking, embedding, indexing, retrieval, and cited answer generation.
3. Support common document formats in MVP and expand over time.
4. Keep a clean separation between open-source engine and paid app layer.
5. Make privacy controls visible and understandable.
6. Support optional sync without making cloud processing mandatory.

---

## 6. Non-goals

The initial product should not be:

1. A general-purpose chatbot unrelated to user documents.
2. A collaborative enterprise knowledge base.
3. A full document editor competing with Word, Google Docs, Notion, or Apple Notes.
4. A legal, tax, medical, or financial advisor.
5. A cloud-first AI assistant that requires upload to function.
6. A full document management system with approval routing, e-signature, or records retention in MVP.
7. A replacement for professional review of legal, tax, financial, medical, or regulated documents.

---

## 7. Target Users and Personas

## 7.1 Persona 1: Privacy-conscious Professional

### Profile
Consultant, founder, lawyer, accountant, analyst, recruiter, operator, or independent professional with sensitive documents.

### Needs
- Ask questions about contracts, invoices, proposals, policies, and client files.
- Avoid uploading confidential files to cloud AI tools.
- Quickly find clauses, dates, obligations, payment terms, risks, and summaries.

### Key Jobs
- “Summarize this contract.”
- “What are the renewal terms?”
- “Which invoices are unpaid?”
- “Find all documents that mention this client.”
- “What are the termination obligations?”

---

## 7.2 Persona 2: Researcher or Student

### Profile
Graduate student, academic researcher, analyst, independent learner, or technical reader.

### Needs
- Chat with papers, notes, manuals, books, reports, and lecture PDFs.
- Compare concepts across multiple documents.
- Extract citations and page references.
- Build study notes from source material.

### Key Jobs
- “What is the main argument of this paper?”
- “Compare these three reports.”
- “Find where this concept is explained.”
- “Create study notes from this chapter.”
- “What are the limitations of this study?”

---

## 7.3 Persona 3: Small Business Owner

### Profile
Owner, office manager, bookkeeper, or operations lead managing invoices, receipts, manuals, contracts, insurance documents, vendor agreements, and policies.

### Needs
- Turn messy folders into searchable knowledge.
- Extract structured details from financial and operational documents.
- Use templates for recurring business tasks.

### Key Jobs
- “Show me warranty terms for this equipment.”
- “Extract invoice number, amount, due date, and vendor.”
- “Which contracts renew this quarter?”
- “What does the manual say about troubleshooting this error?”
- “Summarize all vendor payment terms.”

---

## 7.4 Persona 4: Power User or Developer

### Profile
Technical user interested in local AI, open-source tooling, custom models, and private workflows.

### Needs
- Inspect and modify the RAG pipeline.
- Use local models and custom embeddings.
- Extend parsers, retrievers, and evaluators.
- Run the engine outside the Mac app.

### Key Jobs
- “Use my preferred local model.”
- “Change chunking settings.”
- “Run the open-source engine against my folder.”
- “Create a custom extraction template.”
- “Evaluate retrieval accuracy.”

---

## 8. Core User Problems

## 8.1 Private documents are hard to search semantically
File names and keyword search are not enough when users need meaning-based answers across long or messy documents.

## 8.2 Cloud AI tools create privacy concerns
Many users do not want to upload contracts, invoices, notes, financial documents, or confidential PDFs to third-party services.

## 8.3 Document answers need citations
Users need to verify generated answers against source documents, especially for contracts, manuals, invoices, and research.

## 8.4 Scanned and image-based PDFs are common
Many important files are not machine-readable. Without OCR, AI tools cannot process them reliably.

## 8.5 Repeated document tasks are tedious
Users repeatedly summarize, extract, compare, classify, and review similar document types.

---

## 9. Product Principles

1. **Private by default**  
   Documents stay local unless the user explicitly enables sync or cloud-related features.

2. **Cited, not magical**  
   Every answer based on documents should include clear source references.

3. **Native and simple**  
   The product should feel like a polished Mac app, not a developer demo.

4. **Fast enough for daily use**  
   Indexing, search, and chat should feel responsive on supported Macs.

5. **Open where it matters**  
   The RAG engine should be transparent, auditable, and extensible.

6. **Honest about uncertainty**  
   The assistant should say when a document does not contain enough information.

7. **Power without clutter**  
   Advanced settings should exist, but the default experience should remain simple.

---

## 10. Positioning

## 10.1 Primary Positioning
The private AI assistant for your documents, running locally on your Mac.

## 10.2 Secondary Positioning
An open-source MLX RAG engine packaged into a polished paid Mac app for chatting with PDFs, notes, docs, invoices, contracts, manuals, and scanned documents.

## 10.3 Differentiators

1. Local-first document chat.
2. Open-source RAG engine.
3. MLX optimization for Apple Silicon.
4. Strong citations and source grounding.
5. Native Mac experience.
6. Pro workflows for OCR, sync, templates, and extraction.
7. Privacy-forward pricing and UX.

---

## 11. Product Scope

## 11.1 MVP Scope

The MVP should prove that users can privately import documents, ask questions, receive cited answers, and trust the system.

MVP includes:
- macOS app.
- Local document library.
- PDF import.
- Text-based document parsing.
- Basic support for notes and common document formats.
- Local embeddings and vector index.
- Chat with one document.
- Chat with a collection.
- Citations to document, page, and passage.
- Basic summaries.
- Local model setup.
- Simple privacy controls.
- Paid license flow.

---

## 11.2 V1 Scope

V1 expands from useful document chat to daily productivity.

V1 includes:
- OCR as a Pro feature.
- Folder watching.
- Multiple libraries or workspaces.
- Saved chats.
- Templates for common tasks.
- Structured extraction.
- Better document comparison.
- Citation preview.
- Export answers.
- Optional encrypted sync as a Pro feature.

---

## 11.3 V2 Scope

V2 builds deeper workflow power.

V2 includes:
- Batch processing.
- Advanced extraction schemas.
- Rules and automations.
- Local document monitoring.
- Team or business edition.
- Plugin ecosystem around the open-source engine.
- More model backends beyond MLX.

---

## 12. Feature Overview

## 12.1 Free or Trial Experience

The free or trial experience should let users understand the core value before purchase.

Potential trial limits:
- Limited number of documents.
- Limited number of indexed pages.
- Limited number of chats per day.
- No OCR.
- No sync.
- No custom templates.
- Sample templates only.

---

## 12.2 Paid Standard App

The base paid Mac app should include:
- Local document chat.
- Local libraries.
- PDF and document import.
- Citations.
- Basic summaries.
- Local search.
- Saved chats.
- Manual re-indexing.
- Basic exports.
- Local-only privacy controls.

---

## 12.3 Pro Plan

The Pro plan should include:
- OCR for scanned PDFs and images.
- Optional encrypted sync.
- Templates.
- Batch template runs.
- Advanced extraction.
- Folder watching.
- Higher document or page limits if limits exist.
- Priority model and performance settings.
- Advanced local indexing controls.

---

## 13. Key User Flows

## 13.1 First-run Onboarding

1. User opens Verity for the first time.
2. App explains local-first privacy in plain language.
3. App checks Mac compatibility and local model requirements.
4. User chooses a recommended setup.
5. App creates a default local library.
6. User imports sample documents or their own files.
7. App indexes documents and shows progress.
8. User asks the first question.
9. App returns cited answer with source snippets.
10. User sees upgrade prompts only when reaching Pro-only features.

---

## 13.2 Chat with a PDF

1. User drags a PDF into the app.
2. App parses text and metadata.
3. App indexes the document locally.
4. User opens document chat.
5. User asks: “What are the termination terms?”
6. App retrieves relevant passages.
7. App answers with citations.
8. User clicks a citation.
9. App opens the PDF at the relevant page or passage.
10. User copies or exports the answer.

---

## 13.3 Chat Across a Collection

1. User creates a library called “Client Contracts.”
2. User adds multiple contracts.
3. App indexes all files.
4. User asks: “Which contracts renew in the next 90 days?”
5. App identifies relevant documents and passages.
6. App answers with a grouped list by document.
7. User clicks citations to verify each source.
8. User saves or exports the answer.

---

## 13.4 OCR a Scanned Document

1. User imports a scanned invoice PDF.
2. App detects low or missing text layer.
3. App explains OCR is required.
4. User activates Pro or starts Pro trial.
5. App runs OCR.
6. App indexes recognized text.
7. User asks questions or extracts fields.
8. App provides answers with page references.

---

## 13.5 Use a Template

1. User opens Templates.
2. User selects “Invoice Extraction.”
3. User chooses one or more invoice documents.
4. App extracts vendor, invoice number, date, due date, subtotal, tax, total, and payment terms.
5. App displays results in a table.
6. User reviews citations for each extracted field.
7. User exports to CSV or copies results.

---

## 13.6 Optional Sync

1. User opens Sync settings.
2. App explains what is synced.
3. App explains encryption and privacy model.
4. User chooses whether to sync full documents or only selected app data.
5. User signs in and enables sync.
6. App syncs selected libraries.
7. User can disable sync and remove cloud copies.

---

## 14. Functional Requirements

## 14.1 Document Import

### Requirements
- Users can import files by drag and drop.
- Users can import files through a file picker.
- Users can import folders.
- Users can create libraries or collections.
- Users can remove documents from libraries.
- Users can re-index documents manually.
- App detects duplicate files where feasible.
- App shows file status: imported, indexing, ready, failed, or OCR needed.

### Supported MVP File Types
- PDF with selectable text.
- Plain text.
- Markdown.
- DOCX if technically feasible.
- RTF if technically feasible.

### Later File Types
- Images.
- Scanned PDFs.
- CSV.
- XLSX.
- HTML.
- Email exports.
- EPUB.
- Apple Notes export or integration.

### Acceptance Criteria
- User can drag a text-based PDF into the app and ask a question about it.
- User can see whether import succeeded or failed.
- User can remove an imported document and its index data.
- User can import at least 100 medium-sized PDFs without corrupting the library.

---

## 14.2 Document Parsing

### Requirements
- Extract text from supported documents.
- Preserve page numbers for PDFs.
- Preserve metadata: file name, path, file type, creation date, modification date, page count, and import date.
- Detect poor text extraction quality.
- Detect image-only PDFs.
- Store parsed content locally.
- Split parsed content into chunks suitable for retrieval.

### Chunking Requirements
- Use default chunking tuned for document Q&A.
- Preserve document and page references in every chunk.
- Support configurable chunk size for advanced users.
- Avoid splitting tables and numbered clauses badly where possible.
- Maintain enough surrounding context for citations.

### Acceptance Criteria
- Parsed PDF chunks retain source document and page information.
- When a scanned PDF has no usable text, the app prompts for OCR.
- Retrieval can return citations pointing back to the original page.

---

## 14.3 Local Indexing and Embeddings

### Requirements
- Generate embeddings locally by default.
- Store embeddings locally.
- Build and maintain a local vector index per library.
- Support incremental indexing when new files are added.
- Support re-indexing after parser or embedding model changes.
- Surface indexing progress and failures.
- Avoid blocking the full UI during indexing.

### Acceptance Criteria
- App can index a 50-page PDF and make it searchable.
- App can index a folder without requiring cloud upload.
- App can recover from failed indexing and retry.
- User can see which documents are ready for chat.

---

## 14.4 Retrieval-Augmented Generation

### Requirements
- Retrieve relevant chunks based on user query.
- Generate answers grounded in retrieved document content.
- Provide citations for claims derived from documents.
- Allow user to ask follow-up questions in context.
- Support document-scoped and library-scoped chat.
- Detect when retrieved context is insufficient.
- Avoid fabricating information not present in documents.

### Retrieval Modes
- Single document.
- Selected documents.
- Entire library.
- Current folder or collection.
- Recent imports.

### Answer Modes
- Concise answer.
- Detailed answer.
- Summary.
- Compare documents.
- Extract structured fields.
- Explain simply.

### Acceptance Criteria
- Answers include citations when based on documents.
- Clicking a citation opens the source document location.
- The assistant states when the answer is not found in the selected documents.
- Follow-up questions preserve relevant conversation context.

---

## 14.5 Chat Interface

### Requirements
- User can start a chat with one document.
- User can start a chat with a library.
- User can select scope before asking.
- User can view citations inline.
- User can open source snippets.
- User can copy answers.
- User can regenerate answers.
- User can save chats.
- User can rename chats.
- User can delete chats.

### Important UX Details
- Chat should always show what document set is being used.
- Users should never wonder whether a file was included.
- Citations should be visually distinct and easy to inspect.
- The assistant should be transparent when it is using partial document context.

### Acceptance Criteria
- User can ask a question and receive a cited answer.
- User can change the scope from one document to a library.
- User can view previous chats.
- User can delete chat history locally.

---

## 14.6 Citation and Source Verification

### Requirements
- Every answer generated from documents should cite sources.
- Citation should include document name and page number where available.
- Citation should include a text snippet preview.
- User can open the citation in a document viewer.
- App should highlight the relevant source passage where possible.
- App should support multiple citations for multi-document answers.

### Citation Types
- PDF page citation.
- Text passage citation.
- Document-level citation when page information is unavailable.
- Field-level citation for structured extraction.

### Acceptance Criteria
- User can verify the source of an answer in one click.
- Extracted fields include source references.
- If no citation is available, the UI clearly marks the answer as uncited.

---

## 14.7 Document Viewer

### Requirements
- Built-in PDF viewer for source verification.
- Support opening source file in the system default app.
- Show page number and citation context.
- Support search within current document.
- Support side-by-side chat and document view.

### Acceptance Criteria
- Clicking a citation opens the document viewer at the relevant page.
- User can navigate around the cited page.
- User can return to chat without losing state.

---

## 14.8 Search

### Requirements
- Keyword search across imported documents.
- Semantic search across imported documents.
- Filter search results by document type, library, date, and file name.
- Search result snippets should show source context.
- Search should work independently of chat.

### Acceptance Criteria
- User can search for a term and get matching documents.
- User can search semantically and find related passages without exact keywords.
- User can click a result to open the relevant document.

---

## 14.9 Summarization

### Requirements
- Summarize a single document.
- Summarize selected documents.
- Produce short, medium, and detailed summaries.
- Include cited references for important claims.
- Support summary templates such as executive summary, risks, action items, key dates, and obligations.

### Acceptance Criteria
- User can generate a summary of a PDF.
- Summary includes source references where appropriate.
- User can copy or export the summary.

---

## 14.10 Structured Extraction

### Requirements
- Extract structured fields from documents.
- Provide citations per extracted field.
- Support common document types: invoices, contracts, manuals, receipts, policies, and research papers.
- Display extracted results in a table.
- Allow export to CSV.
- Allow user to edit extracted values manually.

### MVP Extraction Examples
- Invoice: vendor, invoice number, invoice date, due date, total, currency, payment terms.
- Contract: parties, effective date, renewal date, termination terms, governing law, payment terms.
- Manual: product name, model, troubleshooting steps, warnings, warranty terms.
- Research paper: title, authors, abstract, methods, findings, limitations.

### Acceptance Criteria
- User can run an extraction template on one document.
- Extracted fields include citations.
- User can export results.

---

## 14.11 Templates

### Plan Placement
Templates are a Pro feature.

### Requirements
- Provide built-in templates for common workflows.
- Allow users to create custom templates.
- Allow templates to define output format.
- Support prompts, fields, instructions, and examples.
- Support running templates on one or many documents.
- Save template results.

### Built-in Template Ideas
1. Contract Review.
2. Invoice Extraction.
3. Receipt Summary.
4. Manual Troubleshooting.
5. Research Paper Summary.
6. Policy Review.
7. Meeting Notes Summary.
8. Key Dates and Deadlines.
9. Risk and Obligation Finder.
10. Compare Documents.

### Acceptance Criteria
- Pro user can select a template and run it on a document.
- Pro user can create and save a custom template.
- Template output can include structured fields and citations.

---

## 14.12 OCR

### Plan Placement
OCR is a Pro feature.

### Requirements
- Detect scanned PDFs and image-only pages.
- Offer OCR when needed.
- Run OCR locally where feasible.
- Preserve page references after OCR.
- Allow OCR result review.
- Support re-running OCR if quality is poor.
- Show OCR confidence or quality warnings where possible.

### OCR Inputs
- Scanned PDFs.
- Image files.
- Mixed PDFs with both text and image pages.

### Acceptance Criteria
- App detects when a PDF has no text layer.
- Pro user can OCR a scanned PDF.
- OCR text becomes searchable and usable in chat.
- Citations refer to the correct page.

---

## 14.13 Sync

### Plan Placement
Sync is a Pro feature.

### Requirements
- Sync must be optional.
- App must work without sync.
- User must explicitly enable sync.
- User can choose what to sync where feasible.
- Sync should use encryption at rest and in transit.
- Product must clearly explain privacy implications.
- User can disable sync and delete synced data.

### Sync Options
- App settings.
- Libraries.
- Chats.
- Templates.
- Documents.
- Indexes.

### Privacy UX Requirement
Before enabling sync, the app must clearly answer:
- What data leaves this Mac?
- Is document content synced?
- Is AI processing still local?
- Can the user delete synced copies?
- Is sync encrypted?

### Acceptance Criteria
- User can use the app without creating an account.
- Pro user can enable sync.
- User can disable sync.
- User can see which libraries are synced.

---

## 14.14 Privacy and Security Controls

### Requirements
- Local-only mode by default.
- Clear indicator when using local processing.
- Clear indicator when any cloud feature is active.
- Local document deletion should delete parsed text and embeddings.
- App should not train models on user documents.
- Telemetry should be minimal and opt-in where possible.
- Crash reports should not include document content.
- Sensitive logs should be avoided.
- Provide a privacy dashboard.

### Privacy Dashboard Should Show
- Local libraries.
- Storage location.
- Sync status.
- Model used.
- OCR mode.
- Telemetry status.
- Data deletion controls.

### Acceptance Criteria
- User can confirm whether documents are local-only.
- User can delete all local app data.
- User can disable telemetry.
- User can understand when a Pro cloud feature changes data handling.

---

## 14.15 Model Management

### Requirements
- Provide a recommended default local model setup.
- Detect hardware capability.
- Warn users when a selected model may be too slow.
- Allow advanced users to choose compatible local models.
- Allow model download and management if bundled models are not shipped.
- Show model storage size.
- Allow removing downloaded models.

### Acceptance Criteria
- User can start with a recommended model without technical setup.
- Advanced user can change model settings.
- App gives useful feedback if local inference is unavailable or too slow.

---

## 14.16 Open-source RAG Engine

### Requirements
The RAG engine should be available as an open-source project separate from the paid Mac app.

It should include:
- Document loaders.
- Text extraction interfaces.
- Chunking pipeline.
- Embedding interface.
- Vector index interface.
- Retrieval strategies.
- Reranking support.
- Prompt assembly.
- Citation mapping.
- Evaluation tools.
- MLX model integration.
- CLI or SDK.

### Goals of Open Source
- Build developer trust.
- Allow auditing of core privacy-sensitive logic.
- Encourage community contributions for parsers and retrieval methods.
- Make the paid app feel less like a black box.
- Create adoption beyond the app itself.

### Boundaries Between Open Source and Paid App

#### Open-source engine
- RAG pipeline.
- MLX inference adapters.
- Local indexing primitives.
- Citation mapping.
- Evaluation harness.

#### Paid Mac app
- Native UI.
- License management.
- Pro OCR workflow.
- Sync.
- Templates UX.
- Batch workflows.
- App integrations.
- Polished onboarding.
- Support and updates.

---

## 15. Technical Architecture

## 15.1 High-level Architecture

The app should be composed of the following layers:

1. **Native Mac App Layer**
   - UI, onboarding, document library, chat, settings, payments, Pro features.

2. **Document Processing Layer**
   - File import, parsing, metadata extraction, OCR, chunking.

3. **RAG Engine Layer**
   - Embeddings, vector index, retrieval, reranking, prompt assembly, answer generation, citation mapping.

4. **Local Storage Layer**
   - Document metadata, parsed text, chunks, embeddings, index, chats, templates, settings.

5. **Optional Sync Layer**
   - Encrypted sync for selected data.

6. **Model Runtime Layer**
   - MLX-based local inference and embeddings.

---

## 15.2 Data Flow

### Import Flow
1. User imports file.
2. App stores file reference or local copy depending on settings.
3. Parser extracts text and metadata.
4. App detects whether OCR is needed.
5. Text is chunked.
6. Embeddings are generated locally.
7. Chunks and embeddings are stored in a local index.
8. Document status becomes ready.

### Chat Flow
1. User asks a question.
2. App identifies chat scope.
3. Query is embedded locally.
4. Vector retrieval returns candidate chunks.
5. Optional reranking improves relevance.
6. Prompt is assembled with retrieved context.
7. Local model generates answer.
8. Citation mapper links answer to chunks and documents.
9. UI displays answer and citations.

### OCR Flow
1. App detects image-only or low-text page.
2. User chooses OCR.
3. OCR produces text and confidence metadata.
4. OCR text is mapped to page numbers.
5. OCR output is chunked and indexed.
6. User can chat with OCR-derived content.

---

## 15.3 Storage Requirements

The app should store:
- Library metadata.
- Document metadata.
- Parsed text.
- OCR text.
- Chunk metadata.
- Embeddings.
- Vector indexes.
- Chat history.
- Templates.
- User settings.
- License state.

Storage should be local-first and transparent. Users should be able to inspect storage usage and delete app data.

---

## 15.4 Performance Requirements

### Import and Indexing
- A typical text-based PDF should begin indexing within seconds of import.
- Indexing progress should be visible.
- Large imports should run in the background without freezing the UI.
- Failed files should not block the whole library.

### Chat
- Initial answer latency should feel acceptable for local inference.
- Retrieval should be fast enough that generation, not search, is usually the bottleneck.
- The app should stream answers where feasible.

### Search
- Keyword and semantic search should return initial results quickly for medium-sized libraries.

### Hardware Adaptation
- App should detect memory and chip capability.
- App should recommend lighter models for lower-memory Macs.
- App should warn when a library or model may exceed practical local limits.

---

## 16. Non-functional Requirements

## 16.1 Reliability
- No document data loss during import or indexing.
- Failed indexing jobs should be recoverable.
- App should handle restarts during long indexing tasks.
- Corrupted indexes should not break the entire library.

## 16.2 Privacy
- Local-only by default.
- No document upload without explicit user action.
- No model training on user documents.
- Minimal telemetry.
- Clear data deletion.

## 16.3 Security
- Secure local storage where practical.
- Respect macOS sandboxing expectations.
- Use Keychain for credentials and license tokens.
- Encrypted sync for Pro sync.
- No sensitive document content in logs.

## 16.4 Accessibility
- Keyboard navigation for core workflows.
- VoiceOver support for primary UI.
- Sufficient contrast.
- Resizable text where feasible.
- Clear status messages.

## 16.5 Maintainability
- Modular RAG engine.
- Testable parser, chunker, retriever, and citation components.
- Clear separation between open-source and proprietary layers.
- Versioned index schema.

---

## 17. UX Requirements

## 17.1 Navigation Structure

Recommended primary navigation:
- Library.
- Chat.
- Search.
- Templates.
- Imports / Activity.
- Settings.

## 17.2 Main Screens

1. Onboarding.
2. Library view.
3. Document detail view.
4. Chat view.
5. Search view.
6. Template gallery.
7. Template run results.
8. OCR review screen.
9. Settings and privacy dashboard.
10. Sync settings.
11. Model settings.
12. Billing and plan screen.

## 17.3 UX Tone

The app should feel calm, trustworthy, and clear. It should avoid overpromising. It should use plain explanations for privacy, model behavior, and citations.

## 17.4 Empty States

Empty states should guide users toward useful first actions:
- “Drop in a PDF to ask questions privately.”
- “Create a library for contracts, invoices, manuals, or notes.”
- “Try asking: What are the key dates in this document?”

## 17.5 Error States

Error messages should explain the issue and next step:
- Unsupported file type.
- Failed parse.
- OCR required.
- Model not installed.
- Not enough memory.
- Index corrupted.
- Sync unavailable.
- License inactive.

---

## 18. Pricing and Packaging

## 18.1 Packaging Option A: Paid App + Pro Subscription

- One-time or annual paid app unlocks core local document chat.
- Pro subscription unlocks OCR, sync, templates, and advanced workflows.

## 18.2 Packaging Option B: Free Trial + Pro Subscription

- Free app with limited documents or pages.
- Pro unlocks unlimited or higher-limit usage, OCR, sync, and templates.

## 18.3 Recommended Initial Packaging

A simple free trial with a paid Standard license and optional Pro plan.

### Standard
For users who want local document chat:
- Local document import.
- Chat with PDFs and docs.
- Citations.
- Summaries.
- Local search.
- Saved chats.

### Pro
For users with heavier document workflows:
- OCR.
- Sync.
- Templates.
- Batch processing.
- Structured extraction.
- Folder watching.
- Advanced model and indexing controls.

## 18.4 Pricing Considerations

Pricing should communicate that this is productivity software, not just model access. Since local inference reduces variable AI costs, Pro should be justified by workflow value, sync infrastructure, OCR, templates, updates, and support.

---

## 19. Metrics and Success Criteria

## 19.1 Activation Metrics
- Percentage of users who import a document during first session.
- Percentage of users who ask first question.
- Time from install to first cited answer.
- Percentage of imported documents successfully indexed.

## 19.2 Engagement Metrics
- Weekly active users.
- Average chats per active user.
- Average documents imported per user.
- Search usage.
- Citation click-through rate.
- Template usage rate.

## 19.3 Quality Metrics
- Retrieval relevance score.
- Answer citation accuracy.
- Hallucination rate in evaluation set.
- OCR accuracy on test documents.
- Failed indexing rate.
- User-rated answer helpfulness.

## 19.4 Business Metrics
- Trial-to-paid conversion.
- Standard-to-Pro conversion.
- Pro retention.
- Churn reasons.
- Support tickets per active user.

## 19.5 Privacy Trust Metrics
- Percentage of users who keep local-only mode enabled.
- Percentage of users who open privacy dashboard.
- Sync enablement rate.
- Telemetry opt-in rate.
- Privacy-related support questions.

---

## 20. Evaluation Requirements

## 20.1 RAG Evaluation

The product needs a repeatable evaluation process for document QA quality.

Evaluation should measure:
- Whether retrieved chunks contain the answer.
- Whether generated answer matches source content.
- Whether citations support claims.
- Whether the assistant refuses when information is absent.
- Whether answers remain accurate across long documents.

## 20.2 Test Document Sets

Create internal benchmark sets for:
- Contracts.
- Invoices.
- Manuals.
- Research papers.
- Notes.
- Mixed libraries.
- Scanned PDFs.

## 20.3 Example Evaluation Questions

### Contracts
- What is the termination notice period?
- What is the governing law?
- Does the contract auto-renew?
- What are the payment obligations?

### Invoices
- What is the invoice total?
- What is the due date?
- Who is the vendor?
- What line items are listed?

### Manuals
- How do I troubleshoot error code X?
- What safety warnings are listed?
- What is the warranty period?

## 20.4 Required Evaluation Behavior

- If the answer is present, answer with citations.
- If the answer is not present, say it is not found.
- If the answer is ambiguous, explain ambiguity and cite relevant passages.

---

## 21. Trust, Safety, and Legal Considerations

## 21.1 Professional Advice Disclaimer
The app should avoid positioning itself as a substitute for professional advice. For contracts, finance, tax, health, or legal documents, the assistant should summarize and cite document contents but avoid making final professional judgments.

## 21.2 Sensitive Data
The app may process highly sensitive data including contracts, invoices, IDs, health-related documents, financial records, and confidential notes. Privacy, deletion, logging, and sync design are critical.

## 21.3 Generated Content Risk
The assistant may misread documents or generate incorrect answers. Citations, uncertainty language, and clear source previews reduce but do not eliminate this risk.

## 21.4 User Control
Users must be able to:
- Delete documents.
- Delete parsed text.
- Delete embeddings.
- Delete chats.
- Disable sync.
- Export their data where practical.

---

## 22. Launch Plan

## 22.1 Alpha

### Audience
Internal users, technical users, and trusted testers.

### Goals
- Validate local RAG engine.
- Test import and indexing reliability.
- Evaluate answer quality and citation accuracy.
- Collect feedback on local model performance.

### Alpha Scope
- PDF import.
- Local indexing.
- Single-document chat.
- Basic citations.
- Minimal settings.

---

## 22.2 Private Beta

### Audience
Privacy-conscious professionals, researchers, and small business users.

### Goals
- Validate onboarding.
- Test library-scale chat.
- Improve UX for citations.
- Test pricing willingness.
- Identify common document workflows.

### Beta Scope
- Multi-document libraries.
- Search.
- Saved chats.
- Better summaries.
- Initial templates.
- Basic OCR experiments.

---

## 22.3 Public Launch

### Audience
Broader Mac productivity market.

### Launch Scope
- Polished macOS app.
- Paid Standard plan.
- Pro plan with OCR and templates.
- Clear privacy messaging.
- Open-source RAG engine published.
- Documentation and examples.

---

## 23. MVP Requirements Checklist

## 23.1 Must Have
- Native Mac app.
- Import text-based PDFs.
- Local parsing and indexing.
- Local embeddings.
- Chat with one document.
- Chat with a library.
- Cited answers.
- Source preview.
- Basic document search.
- Basic summaries.
- Local-only privacy default.
- Model setup flow.
- Paid license support.

## 23.2 Should Have
- DOCX and Markdown support.
- Saved chats.
- Basic template examples.
- Folder import.
- Indexing activity view.
- Export answer to Markdown or text.

## 23.3 Could Have
- OCR preview.
- Folder watching.
- Advanced retrieval settings.
- Batch summaries.
- Custom templates.

## 23.4 Not MVP
- Full sync.
- Team collaboration.
- Mobile app.
- Complex automations.
- Enterprise admin console.

---

## 24. Detailed User Stories

## 24.1 Import and Library
- As a user, I want to drag documents into the app so I can start asking questions quickly.
- As a user, I want to organize documents into libraries so I can separate work, personal, research, and client files.
- As a user, I want to see indexing status so I know when a document is ready.
- As a user, I want to remove documents and associated AI data so I can control my private information.

## 24.2 Chat
- As a user, I want to ask a question about a PDF so I do not have to read the entire document.
- As a user, I want to ask across multiple documents so I can compare and synthesize information.
- As a user, I want follow-up questions to preserve context so the conversation feels natural.
- As a user, I want the app to say when an answer is not found so I do not rely on guesses.

## 24.3 Citations
- As a user, I want every answer to cite source passages so I can verify it.
- As a user, I want to click citations and open the original document so I can inspect the context.
- As a user, I want citations for extracted fields so I can trust structured results.

## 24.4 OCR
- As a user, I want scanned PDFs to become searchable so old paper documents are useful.
- As a user, I want to know when OCR quality is low so I can verify important answers manually.

## 24.5 Templates
- As a user, I want reusable templates so I can run the same review or extraction workflow repeatedly.
- As a user, I want invoice extraction to produce a table so I can export it.
- As a user, I want contract review templates so I can quickly find risks, dates, and obligations.

## 24.6 Sync
- As a user, I want optional sync so I can use libraries across Macs.
- As a privacy-conscious user, I want the app to work fully without sync.
- As a user, I want to understand what data leaves my device before enabling sync.

---

## 25. Open Questions

## 25.1 Product
1. Should the base product be one-time purchase, subscription, or both?
2. What limits should exist in the trial experience?
3. Should OCR be local-only, cloud-optional, or both?
4. Should templates be entirely Pro or should Standard include basic built-in templates?
5. Should the app copy imported documents into its library or reference them in place by default?

## 25.2 Technical
1. Which local embedding model should be the default?
2. Which local generation model should be recommended for different Mac hardware tiers?
3. What vector index should be used for local storage?
4. How should index migrations be handled as the engine improves?
5. How should the app handle extremely large PDFs or libraries?
6. What OCR stack should be used for speed, accuracy, and privacy?

## 25.3 Privacy and Sync
1. Should synced indexes be encrypted in a way that the provider cannot read?
2. Should users be able to sync metadata and chats without syncing documents?
3. Should the product support bring-your-own storage for sync?
4. How should deletion guarantees be communicated?

## 25.4 Open Source
1. What license should the RAG engine use?
2. Which parts of the app, if any, should be open source beyond the engine?
3. How should community contributions be reviewed?
4. Should the engine include example apps or only CLI and SDK examples?

---

## 26. Risks and Mitigations

## 26.1 Risk: Local model performance is too slow
### Mitigation
- Recommend hardware-specific models.
- Use streaming responses.
- Optimize retrieval and prompt size.
- Allow smaller models.
- Cache embeddings and indexes aggressively.

## 26.2 Risk: Answers are inaccurate or unsupported
### Mitigation
- Make citations central.
- Add retrieval and citation evaluation.
- Use refusal behavior when context is insufficient.
- Let users inspect source snippets quickly.
- Provide evidence indicators carefully.

## 26.3 Risk: Privacy promises are misunderstood
### Mitigation
- Use clear local/cloud indicators.
- Add privacy dashboard.
- Make sync opt-in.
- Avoid vague privacy claims.
- Document data handling plainly.

## 26.4 Risk: OCR is expensive or unreliable
### Mitigation
- Make OCR Pro.
- Start with clear scanned PDF detection.
- Offer quality warnings.
- Support page-level OCR retries.
- Prioritize common business scans first.

## 26.5 Risk: Open-source engine competes with paid app
### Mitigation
- Keep the engine open and valuable.
- Make the paid app win on polish, UX, sync, templates, OCR workflows, support, and reliability.
- Treat open source as adoption and trust channel.

## 26.6 Risk: App appears too technical
### Mitigation
- Hide advanced model controls by default.
- Use recommended setup.
- Provide document-oriented workflows.
- Avoid exposing RAG terminology in everyday UI.

---

## 27. Competitive Landscape

The product competes broadly with:
- Cloud document chat tools.
- PDF AI assistants.
- Knowledge-base AI tools.
- Local LLM apps.
- Note-taking tools with AI.
- Enterprise search tools.

Verity should not compete primarily on generic chatbot quality. It should compete on privacy, local-first design, citations, document workflows, native Mac polish, and the credibility of an open-source RAG engine.

---

## 28. Recommended MVP Definition

The first shippable version should focus on the core promise:

> Drop private PDFs into a Mac app, ask questions, and get cited answers locally.

### MVP Feature Set
1. macOS app.
2. Local library.
3. PDF import.
4. Text extraction.
5. Local indexing.
6. Local chat.
7. Cited answers.
8. Citation preview and PDF page opening.
9. Basic summaries.
10. Basic semantic search.
11. Privacy dashboard.
12. Paid license.
13. Open-source RAG engine release.

### MVP Exclusions
- Full OCR.
- Full sync.
- Advanced templates.
- Team collaboration.
- Mobile app.

### MVP Success Criteria
- A new user can install the app, import a PDF, ask a question, and verify a cited answer within the first session.
- The app works without uploading documents.
- Retrieval and citations are good enough that users trust the workflow for real documents.
- At least one target user segment shows willingness to pay.

---

## 29. Roadmap

## 29.1 Phase 0: Prototype
- CLI RAG engine.
- MLX model integration.
- PDF parsing.
- Local embeddings.
- Vector retrieval.
- Basic cited answers.

## 29.2 Phase 1: Alpha Mac App
- Native app shell.
- Document import.
- Single-document chat.
- Basic library.
- Citation display.
- Model setup.

## 29.3 Phase 2: Beta
- Multi-document chat.
- Search.
- Saved chats.
- Summaries.
- Document viewer.
- Better indexing status.
- Privacy dashboard.

## 29.4 Phase 3: Paid Launch
- Licensing.
- Polished onboarding.
- Public open-source engine.
- Standard paid app.
- Initial Pro plan.
- Documentation.

## 29.5 Phase 4: Pro Expansion
- OCR.
- Templates.
- Batch extraction.
- Folder watching.
- Optional sync.
- Export workflows.

## 29.6 Phase 5: Advanced Workflows
- Automations.
- Monitoring.
- Custom schemas.
- Team edition exploration.
- Plugin ecosystem.

---

## 30. Final Product Definition

Verity is a paid Mac app for people who need AI help with sensitive documents but do not want to upload them to cloud AI tools. It lets users chat with PDFs, notes, docs, invoices, contracts, manuals, and scanned files, with cited answers and local-first processing.

The foundation is an open-source RAG engine optimized for MLX, creating trust, transparency, and developer adoption. The commercial app delivers the polished workflow layer: native Mac UX, document libraries, OCR, sync, templates, structured extraction, and productivity features.

Verity should win by being trustworthy, useful, verifiable, and private by default.

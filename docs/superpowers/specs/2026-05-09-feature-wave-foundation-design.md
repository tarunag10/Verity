# Feature Wave Foundation Design

## Goal

Set up Verity's next feature wave with durable foundations for local model setup, OCR scaffolding, custom templates, citation passage highlighting, and document collections/projects.

## Deliverables

- Document collections can group imported documents into project/client/research scopes.
- Custom templates can be saved locally and run through the existing deterministic extraction engine.
- Citation source references carry highlight metadata so UI surfaces can identify the cited passage.
- OCR setup is represented as an honest local-adapter readiness scaffold.
- Local model setup tracks cache/download readiness without pretending models are downloaded.
- Native SwiftUI surfaces expose the new setup areas without replacing the existing app architecture.

## Architecture

`VerityCore` remains the source of durable state and workflow logic. `LibraryStore` persists collections, custom templates, OCR settings, and model setup state in the existing JSON snapshot. SwiftUI views consume those store APIs through native macOS screens: Collections, Templates, Settings, and Document Viewer.

## Non-Goals

- No production OCR engine is bundled in this pass.
- No fake MLX download progress is shown.
- No cloud sync, billing, or team library behavior is introduced.
- Custom templates start as field-based local extraction workflows; complex prompt editing can build on this foundation later.

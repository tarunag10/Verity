# Accessibility AAA-Oriented Pass Design

## Goal

Make Verity's native macOS UI substantially more accessible by removing low-contrast visual treatment, avoiding color-only meaning, improving labels and target sizing, and aligning the app with WCAG 2.2 AAA-oriented practices where they map cleanly to SwiftUI/macOS.

## Accessibility Baseline

WCAG 2.2 is written for web content, but its principles translate well to native app UI: perceivable, operable, understandable, and robust. For this pass, Verity applies the following native equivalents:

- Prefer primary semantic text over dim secondary or tertiary labels.
- Avoid color-only status communication; status rows must include text and symbols.
- Avoid low-opacity backgrounds, pale color washes, and purely decorative shading for meaning.
- Use visible borders and native controls instead of subtle translucent cards.
- Give icon-only controls explicit accessibility labels.
- Keep actionable controls large enough to be easy to hit and keyboard-focus.
- Combine row content into coherent accessibility elements where VoiceOver should read one item.
- Preserve native macOS materials and selection behavior instead of custom low-contrast surfaces.

## Scope

This pass focuses on the user-facing SwiftUI app surfaces:

- Library and search results
- Chat and citation cards
- Source viewer and highlighted citation context
- Templates and custom template workflows
- Evaluation dashboard and review rows
- Settings, model setup, OCR setup
- Collections/project grouping
- Sidebar chat rows

## Non-Goals

- This pass does not make a formal WCAG conformance claim. AAA conformance requires full manual assistive-technology testing, screenshots, contrast measurement across Light/Dark/Increase Contrast modes, and review of every app state.
- This pass does not replace native AppKit/PDFKit behavior inside `PDFView`.
- This pass does not change core document AI behavior.

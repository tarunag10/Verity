# Accessibility AAA-Oriented Pass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve Verity's native SwiftUI UI toward WCAG 2.2 AAA-oriented accessibility practices by removing low-contrast styling, reducing color-only cues, improving labels, and verifying app type safety.

**Architecture:** Add shared accessibility view helpers in `Sources/Verity/Support`, then apply them to the existing focused SwiftUI views without restructuring core app navigation. Use semantic primary text, bordered panels, native controls, accessibility labels, combined VoiceOver rows, and non-color status cues.

**Tech Stack:** Swift 6.2, SwiftUI, AppKit semantic colors, native macOS accessibility APIs, W3C WCAG 2.2 guidance.

---

## Task 1: Shared Accessibility Helpers

- [x] Add `Sources/Verity/Support/AccessibilitySupport.swift`.
- [x] Add `accessibleMinimumTarget()` for 44-point target sizing.
- [x] Add `accessiblePanel()` using strong semantic border/background instead of translucent shading.
- [x] Add reusable `AccessibleStatusLabel` and `AccessibleMetric` components.

## Task 2: Remove Low-Contrast and Color-Only UI Patterns

- [x] Replace `.secondary` and `.tertiary` foreground usage in app views with `.primary`.
- [x] Remove blue/yellow translucent meaning cues from chat and source highlight surfaces.
- [x] Replace color-only green/orange/red status cues with text+symbol+primary foreground.
- [x] Replace plain citation/template action buttons with bordered native buttons.
- [x] Remove `caption2` microtext from message timestamps.

## Task 3: Improve VoiceOver Labels and Grouping

- [x] Add labels/hints to import, folder import, cancel import, search, chat composer, send, and citation controls.
- [x] Combine rows into single accessibility elements where appropriate.
- [x] Add explicit descriptions for setup checklist steps, citations, document rows, and chat rows.

## Task 4: Verify

- [x] Run static scan for remaining low-contrast patterns.
- [x] Run direct SwiftUI typecheck.
- [ ] Run SwiftPM/Xcode build if the runner is not stalled.

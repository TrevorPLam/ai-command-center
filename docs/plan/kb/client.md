---
title: "Client Architecture"
owner: "Frontend Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

Tauri v2 with GH Actions build and auto-update, Expo SDK 53/54 with EAS Build, Tailwind v4 with OKLCH tokens, WCAG 2.2 AA accessibility compliance.

## Key Facts

### Tauri

**Tauri**: Desktop framework

- v2
- GitHub Actions build
- Mac signing + notarization
- Auto-update tauri-plugin-updater
- Capabilities per window
- Dependency chain audit (Rust + npm)

### Expo

**Expo**: Mobile framework

- SDK 53/54
- EAS Build
- OTA critical-fixes only
- Native secrets via EAS
- CI on tag
- expo-notifications dev build required for Android
- Deep link matrix

### Design System

**DesignSystem**: UI component system

- Tailwind v4 `@theme`
- OKLCH color tokens
- 4px grid system
- Motion tokens
- useShouldAnimate hook
- EmptyState component required
- Skeleton < 2s, spinner > 2s

### Accessibility

**A11y**: WCAG 2.2 AA compliance

- Contrast checks
- Reduced motion support
- Keyboard navigation (Tab/Enter/Escape/Arrows for all interactive elements)
- Canvas alt text
- aria-live regions

## Why It Matters

- Tauri provides secure desktop application packaging
- Expo enables cross-platform mobile development
- Design system ensures consistent UI/UX
- Accessibility compliance ensures inclusive design

## Sources

- Tauri v2 documentation
- Expo documentation
- Tailwind CSS v4 documentation
- WCAG 2.2 guidelines

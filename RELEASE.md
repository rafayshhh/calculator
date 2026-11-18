# Calculator - Open Source Release Process

## Current Status: RELEASE CANDIDATE (RC)

All source code, automated test suites, UI implementations, and domain engines have been audited and verified complete. Calculator is distributed exclusively as an open-source public GitHub repository project.

---

## Platform Release Checklists

### 1. Web / PWA 🟢
- [x] Functional Testing across Chromium & WebKit
- [x] PWA Manifest & App Icons
- [x] Browser Canvas Download & Export Service
- [x] Declarative URL Deep-Linking
- [x] Static GitHub Pages Deployment Pipeline

### 2. Standalone Android (APK) 🟢
- [x] Functional Testing on Emulators and Devices
- [x] Gradle Build Configuration (Kotlin DSL)
- [x] FOSS Release APK Compilation (`flutter build apk --release`)
- [x] Zero Closed-Source Store Dependencies (No Google Play Services)
- [x] Release Asset Attachment for GitHub Releases

### 3. Desktop (Windows, macOS, Linux) 🟢
- [x] Responsive Desktop Navigation Rail & Sidebar
- [x] Multi-Window / Ultrawide Breakpoint Handling
- [x] Standalone Executable Builds

---

## 🚀 GitHub Release Deployment Workflow

1. **Tag Version**:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0 — Calculator Open Source Release"
   git push origin v1.0.0
   ```
2. **Build Standalone Artifacts**:
   - Web PWA: `flutter build web --release`
   - Android APK: `flutter build apk --release`
   - Windows Desktop: `flutter build windows --release`
3. **Publish GitHub Release**:
   - Create Release on GitHub pointing to tag `v1.0.0`.
   - Attach compiled binaries (`app-release.apk`, Web zip bundle, Desktop release).
   - Publish release notes and link to the [Documentation Hub](../Documentation/README.md).

# Calculator — Open Source Community Roadmap

This roadmap outlines the community-driven development milestones for **Calculator** as an open-source project published on GitHub under the MIT License.

> [!NOTE]
> All legacy proprietary deployment paths (such as Google Play Console, Apple App Store, and closed-source signing requirements) have been permanently decommissioned. Calculator is 100% focused on open-source community distribution.

---

## 🎯 Milestone 1: Open Source Public GitHub Release (Current)

- [x] **Source Code Audit & Freeze**: Audit math parsing pipeline, state management, and 150+ specialized calculation tools.
- [x] **Zero-Leak Guarantee**: Ensure zero private keys, API secrets, or personal data exist in the repository.
- [x] **Pure Offline Architecture**: 100% offline-first execution with zero network telemetry or tracking.
- [x] **Comprehensive Documentation Suite**: Centralized `Documentation/` hub covering architecture, tools reference, developer guide, and testing.
- [x] **MIT License & Community Files**: Standard open-source `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `SECURITY.md`.
- [x] **Automated CI Workflow**: GitHub Actions pipeline executing `flutter analyze` and `flutter test` across all pull requests.

---

## 🌐 Milestone 2: Live Web Demo & Community Hub

- [ ] **GitHub Pages Deployment**: Host a live, zero-install Web PWA instance of Calculator directly from the `gh-pages` branch.
- [ ] **GitHub Discussions**: Enable community discussions for feature requests, mathematical formula verifications, and engineering discussions.
- [ ] **Automated GitHub Release Bundles**: Automate GitHub Releases compiling standalone Android APKs, Windows zip executables, and Linux tarballs upon git tag pushes (`v1.0.0`, etc.).

---

## 📦 Milestone 3: FOSS Ecosystem Distribution

- [ ] **Linux Distribution**:
  - Publish on **Flathub** as a verified Flatpak application.
  - Provide standalone portable **AppImage** releases.
  - Create Debian package (`.deb`) and Arch Linux AUR package.
- [ ] **Windows Distribution**:
  - Submit manifest to the Windows Package Manager (`winget`).
  - Provide lightweight portable ZIP package.
- [ ] **macOS Distribution**:
  - Support installation via Homebrew Cask (`brew install --cask calculator`).
  - Universal binary (Apple Silicon + Intel x86_64) DMG releases.
- [ ] **Android FOSS**:
  - Prepare inclusion for **F-Droid** (Free and Open Source Android App Repository).
  - Standalone signed APK assets attached to every GitHub Release.

---

## 🌍 Milestone 4: Internationalization (i18n)

- [ ] **Flutter Localization (`flutter_localizations` & `intl`)**: Extract all user-facing strings into ARB (`.arb`) files.
- [ ] **Community Translation Workflow**:
  - Crowdsource translations across major global languages: Spanish, French, German, Mandarin Chinese, Japanese, Arabic, Hindi, Portuguese, and Urdu.
  - Support RTL (Right-to-Left) layout mirroring for Arabic and Hebrew.

---

## 🔬 Milestone 5: Community Tools & Extensibility

- [ ] **Plugin / Custom Formula Registry**: Enable users to define and save custom multi-variable formulas ($z = f(x, y)$) stored in local Hive boxes.
- [ ] **3D Function Visualizer**: Add interactive WebGL/CustomPaint 3D surface plotters for multivariable calculus ($z = f(x, y)$).
- [ ] **Matrix & Vector Import/Export**: Support CSV and JSON data array import/export for matrix calculations and statistical datasets.

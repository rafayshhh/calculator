# Contributing to Calculator

We welcome community contributions! Please review these guidelines before submitting issues or pull requests.

---

## 🛠️ Development Principles

1. **Pure Dart Domain Engines**: All mathematical and scientific formulas must reside in `domain/` and must not depend on Flutter UI libraries or remote APIs.
2. **Offline-First Guarantee**: No network telemetry, third-party analytics, or cloud dependencies.
3. **Semantic Theming**: All widgets must access styling via `context.kPalette` and `context.kTheme`. Avoid hardcoded colors.
4. **Mandatory Testing**: Every new calculation engine must include corresponding unit tests under `test/`.

---

## 🌿 Contribution Steps

1. Fork the repository and create a feature branch (`git checkout -b feature/my-new-tool`).
2. Implement your changes following project conventions.
3. Run code formatting: `dart format --line-length 80 .`
4. Run static analysis: `flutter analyze` (must report 0 errors and 0 warnings).
5. Run test suite: `flutter test` (all tests must pass).
6. Commit with clear messages (`git commit -m "feat: add optical lens equation calculator"`).
7. Push to your branch and submit a Pull Request.

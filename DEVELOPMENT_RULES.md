# Calculator - Development Rules

## 1. Core Principles
- **No External Dependencies for Math**: All calculations MUST use pure-Dart implementations. Do not import third-party math libraries unless absolutely necessary and approved.
- **Offline First**: Never introduce network calls, analytics, or cloud-syncing.
- **Null Safety**: Strict adherence to Dart null safety. Do not use `!` (bang operator) unless 100% provable.

## 2. Architecture Constraints
- **Separation of Concerns**: UI widgets MUST NOT perform domain calculations. All math logic lives in `domain/` engines.
- **State Mutation**: Use Riverpod `Notifier` classes. Do not use `setState` for global app logic.

## 3. Theming
- **Hardcoded Colors**: NEVER hardcode colors (e.g., `Colors.red`). Always use `context.kPalette`.
- **Hardcoded Spacing**: NEVER use random padding. Use `KSpacing` and `KRadius`.

## 4. Pull Requests
- All new tools must include a corresponding pure-Dart engine test.
- Run `flutter analyze` and ensure 0 issues.
- Run `flutter test` and ensure 100% pass rate.

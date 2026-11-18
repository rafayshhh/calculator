# Calculator - Architecture

## Directory Structure
The repository strictly follows a Feature-First Clean Architecture:

- `lib/app/`: App bootstrap, global routing (`go_router`), and core theme assembly.
- `lib/core/`: Shared design tokens (Spacing, Typography, Radius), reusable UI components (Buttons, Glass Cards, Matrix Editors), and utilities (Logger, Web State Serializer).
- `lib/features/`: Contains all business logic and UI, organized by domain:
  - `calculator/`: The main Math Engine, Smart Formatter, and Core Keypad UI.
  - `history/`: Hive-based persistent history repository.
  - `settings/`: Theme, Font, and Haptic feedback state management.
  - `tools/`: 65 standalone calculation tools, each with its own pure-Dart engine, tests, and UI screen.

## State Management
- **Riverpod (`flutter_riverpod`)**: Used exclusively for global and feature-level state management (e.g., `calculatorProvider`, `themeProvider`, `favoritesProvider`).

## Math Engine
- **Custom Parser & Evaluator**: Located in `lib/features/calculator/domain/math_engine.dart`.
- Uses a formal `Tokenizer` -> `Parser` (AST) -> `Evaluator` pipeline.
- Supports implicit multiplication, algebraic precedence, trigonometric functions, percentage semantics, and fractional exponents.

## Persistence
- **Hive (`hive_flutter`)**: Used for synchronous, secure, on-device binary storage of User History, Pinned Tools, and Settings.

## Routing
- **GoRouter (`go_router`)**: Used for declarative navigation and deep-linking, especially vital for the Web target (e.g., `?state=...` serialization).

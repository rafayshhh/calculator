# Calculator — Testing Guide

Testing is a core pillar of **Calculator**. Because this is a scientific, financial, and engineering calculation suite, mathematical precision and zero-regression guarantees are critical.

---

## 🧪 Test Suite Organization

The test suite is structured parallel to the `lib/` directory:

```text
test/
├── core/
│   ├── kreate_links_test.dart          # Verified documentation & community links
│   └── widgets/
│       └── platform_polish_test.dart   # Shared UI components (KEmptyState, ResultDisplayCard)
│
├── features/
│   ├── calculator/
│   │   ├── math_engine_test.dart       # Core expression parser & AST evaluator
│   │   └── calculator_notifier_test.dart # State transitions, undo/redo stacks
│   │
│   ├── history/
│   │   └── large_history_test.dart     # 1,000+ item dataset stress & Hive persistence
│   │
│   ├── settings/
│   │   └── settings_screen_overhaul_test.dart # Theme switching & preferences
│   │
│   └── tools/
│       ├── domain_engines_extreme_forensics_test.dart # Multi-scale mathematical symmetries
│       ├── physics_engineering_engine_test.dart       # Classical mechanics & electronics
│       ├── chemistry/
│       │   └── chemistry_screens_test.dart            # Molar mass & solution prep
│       ├── discovery/
│       │   └── tool_page_scaffold_test.dart           # Favorites, back, refresh actions
│       ├── everyday_calculators/
│       │   ├── discount_engine_test.dart              # Discount & percentage savings
│       │   ├── fuel_cost_engine_test.dart             # Fuel economy & distance math
│       │   └── percentage_engine_test.dart            # Four percentage calculation modes
│       ├── finance/
│       │   └── finance_engine_test.dart               # Compound interest, ROI, CAGR
│       ├── financial/
│       │   └── financial_engine_test.dart             # Loans, EMI, amortization
│       ├── math/
│       │   ├── math_utilities_engine_test.dart        # Averages, fractions, GCD/LCM
│       │   └── statistics_engine_test.dart            # Mean, median, mode, variance
│       └── unit_conversion/
│           ├── unit_conversion_engine_test.dart       # 15 category precision tests
│           └── unit_converter_swap_test.dart          # Source/target unit swap symmetry
```

---

## 🏃 Running Tests

### 1. Run the Entire Test Suite
```bash
flutter test
```

### 2. Run a Specific Test File
```bash
flutter test test/features/calculator/math_engine_test.dart
```

### 3. Run with Code Coverage
```bash
flutter test --coverage
# Generate readable HTML coverage report (requires lcov):
genhtml coverage/lcov.info -o coverage/html
# Open coverage/html/index.html in browser
```

### 4. Run Filtered by Group or Test Name
```bash
flutter test --name "Percentage Semantics"
```

---

## ✍️ Best Practices: Writing Domain Engine Tests

All domain engines must have accompanying unit tests covering:
1. **Happy Path**: Standard calculation with textbook inputs.
2. **Boundary Conditions**: Zero inputs, extreme values ($10^{-12}$, $10^{12}$).
3. **Error Paths**: Negative numbers where invalid, division by zero, malformed input format.
4. **Floating-Point Precision**: Use `closeTo(expected, epsilon)` instead of strict equality `equals()`.

### Example Template:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kreate_calculator/features/tools/physics/domain/physics_engine.dart';

void main() {
  group('PhysicsEngine — Density Tests', () {
    test('Calculates density correctly for normal inputs', () {
      final density = PhysicsEngine.calculateDensity(100.0, 5.0);
      expect(density, equals(20.0));
    });

    test('Floating-point calculations respect precision threshold', () {
      final res = PhysicsEngine.calculateWaveSpeed(440.0, 0.77);
      expect(res, closeTo(338.8, 1e-4));
    });

    test('Throws typed ArgumentError on zero or negative volume', () {
      expect(
        () => PhysicsEngine.calculateDensity(10.0, 0.0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => PhysicsEngine.calculateDensity(10.0, -2.0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```

---

## 🖥️ Widget Testing with Riverpod & In-Memory Repositories

Because Calculator uses Hive and Riverpod, widget tests should decouple from local disk storage using the `InMemoryHistoryRepository` pattern:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kreate_calculator/features/history/data/history_repository.dart';
import 'package:kreate_calculator/features/history/domain/history_entry.dart';
import 'package:kreate_calculator/features/history/providers/history_provider.dart';

class InMemoryHistoryRepository implements HistoryRepository {
  final List<HistoryEntryV2> _entries = [];
  @override List<HistoryEntryV2> getEntries() => List.unmodifiable(_entries);
  @override Future<void> addEntry(HistoryEntryV2 entry) async => _entries.insert(0, entry);
  @override Future<void> deleteEntry(String id) async => _entries.removeWhere((e) => e.id == id);
  @override Future<void> clearAll() async => _entries.clear();
}

Widget createTestHarness(Widget child, InMemoryHistoryRepository repo) {
  return ProviderScope(
    overrides: [
      historyRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}
```

---

## 🎯 Coverage Benchmarks

| Layer | Coverage Benchmark | Critical Verification Areas |
|:---|:---|:---|
| **Domain Engines** | **≥ 95%** | Mathematical accuracy, edge-case rejection, zero division |
| **Riverpod Providers** | **≥ 85%** | State transitions, undo/redo, input validation |
| **UI Components** | **Key User Flows** | Interactive buttons, theme switches, error display chips |

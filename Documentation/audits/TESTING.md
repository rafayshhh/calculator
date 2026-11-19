# Calculator — Testing Guide

---

## Test Structure

```
test/
├── core/
│   ├── kreate_links_test.dart          # URL constants verification
│   └── web_state_serializer_test.dart  # Base64 encode/decode
│
├── features/
│   ├── calculator/
│   │   ├── math_engine_test.dart       # Core expression evaluator
│   │   ├── math_engine_2_test.dart     # Extended engine tests
│   │   └── smart_formatter_test.dart   # Numeric formatting
│   │
│   ├── history/
│   │   └── history_repository_test.dart
│   │
│   └── tools/
│       ├── financial/
│       │   ├── financial_engine_test.dart
│       │   └── financial_providers_test.dart
│       ├── math/
│       │   ├── advanced_math_engine_test.dart
│       │   └── statistics_engine_test.dart
│       ├── physics/
│       │   └── physics_screens_test.dart
│       └── unit_conversion/
│           ├── unit_conversion_engine_test.dart
│           └── unit_conversion_screen_test.dart
│
└── integration_test/                   # End-to-end tests
```

---

## Running Tests

### Full Suite
```bash
flutter test
```

### Single File
```bash
flutter test test/features/calculator/math_engine_test.dart
```

### With Coverage
```bash
flutter test --coverage
# Then open: coverage/html/index.html
```

### Integration Tests
```bash
flutter test integration_test/
```

---

## Writing Tests for Engines

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kreate_calculator/features/tools/my/domain/my_engine.dart';

void main() {
  group('MyEngine', () {
    // Happy path
    test('calculates expected result', () {
      final result = MyEngine.calculate(input: 42.0);
      expect(result.value, closeTo(expectedValue, 1e-9));
      expect(result.formula, isNotEmpty);
    });

    // Edge cases
    test('returns zero for zero input', () {
      expect(MyEngine.calculate(input: 0).value, equals(0));
    });

    // Error cases
    test('throws ArgumentError for negative input', () {
      expect(
        () => MyEngine.calculate(input: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    // Precision
    test('precision within 1e-9', () {
      final result = MyEngine.calculate(input: 1.0 / 3.0);
      expect(result.value, closeTo(0.333333333, 1e-6));
    });
  });
}
```

---

## Writing Widget Tests

Use the `InMemoryHistoryRepository` pattern (from `physics_screens_test.dart`):

```dart
class InMemoryHistoryRepository implements HistoryRepository {
  final List<HistoryEntryV2> _entries = [];
  @override List<HistoryEntryV2> getEntries() => List.unmodifiable(_entries);
  @override Future<void> addEntry(HistoryEntryV2 entry) async => _entries.insert(0, entry);
  @override Future<void> deleteEntry(String id) async => _entries.removeWhere((e) => e.id == id);
  @override Future<void> clearAll() async => _entries.clear();
}

Widget createTestWidget(Widget child, InMemoryHistoryRepository repo) {
  return ProviderScope(
    overrides: [historyRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}
```

---

## Test Naming Conventions

Use the following format for test names:
```
"[WidgetName|EngineName] [action/scenario]"
```

Examples:
- `"CalculatorEngine handles trailing decimal 5."`
- `"FinancialEngine throws on paymentsPerYear = 0"`
- `"ForceScreen renders and calculates F = ma"`

---

## Coverage Targets

| Layer | Target |
|-------|--------|
| Domain engines | ≥ 90% line coverage |
| Providers | ≥ 80% line coverage |
| Widgets | Key interactions covered |

---

## Common Test Patterns

### Testing async state providers
```dart
test('LoanProvider calculates and serializes', () {
  final container = ProviderContainer();
  final notifier = container.read(loanProvider.notifier);
  
  notifier.updateInput('principal', '10000');
  notifier.updateInput('rate', '5');
  
  final state = container.read(loanProvider);
  expect(state.hasError, false);
  expect(state.periodicPayment, isNotEmpty);
  
  // Test round-trip serialization
  final encoded = notifier.serialize();
  notifier.reset();
  notifier.restoreFromJson(encoded);
  expect(container.read(loanProvider).principal, '10000');
});
```

### Testing deep link state
```dart
test('screen restores from URL state', () async {
  final json = jsonEncode({'value': '42', 'mode': 'deg'});
  final encoded = WebStateSerializer.encodeState(json);
  
  final decoded = WebStateSerializer.decodeState(encoded);
  expect(jsonDecode(decoded!)['value'], '42');
});
```

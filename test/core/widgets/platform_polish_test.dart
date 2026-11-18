import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:calculator/core/widgets/k_empty_state.dart';
import 'package:calculator/core/widgets/result_display_card.dart';
import 'package:calculator/core/widgets/premium_numeric_field.dart';
import 'package:calculator/features/tools/presentation/tools_screen.dart';
import 'package:calculator/features/tools/presentation/all_tools_screen.dart';
import 'package:calculator/features/tools/presentation/category_screen.dart';
import 'package:calculator/features/tools/domain/tool_definition.dart';
import 'package:calculator/features/history/data/history_repository.dart';
import 'package:calculator/features/history/providers/history_provider.dart';
import 'package:calculator/features/history/domain/history_entry.dart';

class InMemoryHistoryRepository implements HistoryRepository {
  final List<HistoryEntryV2> _entries = [];
  @override
  List<HistoryEntryV2> getEntries() => List.unmodifiable(_entries);
  @override
  Future<void> addEntry(HistoryEntryV2 entry) async {
    _entries.insert(0, entry);
  }

  @override
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> clearAll() async {
    _entries.clear();
  }
}

void main() {
  final tempDir = Directory.systemTemp.createTempSync(
    'hive_platform_polish_test',
  );

  setUpAll(() async {
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Phase 19.5 — Platform Polish & Shared Primitives Tests', () {
    late InMemoryHistoryRepository repo;

    setUp(() {
      repo = InMemoryHistoryRepository();
    });

    Widget wrap(Widget child) {
      return ProviderScope(
        overrides: [historyRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(home: child),
      );
    }

    testWidgets(
      'KEmptyState renders icon, title, description, and suggestions',
      (tester) async {
        String? selectedSuggestion;
        bool actionTriggered = false;

        await tester.pumpWidget(
          wrap(
            KEmptyState(
              icon: Icons.search_off_rounded,
              title: 'No Items Found',
              description: 'Please try searching for other terms.',
              suggestions: const ['loan', 'density', 'matrix'],
              onSuggestionSelected: (tag) => selectedSuggestion = tag,
              actionLabel: 'Reset',
              onAction: () => actionTriggered = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No Items Found'), findsOneWidget);
        expect(
          find.text('Please try searching for other terms.'),
          findsOneWidget,
        );
        expect(find.text('density'), findsOneWidget);
        expect(find.text('Reset'), findsOneWidget);

        await tester.tap(find.text('density'));
        await tester.pumpAndSettle();
        expect(selectedSuggestion, equals('density'));

        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();
        expect(actionTriggered, isTrue);
      },
    );

    testWidgets(
      'ResultDisplayCard renders formula, substitution, details, and action bar',
      (tester) async {
        bool shared = false;
        bool reset = false;

        await tester.pumpWidget(
          wrap(
            ResultDisplayCard(
              label: 'Calculated Force',
              value: '220 N',
              secondaryLabel: 'Acceleration',
              secondaryValue: '11 m/s²',
              formula: 'F = m × a',
              substitution: 'F = 20 kg × 11 m/s²',
              details: 'Standard Newtonian calculation on flat plane.',
              onShare: () => shared = true,
              onReset: () => reset = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Calculated Force'), findsOneWidget);
        expect(find.text('220 N'), findsOneWidget);
        expect(find.text('F = m × a'), findsOneWidget);
        expect(find.text('F = 20 kg × 11 m/s²'), findsOneWidget);
        expect(find.text('Share'), findsOneWidget);
        expect(find.text('Reset'), findsOneWidget);

        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();
        expect(reset, isTrue);

        await tester.tap(find.text('Share'));
        await tester.pumpAndSettle();
        expect(shared, isTrue);
      },
    );

    testWidgets(
      'PremiumNumericField clear button and submit triggers callbacks',
      (tester) async {
        String changedValue = '100';
        String? submittedValue;

        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: PremiumNumericField(
                label: 'Input Mass',
                value: changedValue,
                suffix: 'kg',
                onChanged: (val) => changedValue = val,
                onSubmitted: (val) => submittedValue = val,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Input Mass'), findsOneWidget);
        expect(find.text('kg'), findsOneWidget);
        expect(find.byIcon(Icons.clear_rounded), findsOneWidget);

        await tester.tap(find.byIcon(Icons.clear_rounded));
        await tester.pumpAndSettle();
        expect(changedValue, equals(''));

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(submittedValue, isNull);
      },
    );

    testWidgets('ToolsScreen renders hub sections cleanly', (tester) async {
      await tester.pumpWidget(wrap(const ToolsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Toolbox Hub'), findsOneWidget);
      expect(find.text('EXPLORE CATEGORIES'), findsOneWidget);
    });

    testWidgets('AllToolsScreen renders directory and tabs', (tester) async {
      await tester.pumpWidget(wrap(const AllToolsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('All Tools Directory'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
    });

    testWidgets('CategoryScreen renders category title and tools', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const CategoryScreen(category: ToolCategory.mathematics)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mathematics'), findsWidgets);
    });

    testWidgets(
      'Responsive layouts adapt gracefully across multi-screen widths',
      (tester) async {
        final viewports = [
          const Size(320, 600),
          const Size(390, 844),
          const Size(768, 1024),
          const Size(1280, 800),
          const Size(1920, 1080),
        ];

        for (final size in viewports) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          await tester.pumpWidget(wrap(const ToolsScreen()));
          await tester.pumpAndSettle();

          expect(find.text('Toolbox Hub'), findsOneWidget);
        }
      },
    );
  });
}

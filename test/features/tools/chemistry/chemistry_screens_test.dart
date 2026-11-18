import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:calculator/features/history/data/history_repository.dart';
import 'package:calculator/features/history/providers/history_provider.dart';
import 'package:calculator/features/history/domain/history_entry.dart';
import 'package:calculator/features/tools/chemistry/presentation/molar_mass_screen.dart';
import 'package:calculator/features/tools/chemistry/presentation/stoichiometry_screen.dart';
import 'package:calculator/features/tools/chemistry/presentation/molarity_screen.dart';
import 'package:calculator/features/tools/chemistry/presentation/dilution_screen.dart';
import 'package:calculator/features/tools/chemistry/presentation/ideal_gas_screen.dart';
import 'package:calculator/features/tools/chemistry/presentation/gas_law_screen.dart';
import 'package:calculator/features/tools/chemistry/presentation/concentration_screen.dart';
import 'package:calculator/features/tools/chemistry/presentation/ph_screen.dart';

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
    'hive_chemistry_screens_test',
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

  Widget createTestWidget(Widget child, InMemoryHistoryRepository repo) {
    return ProviderScope(
      overrides: [historyRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(home: child),
    );
  }

  group('Chemistry Screens Widget Tests', () {
    late InMemoryHistoryRepository repo;

    setUp(() {
      repo = InMemoryHistoryRepository();
    });

    testWidgets('MolarMassScreen renders and computes formula mass', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const MolarMassScreen(), repo));
      await tester.pumpAndSettle();

      expect(find.text('Molar Mass Calculator'), findsOneWidget);
      expect(find.text('Total Molar Mass'), findsOneWidget);
      expect(find.textContaining('74.092 g/mol'), findsOneWidget);
    });

    testWidgets('StoichiometryScreen renders and computes yield', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const StoichiometryScreen(), repo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stoichiometry Calculator'), findsOneWidget);
      expect(find.textContaining('Yield of H2O'), findsOneWidget);
    });

    testWidgets('MolarityScreen renders and calculates molarity', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const MolarityScreen(), repo));
      await tester.pumpAndSettle();

      expect(find.text('Molarity Calculator'), findsOneWidget);
      expect(find.text('Molarity (M)'), findsWidgets);
      expect(find.textContaining('2 M (mol/L)'), findsOneWidget);
    });

    testWidgets('DilutionScreen renders and computes V1', (tester) async {
      await tester.pumpWidget(createTestWidget(const DilutionScreen(), repo));
      await tester.pumpAndSettle();

      expect(find.text('Dilution Calculator'), findsOneWidget);
      expect(find.text('Required Stock Volume (V₁)'), findsOneWidget);
      expect(find.textContaining('25 mL'), findsOneWidget);
    });

    testWidgets('IdealGasScreen renders and computes pressure', (tester) async {
      await tester.pumpWidget(createTestWidget(const IdealGasScreen(), repo));
      await tester.pumpAndSettle();

      expect(find.text('Ideal Gas Law'), findsOneWidget);
      expect(find.text('Gas Pressure (P)'), findsOneWidget);
    });

    testWidgets('GasLawScreen renders and switches modes', (tester) async {
      await tester.pumpWidget(createTestWidget(const GasLawScreen(), repo));
      await tester.pumpAndSettle();

      expect(find.text('Gas Laws Calculator'), findsOneWidget);
      expect(find.text('Final Pressure (P₂)'), findsOneWidget);

      await tester.tap(find.text('Charles'));
      await tester.pumpAndSettle();

      expect(find.text('Final Volume (V₂)'), findsOneWidget);
    });

    testWidgets('ConcentrationScreen calculates mass percent', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const ConcentrationScreen(), repo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Concentration Calculator'), findsOneWidget);
      expect(find.text('Mass Percentage (% w/w)'), findsOneWidget);
      expect(find.textContaining('15%'), findsOneWidget);
    });

    testWidgets('PhScreen calculates pH and status', (tester) async {
      await tester.pumpWidget(createTestWidget(const PhScreen(), repo));
      await tester.pumpAndSettle();

      expect(find.text('pH Calculator'), findsOneWidget);
      expect(find.text('Solution pH'), findsOneWidget);
      expect(find.text('3.00'), findsOneWidget);
      expect(find.text('Acidic (pH < 7)'), findsOneWidget);
    });
  });
}

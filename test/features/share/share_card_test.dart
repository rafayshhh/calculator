import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/app/theme/k_theme.dart';
import '../../../lib/core/constants/k_color_theme.dart';
import '../../../lib/features/history/domain/history_entry.dart';
import '../../../lib/features/share/domain/calculation_share_data.dart';
import '../../../lib/features/share/presentation/widgets/calculation_share_card.dart';
import '../../../lib/features/tools/application/tool_share_adapter.dart';

void main() {
  group('CalculationShareCard Widget Tests', () {
    testWidgets('CalculationShareCard renders basic calculation properly', (tester) async {
      final data = CalculationShareData(
        title: 'Standard Calculation',
        expression: '200 × 15%',
        result: '30',
        category: 'Basic',
        timestamp: DateTime(2026, 8, 16, 12, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: KTheme.buildTheme(brightness: Brightness.dark, colorTheme: KColorTheme.kreateBlue),
          home: Scaffold(
            body: Center(
              child: CalculationShareCard(
                data: data,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Calculator'), findsOneWidget);
      expect(find.text('200 × 15%'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('github.com/rafayshhh'), findsOneWidget);
    });

    testWidgets('CalculationShareCard renders tool-aware inputs and formula', (tester) async {
      final data = ToolShareAdapter.create(
        toolTitle: 'Body Mass Index (BMI)',
        category: 'Health & Fitness',
        result: '22.9 kg/m²',
        formula: 'BMI = weight / (height)²Bytes',
        inputs: [
          const ShareField(label: 'Height', value: '180', unit: 'cm'),
          const ShareField(label: 'Weight', value: '74', unit: 'kg'),
        ],
        secondaryResults: [
          const ShareField(label: 'Classification', value: 'Normal weight'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: KTheme.buildTheme(brightness: Brightness.dark, colorTheme: KColorTheme.emeraldGreen),
          home: Scaffold(
            body: Center(
              child: CalculationShareCard(
                data: data,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Body Mass Index (BMI)'), findsOneWidget);
      expect(find.text('22.9 kg/m²'), findsOneWidget);
      expect(find.text('Classification: Normal weight'), findsOneWidget);
    });

    test('ToolShareAdapter correctly parses HistoryEntryV2 into tool-aware share data', () {
      final historyEntry = HistoryEntryV2(
        id: '123',
        expression: '180 cm, 75 kg',
        result: '23.1 kg/m²',
        timestamp: DateTime(2026, 8, 16, 12, 0),
        toolRoute: '/tools/health/bmi',
        toolStateJson: '{"height":"180","weight":"75","formula":"BMI = weight / height^2"}',
      );

      final shareData = ToolShareAdapter.fromHistoryEntry(historyEntry);
      expect(shareData.title, isNotEmpty);
      expect(shareData.result, '23.1 kg/m²');
      expect(shareData.formula, 'BMI = weight / height^2');
      expect(shareData.inputs.length, greaterThanOrEqualTo(2));
    });

    testWidgets('CalculationShareCard renders across all 12 theme combinations without exception', (tester) async {
      final data = CalculationShareData(
        title: 'Theme Matrix Test',
        expression: '42 × 42',
        result: '1764',
        category: 'Math',
        inputs: const [
          ShareField(label: 'Factor A', value: '42'),
          ShareField(label: 'Factor B', value: '42'),
        ],
      );

      for (final colorTheme in KColorTheme.values) {
        for (final brightness in [Brightness.dark, Brightness.light]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: KTheme.buildTheme(brightness: brightness, colorTheme: colorTheme),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: CalculationShareCard(data: data),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'Failed on theme: ${colorTheme.name} in $brightness');
          expect(find.text('1764'), findsOneWidget);
        }
      }
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator/core/widgets/tool_page_scaffold.dart';
import 'package:calculator/core/widgets/related_tools_section.dart';

void main() {
  testWidgets(
    'ToolPageScaffold renders title, inputs, results, and action buttons',
    (tester) async {
      bool backPressed = false;
      bool refreshPressed = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ToolPageScaffold(
              toolId: 'molar_mass',
              title: 'Molar Mass Calculator',
              description: 'Calculate molecular weight & elemental breakdown',
              icon: Icons.science_outlined,
              onBack: () => backPressed = true,
              onRefresh: () => refreshPressed = true,
              inputs: const [Text('Formula Input Widget')],
              results: const [Text('Mass Result Widget')],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Molar Mass Calculator'), findsOneWidget);
      expect(find.text('Formula Input Widget'), findsOneWidget);
      expect(find.text('Mass Result Widget'), findsOneWidget);
      expect(find.text('RELATED CALCULATORS'), findsOneWidget);

      // Test back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      expect(backPressed, true);

      // Test refresh button
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      expect(refreshPressed, true);
    },
  );

  testWidgets('ToolPageScaffold favorite button toggles favorite state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ToolPageScaffold(
            toolId: 'molar_mass',
            title: 'Molar Mass Calculator',
            description: 'Calculate molecular weight',
            icon: Icons.science_outlined,
            onBack: () {},
            onRefresh: () {},
            inputs: const [Text('Input')],
            results: const [Text('Result')],
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Initially unstarred in AppBar
    final appBarStarOutline = find.descendant(
      of: find.byType(AppBar),
      matching: find.byIcon(Icons.star_outline_rounded),
    );
    expect(appBarStarOutline, findsOneWidget);

    // Tap favorite icon in AppBar
    await tester.tap(appBarStarOutline);
    await tester.pump(const Duration(milliseconds: 100));

    // Now starred in AppBar
    final appBarStarFilled = find.descendant(
      of: find.byType(AppBar),
      matching: find.byIcon(Icons.star_rounded),
    );
    expect(appBarStarFilled, findsOneWidget);
  });

  testWidgets('RelatedToolsSection renders compact related cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RelatedToolsSection(toolId: 'ohms_law'),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('RELATED CALCULATORS'), findsOneWidget);
  });
}

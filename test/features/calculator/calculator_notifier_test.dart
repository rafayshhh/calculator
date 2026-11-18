import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:calculator/features/calculator/domain/math_engine.dart';
import 'package:calculator/features/calculator/providers/calculator_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('test_calc_notifier_');
    Hive.init(tempDir.path);
    await Hive.openBox<double>('kreate_calculator_memory');
    await Hive.openBox('kreate_history_box_v2');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('CalculatorNotifier & Undo/Redo Engine Tests', () {
    test('Initial state is clean with 0 expression and empty stacks', () {
      final container = ProviderContainer();
      final state = container.read(calculatorProvider);
      expect(state.expression, '0');
      expect(state.result, '');
      expect(state.canUndo, isFalse);
      expect(state.canRedo, isFalse);
    });

    test('append creates undo history and clears redo stack', () {
      final container = ProviderContainer();
      final notifier = container.read(calculatorProvider.notifier);

      notifier.append('5');
      notifier.append('+');
      notifier.append('3');

      final state = container.read(calculatorProvider);
      expect(state.expression, '5+3');
      expect(state.canUndo, isTrue);
      expect(state.undoStack.length, 3);
    });

    test('undo and redo navigate expression history correctly', () {
      final container = ProviderContainer();
      final notifier = container.read(calculatorProvider.notifier);

      notifier.append('1');
      notifier.append('0');
      notifier.append('0');
      expect(container.read(calculatorProvider).expression, '100');

      notifier.undo();
      expect(container.read(calculatorProvider).expression, '10');
      expect(container.read(calculatorProvider).canRedo, isTrue);

      notifier.undo();
      expect(container.read(calculatorProvider).expression, '1');

      notifier.redo();
      expect(container.read(calculatorProvider).expression, '10');

      notifier.redo();
      expect(container.read(calculatorProvider).expression, '100');
    });

    test('insertAt and replaceRange track undo stack', () {
      final container = ProviderContainer();
      final notifier = container.read(calculatorProvider.notifier);

      notifier.setExpression('10+20');
      notifier.insertAt(2, '*5');
      expect(container.read(calculatorProvider).expression, '10*5+20');

      notifier.replaceRange(0, 4, '99');
      expect(container.read(calculatorProvider).expression, '99+20');

      notifier.undo();
      expect(container.read(calculatorProvider).expression, '10*5+20');

      notifier.undo();
      expect(container.read(calculatorProvider).expression, '10+20');
    });

    test('clear and delete manage expression correctly', () {
      final container = ProviderContainer();
      final notifier = container.read(calculatorProvider.notifier);

      notifier.setExpression('456');
      notifier.delete();
      expect(container.read(calculatorProvider).expression, '45');

      notifier.clear();
      expect(container.read(calculatorProvider).expression, '0');

      notifier.undo();
      expect(container.read(calculatorProvider).expression, '45');
    });

    test('calculate evaluates expression and populates result', () {
      final container = ProviderContainer();
      final notifier = container.read(calculatorProvider.notifier);

      notifier.setExpression('12 * 8');
      notifier.calculate();

      final state = container.read(calculatorProvider);
      expect(state.result, '96');
      expect(state.hasError, isFalse);
    });

    test(
      'Memory functions store, recall, add, subtract, and clear properly',
      () {
        final container = ProviderContainer();
        final notifier = container.read(calculatorProvider.notifier);

        notifier.setExpression('50');
        notifier.calculate();
        notifier.memoryStore();
        expect(container.read(calculatorProvider).memoryValue, 50.0);

        notifier.setExpression('25');
        notifier.calculate();
        notifier.memoryAdd();
        expect(container.read(calculatorProvider).memoryValue, 75.0);

        notifier.memorySubtract();
        expect(container.read(calculatorProvider).memoryValue, 50.0);

        notifier.memoryClear();
        expect(container.read(calculatorProvider).memoryValue, isNull);
      },
    );

    test('AngleMode toggles degrees -> radians -> gradians -> degrees', () {
      final container = ProviderContainer();
      final notifier = container.read(calculatorProvider.notifier);

      expect(container.read(calculatorProvider).angleMode, AngleMode.degrees);
      notifier.toggleAngleMode();
      expect(container.read(calculatorProvider).angleMode, AngleMode.radians);
      notifier.toggleAngleMode();
      expect(container.read(calculatorProvider).angleMode, AngleMode.gradians);
      notifier.toggleAngleMode();
      expect(container.read(calculatorProvider).angleMode, AngleMode.degrees);
    });
  });
}

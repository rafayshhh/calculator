import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../domain/math_engine.dart';
import '../../history/providers/history_provider.dart';
import '../../settings/providers/app_settings_provider.dart';

class CalculatorState {
  final String expression;
  final String result;
  final List<String> undoStack;
  final List<String> redoStack;
  final double? memoryValue;
  final AngleMode angleMode;
  final bool hasError;
  final String? errorType;
  final bool isScientific;
  final bool isScientificExpanded;

  const CalculatorState({
    this.expression = '0',
    this.result = '',
    this.undoStack = const [],
    this.redoStack = const [],
    this.memoryValue,
    this.angleMode = AngleMode.degrees,
    this.hasError = false,
    this.errorType,
    this.isScientific = false,
    this.isScientificExpanded = false,
  });

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  CalculatorState copyWith({
    String? expression,
    String? result,
    List<String>? undoStack,
    List<String>? redoStack,
    double? memoryValue,
    bool clearMemory = false,
    AngleMode? angleMode,
    bool? hasError,
    String? errorType,
    bool? isScientific,
    bool? isScientificExpanded,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      memoryValue: clearMemory ? null : (memoryValue ?? this.memoryValue),
      angleMode: angleMode ?? this.angleMode,
      hasError: hasError ?? this.hasError,
      errorType: errorType ?? this.errorType,
      isScientific: isScientific ?? this.isScientific,
      isScientificExpanded: isScientificExpanded ?? this.isScientificExpanded,
    );
  }
}

class CalculatorNotifier extends Notifier<CalculatorState> {
  static const String memoryBoxName = 'kreate_calculator_memory';
  static const String memoryKey = 'calc_mem_val';

  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(memoryBoxName)) {
        await Hive.openBox<double>(memoryBoxName);
      }
    } catch (_) {}
  }

  @override
  CalculatorState build() {
    double? mem;
    try {
      if (Hive.isBoxOpen(memoryBoxName)) {
        final box = Hive.box<double>(memoryBoxName);
        mem = box.get(memoryKey);
      }
    } catch (_) {}

    final defaultAngle = ref.read(appSettingsProvider).defaultAngleMode;
    return CalculatorState(
      memoryValue: mem,
      angleMode: defaultAngle,
    );
  }

  void _pushUndo(String currentExpr) {
    state = state.copyWith(
      undoStack: [...state.undoStack, currentExpr],
      redoStack: const [],
    );
  }

  void append(String text) {
    _pushUndo(state.expression);

    String newExpr;
    if (state.expression == '0' &&
        text != '.' &&
        text != '+' &&
        text != '*' &&
        text != '×' &&
        text != '/' &&
        text != '÷' &&
        text != '^' &&
        text != '%') {
      newExpr = text;
    } else {
      newExpr = state.expression + text;
    }

    state = state.copyWith(
      expression: newExpr,
      hasError: false,
    );
  }

  void appendFunction(String func) {
    append('$func(');
  }

  void setExpression(String expr) {
    _pushUndo(state.expression);
    state = state.copyWith(
      expression: expr,
      hasError: false,
    );
  }

  void insertAt(int index, String text) {
    _pushUndo(state.expression);
    final clamped = index.clamp(0, state.expression.length);
    final before = state.expression.substring(0, clamped);
    final after = state.expression.substring(clamped);
    state = state.copyWith(
      expression: before + text + after,
      hasError: false,
    );
  }

  void replaceRange(int start, int end, String replacement) {
    _pushUndo(state.expression);
    final clampedStart = start.clamp(0, state.expression.length);
    final clampedEnd = end.clamp(clampedStart, state.expression.length);
    final newExpr = state.expression.replaceRange(clampedStart, clampedEnd, replacement);
    state = state.copyWith(
      expression: newExpr,
      hasError: false,
    );
  }

  void delete() {
    if (state.expression.length > 1) {
      state = state.copyWith(
        expression: state.expression.substring(0, state.expression.length - 1),
        hasError: false,
      );
    } else {
      state = state.copyWith(
        expression: '0',
        hasError: false,
      );
    }
  }

  void clear() {
    _pushUndo(state.expression);
    state = state.copyWith(
      expression: '0',
      result: '',
      hasError: false,
    );
  }

  void undo() {
    if (!state.canUndo) return;
    final last = state.undoStack.last;
    final newUndo = List<String>.from(state.undoStack)..removeLast();
    final newRedo = [...state.redoStack, state.expression];

    state = state.copyWith(
      expression: last,
      undoStack: newUndo,
      redoStack: newRedo,
      hasError: false,
    );
  }

  void redo() {
    if (!state.canRedo) return;
    final next = state.redoStack.last;
    final newRedo = List<String>.from(state.redoStack)..removeLast();
    final newUndo = [...state.undoStack, state.expression];

    state = state.copyWith(
      expression: next,
      undoStack: newUndo,
      redoStack: newRedo,
      hasError: false,
    );
  }

  void calculate() {
    try {
      final precisionSetting = ref.read(appSettingsProvider).decimalPrecision;
      final res = MathEngine.evaluate(
        state.expression,
        angleMode: state.angleMode,
        precision: precisionSetting >= 0 ? precisionSetting : null,
      );

      state = state.copyWith(
        result: res,
        hasError: false,
      );

      // Record in history
      try {
        ref.read(historyProvider.notifier).add(
              state.expression,
              res,
            );
      } catch (_) {}
    } catch (_) {
      state = state.copyWith(
        hasError: true,
      );
    }
  }

  void memoryStore() {
    final val = double.tryParse(state.result.isNotEmpty ? state.result : state.expression);
    if (val != null) {
      state = state.copyWith(memoryValue: val);
      _persistMemory(val);
    }
  }

  void memoryRecall() {
    if (state.memoryValue != null) {
      final str = state.memoryValue! % 1 == 0
          ? state.memoryValue!.toInt().toString()
          : state.memoryValue!.toString();
      append(str);
    }
  }

  void memoryAdd() {
    final val = double.tryParse(state.result.isNotEmpty ? state.result : state.expression);
    if (val != null) {
      final current = state.memoryValue ?? 0.0;
      final updated = current + val;
      state = state.copyWith(memoryValue: updated);
      _persistMemory(updated);
    }
  }

  void memorySubtract() {
    final val = double.tryParse(state.result.isNotEmpty ? state.result : state.expression);
    if (val != null) {
      final current = state.memoryValue ?? 0.0;
      final updated = current - val;
      state = state.copyWith(memoryValue: updated);
      _persistMemory(updated);
    }
  }

  void memoryClear() {
    state = state.copyWith(clearMemory: true);
    try {
      if (Hive.isBoxOpen(memoryBoxName)) {
        Hive.box<double>(memoryBoxName).delete(memoryKey);
      }
    } catch (_) {}
  }

  void _persistMemory(double val) {
    try {
      if (Hive.isBoxOpen(memoryBoxName)) {
        Hive.box<double>(memoryBoxName).put(memoryKey, val);
      }
    } catch (_) {}
  }

  void toggleAngleMode() {
    final next = switch (state.angleMode) {
      AngleMode.degrees => AngleMode.radians,
      AngleMode.radians => AngleMode.gradians,
      AngleMode.gradians => AngleMode.degrees,
    };
    state = state.copyWith(angleMode: next);
  }

  void toggleScientific() {
    state = state.copyWith(isScientific: !state.isScientific);
  }

  void toggleScientificExpanded() {
    state = state.copyWith(isScientificExpanded: !state.isScientificExpanded);
  }

  void restoreState(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (data.containsKey('expression')) {
        setExpression(data['expression'] as String);
      }
    } catch (_) {}
  }
}

final calculatorProvider =
    NotifierProvider<CalculatorNotifier, CalculatorState>(
  CalculatorNotifier.new,
);

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/kreate_logger.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/math_utilities_engine.dart';

class AverageState {
  final String numbersInput;
  final String sum;
  final String mean;
  final String median;
  final String min;
  final String max;
  final bool hasError;
  final String errorMessage;

  const AverageState({
    this.numbersInput = '',
    this.sum = '',
    this.mean = '',
    this.median = '',
    this.min = '',
    this.max = '',
    this.hasError = false,
    this.errorMessage = '',
  });

  AverageState copyWith({
    String? numbersInput,
    String? sum,
    String? mean,
    String? median,
    String? min,
    String? max,
    bool? hasError,
    String? errorMessage,
  }) {
    return AverageState(
      numbersInput: numbersInput ?? this.numbersInput,
      sum: sum ?? this.sum,
      mean: mean ?? this.mean,
      median: median ?? this.median,
      min: min ?? this.min,
      max: max ?? this.max,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {'numbersInput': numbersInput};
  }
}

class AverageNotifier extends StateNotifier<AverageState> {
  final Ref ref;

  AverageNotifier(this.ref) : super(const AverageState());

  void setNumbersInput(String value) {
    state = state.copyWith(numbersInput: value);
    _calculate();
  }

  void reset() {
    state = const AverageState();
  }

  void restoreFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      state = state.copyWith(
        numbersInput: data['numbersInput']?.toString() ?? '',
      );
      _calculate();
    } catch (e, st) {
      KreateLogger.error('Failed to restore Average state', e, st);
      reset();
    }
  }

  void _calculate() {
    if (state.numbersInput.isEmpty) {
      state = state.copyWith(
        sum: '',
        mean: '',
        median: '',
        min: '',
        max: '',
        hasError: false,
        errorMessage: '',
      );
      return;
    }

    try {
      final parts = state.numbersInput
          .split(RegExp(r'[,\s]+'))
          .where((s) => s.isNotEmpty);
      final numbers = parts.map((s) => double.parse(s)).toList();

      if (numbers.isEmpty) {
        throw ArgumentError('No valid numbers provided');
      }

      final result = MathUtilitiesEngine.calculateAverage(numbers);

      state = state.copyWith(
        sum: _format(result.sum),
        mean: _format(result.mean),
        median: _format(result.median),
        min: _format(result.min),
        max: _format(result.max),
        hasError: false,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        sum: '',
        mean: '',
        median: '',
        min: '',
        max: '',
        hasError: true,
        errorMessage: e
            .toString()
            .replaceAll('Invalid argument(s): ', '')
            .replaceAll('FormatException: ', ''),
      );
    }
  }

  String _format(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void saveToHistory() {
    if (state.mean.isEmpty || state.hasError) return;

    final equation =
        'avg(${state.numbersInput.replaceAll(RegExp(r'\s+'), ',')})';
    final result = state.mean;

    final stateJson = jsonEncode(state.toJson());

    ref
        .read(historyProvider.notifier)
        .add(
          equation,
          result,
          toolRoute: '/tools/average',
          toolStateJson: stateJson,
        );
  }
}

final averageProvider = StateNotifierProvider<AverageNotifier, AverageState>((
  ref,
) {
  return AverageNotifier(ref);
});

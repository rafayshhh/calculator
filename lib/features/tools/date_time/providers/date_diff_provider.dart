import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../history/providers/history_provider.dart';
import '../domain/date_time_engine.dart';

class DateDiffState {
  final DateTime? startDate;
  final DateTime? endDate;
  final String formattedDifference;
  final String totalDays;
  final bool hasError;
  final String errorMessage;

  const DateDiffState({
    this.startDate,
    this.endDate,
    this.formattedDifference = '',
    this.totalDays = '',
    this.hasError = false,
    this.errorMessage = '',
  });

  DateDiffState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? formattedDifference,
    String? totalDays,
    bool? hasError,
    String? errorMessage,
  }) {
    return DateDiffState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      formattedDifference: formattedDifference ?? this.formattedDifference,
      totalDays: totalDays ?? this.totalDays,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DateDiffNotifier extends StateNotifier<DateDiffState> {
  final Ref ref;

  DateDiffNotifier(this.ref) : super(const DateDiffState());

  void setStartDate(DateTime date) {
    state = state.copyWith(startDate: date);
    _calculate();
  }

  void setEndDate(DateTime date) {
    state = state.copyWith(endDate: date);
    _calculate();
  }

  void reset() {
    state = const DateDiffState();
  }

  void _calculate() {
    if (state.startDate == null || state.endDate == null) {
      state = state.copyWith(
        formattedDifference: '',
        totalDays: '',
        hasError: false,
        errorMessage: '',
      );
      return;
    }

    try {
      final res = DateTimeEngine.calculateDifference(
        start: state.startDate!,
        end: state.endDate!,
      );

      state = state.copyWith(
        formattedDifference: res.formattedSummary,
        totalDays: '${res.totalDays.abs()} days',
        hasError: false,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  void restoreFromJson(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      DateTime? s;
      DateTime? e;
      if (data['startDate'] != null) {
        s = DateTime.parse(data['startDate']);
      }
      if (data['endDate'] != null) {
        e = DateTime.parse(data['endDate']);
      }
      state = state.copyWith(startDate: s, endDate: e);
      _calculate();
    } catch (_) {}
  }

  void saveToHistory() {
    if (state.startDate == null || state.endDate == null || state.hasError) {
      return;
    }

    final sStr = '${state.startDate!.year}-${state.startDate!.month.toString().padLeft(2, '0')}-${state.startDate!.day.toString().padLeft(2, '0')}';
    final eStr = '${state.endDate!.year}-${state.endDate!.month.toString().padLeft(2, '0')}-${state.endDate!.day.toString().padLeft(2, '0')}';
    final stateJson = jsonEncode({
      'startDate': state.startDate!.toIso8601String(),
      'endDate': state.endDate!.toIso8601String(),
    });

    ref.read(historyProvider.notifier).add(
      'Date Difference: $sStr to $eStr',
      '${state.formattedDifference} (${state.totalDays})',
      toolRoute: '/tools/date_diff',
      toolStateJson: stateJson,
    );
  }
}

final dateDiffProvider =
    StateNotifierProvider<DateDiffNotifier, DateDiffState>((ref) {
  return DateDiffNotifier(ref);
});

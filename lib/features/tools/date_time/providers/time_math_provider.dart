import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/kreate_logger.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/date_time_engine.dart';

class TimeMathState {
  final DateTime? initialDate;
  final String years;
  final String months;
  final String days;
  final String hours;
  final String minutes;
  final bool isSubtract;
  final String resultDate;
  final bool hasError;
  final String errorMessage;

  const TimeMathState({
    this.initialDate,
    this.years = '',
    this.months = '',
    this.days = '',
    this.hours = '',
    this.minutes = '',
    this.isSubtract = false,
    this.resultDate = '',
    this.hasError = false,
    this.errorMessage = '',
  });

  TimeMathState copyWith({
    DateTime? initialDate,
    String? years,
    String? months,
    String? days,
    String? hours,
    String? minutes,
    bool? isSubtract,
    String? resultDate,
    bool? hasError,
    String? errorMessage,
  }) {
    return TimeMathState(
      initialDate: initialDate ?? this.initialDate,
      years: years ?? this.years,
      months: months ?? this.months,
      days: days ?? this.days,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      isSubtract: isSubtract ?? this.isSubtract,
      resultDate: resultDate ?? this.resultDate,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initialDate': initialDate?.toIso8601String(),
      'years': years,
      'months': months,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'isSubtract': isSubtract,
    };
  }
}

class TimeMathNotifier extends StateNotifier<TimeMathState> {
  final Ref ref;

  TimeMathNotifier(this.ref) : super(const TimeMathState());

  void setInitialDate(DateTime date) {
    state = state.copyWith(initialDate: date);
    _calculate();
  }

  void setYears(String value) {
    state = state.copyWith(years: value);
    _calculate();
  }

  void setMonths(String value) {
    state = state.copyWith(months: value);
    _calculate();
  }

  void setDays(String value) {
    state = state.copyWith(days: value);
    _calculate();
  }

  void setHours(String value) {
    state = state.copyWith(hours: value);
    _calculate();
  }

  void setMinutes(String value) {
    state = state.copyWith(minutes: value);
    _calculate();
  }

  void toggleOperation() {
    state = state.copyWith(isSubtract: !state.isSubtract);
    _calculate();
  }

  void reset() {
    state = const TimeMathState();
  }

  void restoreFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      state = state.copyWith(
        initialDate: data['initialDate'] != null
            ? DateTime.parse(data['initialDate'])
            : null,
        years: data['years']?.toString() ?? '',
        months: data['months']?.toString() ?? '',
        days: data['days']?.toString() ?? '',
        hours: data['hours']?.toString() ?? '',
        minutes: data['minutes']?.toString() ?? '',
        isSubtract: data['isSubtract'] ?? false,
      );
      _calculate();
    } catch (e, st) {
      KreateLogger.error('Failed to restore Time Math state', e, st);
      reset();
    }
  }

  void _calculate() {
    if (state.initialDate == null) {
      state = state.copyWith(resultDate: '', hasError: false, errorMessage: '');
      return;
    }

    try {
      final y = int.tryParse(state.years) ?? 0;
      final m = int.tryParse(state.months) ?? 0;
      final d = int.tryParse(state.days) ?? 0;
      final h = int.tryParse(state.hours) ?? 0;
      final min = int.tryParse(state.minutes) ?? 0;

      final result = DateTimeEngine.addSubtractTime(
        initialDate: state.initialDate!,
        years: y,
        months: m,
        days: d,
        hours: h,
        minutes: min,
        isSubtract: state.isSubtract,
      );

      final resultStr =
          '${result.year}-${result.month.toString().padLeft(2, '0')}-${result.day.toString().padLeft(2, '0')} ${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';

      state = state.copyWith(
        resultDate: resultStr,
        hasError: false,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        resultDate: '',
        hasError: true,
        errorMessage: e.toString().replaceAll('Invalid argument(s): ', ''),
      );
    }
  }

  void saveToHistory() {
    if (state.resultDate.isEmpty ||
        state.hasError ||
        state.initialDate == null) {
      return;
    }

    final initialStr =
        '${state.initialDate!.year}-${state.initialDate!.month}-${state.initialDate!.day}';
    final op = state.isSubtract ? '-' : '+';

    final parts = [];
    if (state.years.isNotEmpty) parts.add('${state.years}y');
    if (state.months.isNotEmpty) parts.add('${state.months}m');
    if (state.days.isNotEmpty) parts.add('${state.days}d');
    if (state.hours.isNotEmpty) parts.add('${state.hours}h');
    if (state.minutes.isNotEmpty) parts.add('${state.minutes}min');

    final equation = '$initialStr $op ${parts.join(', ')}';
    final result = state.resultDate;

    final stateJson = jsonEncode(state.toJson());

    ref
        .read(historyProvider.notifier)
        .add(
          equation,
          result,
          toolRoute: '/tools/time_math',
          toolStateJson: stateJson,
        );
  }
}

final timeMathProvider = StateNotifierProvider<TimeMathNotifier, TimeMathState>(
  (ref) {
    return TimeMathNotifier(ref);
  },
);

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/everyday_engine.dart';
import '../../../history/providers/history_provider.dart';

class TipState {
  final String billAmount;
  final String tipPercentage;
  final String people;
  final TipResult? result;
  final bool hasError;

  const TipState({
    this.billAmount = '',
    this.tipPercentage = '15',
    this.people = '1',
    this.result,
    this.hasError = false,
  });

  TipState copyWith({
    String? billAmount,
    String? tipPercentage,
    String? people,
    TipResult? result,
    bool? hasError,
    bool clearResult = false,
  }) {
    return TipState(
      billAmount: billAmount ?? this.billAmount,
      tipPercentage: tipPercentage ?? this.tipPercentage,
      people: people ?? this.people,
      result: clearResult ? null : (result ?? this.result),
      hasError: hasError ?? this.hasError,
    );
  }
}

class TipNotifier extends Notifier<TipState> {
  @override
  TipState build() {
    return const TipState();
  }

  void restoreFromJson(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr);
      state = state.copyWith(
        billAmount: map['billAmount'],
        tipPercentage: map['tipPercentage'],
        people: map['people'],
      );
      _calculate();
    } catch (_) {}
  }

  void setBillAmount(String value) {
    state = state.copyWith(billAmount: value);
    _calculate();
  }

  void setTipPercentage(String value) {
    state = state.copyWith(tipPercentage: value);
    _calculate();
  }

  void setPeople(String value) {
    state = state.copyWith(people: value);
    _calculate();
  }

  void reset() {
    state = const TipState();
  }

  void saveToHistory() {
    if (state.result == null || state.hasError) return;

    final expression =
        '\$${state.billAmount} bill, ${state.tipPercentage}% tip, ${state.people} people';
    final res = '\$${_formatResult(state.result!.tipPerPerson)}/person';

    final stateJson = jsonEncode({
      'billAmount': state.billAmount,
      'tipPercentage': state.tipPercentage,
      'people': state.people,
    });

    ref
        .read(historyProvider.notifier)
        .add(
          expression,
          res,
          toolRoute: '/tools/tip',
          toolStateJson: stateJson,
        );
  }

  void _calculate() {
    if (state.billAmount.isEmpty ||
        state.tipPercentage.isEmpty ||
        state.people.isEmpty) {
      state = state.copyWith(clearResult: true, hasError: false);
      return;
    }

    final bill = double.tryParse(state.billAmount);
    final tip = double.tryParse(state.tipPercentage);
    final people = int.tryParse(state.people);

    if (bill == null || tip == null || people == null) {
      state = state.copyWith(clearResult: true, hasError: true);
      return;
    }

    try {
      final res = EverydayEngine.calculateTip(
        billAmount: bill,
        tipPercentage: tip,
        people: people,
      );
      state = state.copyWith(result: res, hasError: false);
    } catch (e) {
      state = state.copyWith(clearResult: true, hasError: true);
    }
  }

  String _formatResult(double value) {
    return value.toStringAsFixed(2);
  }
}

final tipProvider = NotifierProvider<TipNotifier, TipState>(() {
  return TipNotifier();
});

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/financial_engine.dart';
import '../../../../core/utils/web_state_serializer.dart';

class SimpleInterestState {
  final String principal;
  final String rate;
  final String years;
  final String finalAmount;
  final String interestEarned;
  final bool hasError;
  final String errorMessage;

  const SimpleInterestState({
    this.principal = '',
    this.rate = '',
    this.years = '',
    this.finalAmount = '',
    this.interestEarned = '',
    this.hasError = false,
    this.errorMessage = '',
  });

  SimpleInterestState copyWith({
    String? principal,
    String? rate,
    String? years,
    String? finalAmount,
    String? interestEarned,
    bool? hasError,
    String? errorMessage,
  }) {
    return SimpleInterestState(
      principal: principal ?? this.principal,
      rate: rate ?? this.rate,
      years: years ?? this.years,
      finalAmount: finalAmount ?? this.finalAmount,
      interestEarned: interestEarned ?? this.interestEarned,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory SimpleInterestState.fromJson(Map<String, dynamic> map) {
    return SimpleInterestState(
      principal: map['principal'] ?? '',
      rate: map['rate'] ?? '',
      years: map['years'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'principal': principal, 'rate': rate, 'years': years};
  }
}

class SimpleInterestNotifier extends Notifier<SimpleInterestState> {
  @override
  SimpleInterestState build() => const SimpleInterestState();

  void reset() => state = const SimpleInterestState();

  void restoreFromJson(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      state = SimpleInterestState.fromJson(map);
      calculate();
    } catch (_) {}
  }

  String serialize() {
    return WebStateSerializer.encodeState(jsonEncode(state.toJson()));
  }

  String _fmt(double val) {
    final formatter = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    return formatter.format(val);
  }

  void updateInput(String key, String val) {
    if (key == 'principal') state = state.copyWith(principal: val);
    if (key == 'rate') state = state.copyWith(rate: val);
    if (key == 'years') state = state.copyWith(years: val);
    calculate();
  }

  void calculate() {
    try {
      double p = double.parse(state.principal);
      double r = double.parse(state.rate);
      double y = double.parse(state.years);
      if (p < 0 || y < 0) throw Exception('Invalid values');
      final res = FinancialEngine.calculateSimpleInterest(
        principal: p,
        annualRate: r,
        years: y,
      );
      state = state.copyWith(
        finalAmount: _fmt(res.finalAmount),
        interestEarned: _fmt(res.interestEarned),
        hasError: false,
      );
    } catch (e) {
      state = state.copyWith(hasError: true, errorMessage: 'Invalid input');
    }
  }
}

final simpleInterestProvider =
    NotifierProvider<SimpleInterestNotifier, SimpleInterestState>(
      () => SimpleInterestNotifier(),
    );

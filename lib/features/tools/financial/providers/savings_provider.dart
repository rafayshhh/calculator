import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/financial_engine.dart';
import '../../../../core/utils/web_state_serializer.dart';

class SavingsState {
  final String initialDeposit;
  final String contribution;
  final String rate;
  final String years;
  final String finalAmount;
  final String totalPrincipal;
  final String interestEarned;
  final bool hasError;
  final String errorMessage;

  const SavingsState({
    this.initialDeposit = '',
    this.contribution = '',
    this.rate = '',
    this.years = '',
    this.finalAmount = '',
    this.totalPrincipal = '',
    this.interestEarned = '',
    this.hasError = false,
    this.errorMessage = '',
  });

  SavingsState copyWith({
    String? initialDeposit,
    String? contribution,
    String? rate,
    String? years,
    String? finalAmount,
    String? totalPrincipal,
    String? interestEarned,
    bool? hasError,
    String? errorMessage,
  }) {
    return SavingsState(
      initialDeposit: initialDeposit ?? this.initialDeposit,
      contribution: contribution ?? this.contribution,
      rate: rate ?? this.rate,
      years: years ?? this.years,
      finalAmount: finalAmount ?? this.finalAmount,
      totalPrincipal: totalPrincipal ?? this.totalPrincipal,
      interestEarned: interestEarned ?? this.interestEarned,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory SavingsState.fromJson(Map<String, dynamic> map) {
    return SavingsState(
      initialDeposit: map['initialDeposit'] ?? '',
      contribution: map['contribution'] ?? '',
      rate: map['rate'] ?? '',
      years: map['years'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initialDeposit': initialDeposit,
      'contribution': contribution,
      'rate': rate,
      'years': years,
    };
  }
}

class SavingsNotifier extends Notifier<SavingsState> {
  @override
  SavingsState build() => const SavingsState();

  void reset() => state = const SavingsState();

  void restoreFromJson(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      state = SavingsState.fromJson(map);
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
    if (key == 'initialDeposit') state = state.copyWith(initialDeposit: val);
    if (key == 'contribution') state = state.copyWith(contribution: val);
    if (key == 'rate') state = state.copyWith(rate: val);
    if (key == 'years') state = state.copyWith(years: val);
    calculate();
  }

  void calculate() {
    try {
      double p = double.parse(state.initialDeposit);
      double c = double.parse(state.contribution);
      double r = double.parse(state.rate);
      int y = int.parse(state.years);
      if (p < 0 || c < 0 || y < 0) throw Exception('Invalid values');
      final res = FinancialEngine.calculateCompoundInterest(
        principal: p,
        annualRate: r,
        years: y,
        compoundsPerYear: 12,
        additionalContribution: c,
        contributionsPerYear: 12,
      );
      state = state.copyWith(
        finalAmount: _fmt(res.finalAmount),
        totalPrincipal: _fmt(res.totalPrincipal),
        interestEarned: _fmt(res.interestEarned),
        hasError: false,
      );
    } catch (e) {
      state = state.copyWith(hasError: true, errorMessage: 'Invalid input');
    }
  }
}

final savingsProvider = NotifierProvider<SavingsNotifier, SavingsState>(
  () => SavingsNotifier(),
);

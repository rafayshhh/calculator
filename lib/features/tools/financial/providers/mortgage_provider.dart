import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/financial_engine.dart';
import '../../../../core/utils/web_state_serializer.dart';

class MortgageState {
  final String homePrice;
  final String downPayment;
  final String rate;
  final String term;
  final String payment;
  final String totalPayment;
  final String totalInterest;
  final bool hasError;
  final String errorMessage;

  const MortgageState({
    this.homePrice = '',
    this.downPayment = '',
    this.rate = '',
    this.term = '',
    this.payment = '',
    this.totalPayment = '',
    this.totalInterest = '',
    this.hasError = false,
    this.errorMessage = '',
  });

  MortgageState copyWith({
    String? homePrice,
    String? downPayment,
    String? rate,
    String? term,
    String? payment,
    String? totalPayment,
    String? totalInterest,
    bool? hasError,
    String? errorMessage,
  }) {
    return MortgageState(
      homePrice: homePrice ?? this.homePrice,
      downPayment: downPayment ?? this.downPayment,
      rate: rate ?? this.rate,
      term: term ?? this.term,
      payment: payment ?? this.payment,
      totalPayment: totalPayment ?? this.totalPayment,
      totalInterest: totalInterest ?? this.totalInterest,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory MortgageState.fromJson(Map<String, dynamic> map) {
    return MortgageState(
      homePrice: map['homePrice'] ?? '',
      downPayment: map['downPayment'] ?? '',
      rate: map['rate'] ?? '',
      term: map['term'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'homePrice': homePrice,
      'downPayment': downPayment,
      'rate': rate,
      'term': term,
    };
  }
}

class MortgageNotifier extends Notifier<MortgageState> {
  @override
  MortgageState build() => const MortgageState();

  void reset() => state = const MortgageState();

  void restoreFromJson(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      state = MortgageState.fromJson(map);
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
    if (key == 'homePrice') state = state.copyWith(homePrice: val);
    if (key == 'downPayment') state = state.copyWith(downPayment: val);
    if (key == 'rate') state = state.copyWith(rate: val);
    if (key == 'term') state = state.copyWith(term: val);
    calculate();
  }

  void calculate() {
    try {
      double h = double.parse(state.homePrice);
      double d = double.parse(state.downPayment);
      double r = double.parse(state.rate);
      int y = int.parse(state.term);
      if (h < 0 || d < 0 || d > h || y <= 0) throw Exception('Invalid values');
      final res = FinancialEngine.calculateLoan(
        principal: h - d,
        annualRate: r,
        durationInPeriods: y * 12,
        paymentsPerYear: 12,
      );
      state = state.copyWith(
        payment: _fmt(res.periodicPayment),
        totalPayment: _fmt(res.totalPayment),
        totalInterest: _fmt(res.totalInterest),
        hasError: false,
      );
    } catch (e) {
      state = state.copyWith(hasError: true, errorMessage: 'Invalid input');
    }
  }
}

final mortgageProvider = NotifierProvider<MortgageNotifier, MortgageState>(
  () => MortgageNotifier(),
);

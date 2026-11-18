import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../history/providers/history_provider.dart';
import '../domain/everyday_engine.dart';

class DiscountState {
  final String originalPrice;
  final String discountPercentage;
  final DiscountResult? result;
  final bool hasError;
  final String errorMessage;

  const DiscountState({
    this.originalPrice = '100',
    this.discountPercentage = '20',
    this.result,
    this.hasError = false,
    this.errorMessage = '',
  });

  DiscountState copyWith({
    String? originalPrice,
    String? discountPercentage,
    DiscountResult? result,
    bool? hasError,
    String? errorMessage,
  }) {
    return DiscountState(
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      result: result ?? this.result,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DiscountNotifier extends StateNotifier<DiscountState> {
  final Ref ref;

  DiscountNotifier(this.ref) : super(const DiscountState()) {
    _calculate();
  }

  void setOriginalPrice(String val) {
    state = state.copyWith(originalPrice: val);
    _calculate();
  }

  void setDiscountPercentage(String val) {
    state = state.copyWith(discountPercentage: val);
    _calculate();
  }

  void reset() {
    state = const DiscountState();
    _calculate();
  }

  void _calculate() {
    final orig = double.tryParse(state.originalPrice.trim());
    final disc = double.tryParse(state.discountPercentage.trim());

    if (orig == null || disc == null) {
      state = state.copyWith(
        result: null,
        hasError: false,
        errorMessage: '',
      );
      return;
    }

    try {
      final res = EverydayEngine.calculateDiscount(
        originalPrice: orig,
        discountPercentage: disc,
      );

      state = state.copyWith(
        result: res,
        hasError: false,
        errorMessage: '',
      );

      final stateJson = jsonEncode({
        'originalPrice': state.originalPrice,
        'discountPercentage': state.discountPercentage,
      });

      ref.read(historyProvider.notifier).add(
        'Discount: \$${state.originalPrice} - ${state.discountPercentage}%',
        '\$${res.finalPrice.toStringAsFixed(2)}',
        toolRoute: '/tools/discount',
        toolStateJson: stateJson,
      );
    } catch (e) {
      state = state.copyWith(
        result: null,
        hasError: true,
        errorMessage: e.toString().replaceAll('ArgumentError: ', ''),
      );
    }
  }

  void restoreFromJson(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      state = state.copyWith(
        originalPrice: data['originalPrice']?.toString() ?? '100',
        discountPercentage: data['discountPercentage']?.toString() ?? '20',
      );
      _calculate();
    } catch (_) {}
  }
}

final discountProvider =
    StateNotifierProvider<DiscountNotifier, DiscountState>((ref) {
  return DiscountNotifier(ref);
});

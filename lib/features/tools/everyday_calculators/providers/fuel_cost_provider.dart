import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../history/providers/history_provider.dart';
import '../domain/everyday_engine.dart';

class FuelCostState {
  final String distance;
  final String efficiency;
  final bool isVolumePerDistance;
  final String fuelPrice;
  final String totalCost;
  final String fuelNeeded;
  final bool hasError;
  final String errorMessage;

  const FuelCostState({
    this.distance = '100',
    this.efficiency = '8.0',
    this.isVolumePerDistance = true,
    this.fuelPrice = '3.50',
    this.totalCost = '',
    this.fuelNeeded = '',
    this.hasError = false,
    this.errorMessage = '',
  });

  FuelCostState copyWith({
    String? distance,
    String? efficiency,
    bool? isVolumePerDistance,
    String? fuelPrice,
    String? totalCost,
    String? fuelNeeded,
    bool? hasError,
    String? errorMessage,
  }) {
    return FuelCostState(
      distance: distance ?? this.distance,
      efficiency: efficiency ?? this.efficiency,
      isVolumePerDistance: isVolumePerDistance ?? this.isVolumePerDistance,
      fuelPrice: fuelPrice ?? this.fuelPrice,
      totalCost: totalCost ?? this.totalCost,
      fuelNeeded: fuelNeeded ?? this.fuelNeeded,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FuelCostNotifier extends StateNotifier<FuelCostState> {
  final Ref ref;

  FuelCostNotifier(this.ref) : super(const FuelCostState()) {
    _calculate();
  }

  void setDistance(String val) {
    state = state.copyWith(distance: val);
    _calculate();
  }

  void setEfficiency(String val) {
    state = state.copyWith(efficiency: val);
    _calculate();
  }

  void toggleEfficiencyType() {
    state = state.copyWith(isVolumePerDistance: !state.isVolumePerDistance);
    _calculate();
  }

  void setFuelPrice(String val) {
    state = state.copyWith(fuelPrice: val);
    _calculate();
  }

  void reset() {
    state = const FuelCostState();
    _calculate();
  }

  void _calculate() {
    final dist = double.tryParse(state.distance.trim());
    final eff = double.tryParse(state.efficiency.trim());
    final price = double.tryParse(state.fuelPrice.trim());

    if (dist == null || eff == null || price == null) {
      state = state.copyWith(
        totalCost: '',
        fuelNeeded: '',
        hasError: false,
        errorMessage: '',
      );
      return;
    }

    try {
      final res = EverydayEngine.calculateFuelCost(
        distance: dist,
        efficiency: eff,
        pricePerUnit: price,
        isVolumePerDistance: state.isVolumePerDistance,
      );

      state = state.copyWith(
        totalCost: res.totalCost.toStringAsFixed(2),
        fuelNeeded: res.fuelNeeded.toStringAsFixed(2),
        hasError: false,
        errorMessage: '',
      );

      final stateJson = jsonEncode({
        'distance': state.distance,
        'efficiency': state.efficiency,
        'isVolumePerDistance': state.isVolumePerDistance,
        'fuelPrice': state.fuelPrice,
      });

      ref.read(historyProvider.notifier).add(
        'Fuel Cost: ${state.distance} km @ \$${state.fuelPrice}/L',
        '\$${res.totalCost.toStringAsFixed(2)}',
        toolRoute: '/tools/fuel_cost',
        toolStateJson: stateJson,
      );
    } catch (e) {
      state = state.copyWith(
        totalCost: '',
        fuelNeeded: '',
        hasError: true,
        errorMessage: e.toString().replaceAll('ArgumentError: ', ''),
      );
    }
  }

  void restoreFromJson(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      state = state.copyWith(
        distance: data['distance']?.toString() ?? '100',
        efficiency: data['efficiency']?.toString() ?? '8.0',
        isVolumePerDistance: data['isVolumePerDistance'] ?? true,
        fuelPrice: data['fuelPrice']?.toString() ?? '3.50',
      );
      _calculate();
    } catch (_) {}
  }
}

final fuelCostProvider =
    StateNotifierProvider<FuelCostNotifier, FuelCostState>((ref) {
  return FuelCostNotifier(ref);
});

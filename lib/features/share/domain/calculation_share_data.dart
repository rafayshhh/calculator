import 'package:flutter/material.dart';
import '../../../core/constants/k_color_theme.dart';

/// Strongly-typed single field in a calculation or tool result (input, parameter, or metric).
class ShareField {
  final String label;
  final String value;
  final String? unit;

  const ShareField({
    required this.label,
    required this.value,
    this.unit,
  });

  String get formattedValue => unit != null && unit!.isNotEmpty ? '$value $unit' : value;

  Map<String, dynamic> toMap() => {
        'label': label,
        'value': value,
        if (unit != null) 'unit': unit,
      };

  factory ShareField.fromMap(Map<String, dynamic> map) => ShareField(
        label: map['label']?.toString() ?? '',
        value: map['value']?.toString() ?? '',
        unit: map['unit']?.toString(),
      );
}

/// Primary formatted result with strong visual hierarchy and optional interpretation.
class ShareResult {
  final String label;
  final String value;
  final String? unit;
  final String? secondaryLabel;
  final String? secondaryValue;
  final String? interpretation;

  const ShareResult({
    required this.label,
    required this.value,
    this.unit,
    this.secondaryLabel,
    this.secondaryValue,
    this.interpretation,
  });

  String get displayValue => unit != null && unit!.isNotEmpty ? '$value $unit' : value;
}

/// Pure domain data model representing a comprehensive, tool-aware shareable payload.
class CalculationShareData {
  final String title;
  final String expression;
  final String result;
  final String? toolId;
  final String? category;
  final String? formula;
  final String? substitution;
  final String? notes;
  final IconData? icon;
  final List<ShareField> inputs;
  final List<ShareField> secondaryResults;
  final Map<String, String>? metadata;
  final DateTime? timestamp;
  final KColorTheme? colorTheme;
  final Brightness? brightness;
  final Widget? customResultWidget;

  const CalculationShareData({
    required this.title,
    required this.expression,
    required this.result,
    this.toolId,
    this.category,
    this.formula,
    this.substitution,
    this.notes,
    this.icon,
    this.inputs = const [],
    this.secondaryResults = const [],
    this.metadata,
    this.timestamp,
    this.colorTheme,
    this.brightness,
    this.customResultWidget,
  });

  /// Factory helper for creating standard calculator share payloads.
  factory CalculationShareData.standard({
    required String expression,
    required String result,
    bool isScientific = false,
    String? angleMode,
    DateTime? timestamp,
  }) {
    return CalculationShareData(
      title: isScientific ? 'Scientific Calculation' : 'Standard Calculation',
      expression: expression,
      result: result.isEmpty ? '0' : result,
      category: isScientific ? 'Scientific' : 'Basic',
      icon: isScientific ? Icons.science_outlined : Icons.calculate_outlined,
      inputs: [
        ShareField(label: 'Expression', value: expression),
      ],
      metadata: {
        'Mode': isScientific ? 'Scientific' : 'Standard',
        'Angle Unit': ?angleMode,
      },
      timestamp: timestamp ?? DateTime.now(),
    );
  }
}

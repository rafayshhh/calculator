import 'dart:convert';

import 'package:flutter/material.dart';

import '../../history/domain/history_entry.dart';
import '../../share/domain/calculation_share_data.dart';
import '../data/tools_registry.dart';
import '../domain/tool_definition.dart';

/// Centralized adapter that translates raw tool data, history entries, or tool parameters
/// into structured, tool-aware `CalculationShareData` models.
class ToolShareAdapter {
  ToolShareAdapter._();

  /// Converts a [HistoryEntryV2] into a rich, tool-aware [CalculationShareData].
  static CalculationShareData fromHistoryEntry(
    HistoryEntryV2 entry, {
    BuildContext? context,
  }) {
    if (entry.toolRoute == null || entry.toolRoute!.isEmpty) {
      // Standard calculator calculation
      return CalculationShareData.standard(
        expression: entry.expression,
        result: entry.result,
        timestamp: entry.timestamp,
      );
    }

    final tool = ToolRegistry.tools
        .where((t) => t.route == entry.toolRoute)
        .firstOrNull;
    final toolTitle = tool?.title ?? 'Tool Calculation';
    final categoryName = tool != null
        ? '${tool.category.displayName} • ${tool.subcategory.displayName}'
        : 'Specialized Tool';

    Map<String, dynamic> stateMap = {};
    if (entry.toolStateJson != null && entry.toolStateJson!.isNotEmpty) {
      try {
        stateMap = jsonDecode(entry.toolStateJson!) as Map<String, dynamic>;
      } catch (_) {}
    }

    final inputs = <ShareField>[];
    String? formula;
    String? substitution;
    final metadata = <String, String>{};

    // Extract tool-specific inputs and formulas from stateMap
    stateMap.forEach((key, value) {
      if (key == 'formula') {
        formula = value?.toString();
      } else if (key == 'substitution' || key == 'steps') {
        substitution = value?.toString();
      } else if (value != null && value.toString().isNotEmpty) {
        final formattedKey = _formatKeyLabel(key);
        if (inputs.length < 8) {
          inputs.add(ShareField(label: formattedKey, value: value.toString()));
        } else {
          metadata[formattedKey] = value.toString();
        }
      }
    });

    if (inputs.isEmpty && entry.expression.isNotEmpty) {
      inputs.add(ShareField(label: 'Calculation', value: entry.expression));
    }

    return CalculationShareData(
      toolId: tool?.id,
      title: toolTitle,
      category: categoryName,
      icon: tool?.icon ?? Icons.calculate_outlined,
      expression: entry.expression,
      result: entry.result,
      formula: formula,
      substitution: substitution,
      inputs: inputs,
      metadata: metadata.isNotEmpty ? metadata : null,
      timestamp: entry.timestamp,
    );
  }

  /// Builds a customized, tool-aware share payload directly from active tool execution values.
  static CalculationShareData create({
    required String toolTitle,
    required String result,
    String? toolId,
    String? category,
    IconData? icon,
    String? expression,
    String? formula,
    String? substitution,
    String? notes,
    List<ShareField> inputs = const [],
    List<ShareField> secondaryResults = const [],
    Map<String, String>? metadata,
    DateTime? timestamp,
  }) {
    return CalculationShareData(
      toolId: toolId,
      title: toolTitle,
      category: category,
      icon: icon,
      expression:
          expression ??
          (inputs.isNotEmpty
              ? inputs.map((f) => '${f.label}: ${f.formattedValue}').join(', ')
              : toolTitle),
      result: result,
      formula: formula,
      substitution: substitution,
      notes: notes,
      inputs: inputs,
      secondaryResults: secondaryResults,
      metadata: metadata,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  static String _formatKeyLabel(String key) {
    if (key.isEmpty) return key;
    // camelCase to Capitalized Words
    final result = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1).trim();
  }
}

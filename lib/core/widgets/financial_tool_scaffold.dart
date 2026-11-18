import 'package:flutter/material.dart';
import 'tool_page_scaffold.dart';

/// A convenience wrapper around [ToolPageScaffold] designed for financial,
/// chemical, and quantitative utility tool screens.
class FinancialToolScaffold extends StatelessWidget {
  final String? toolId;
  final String title;
  final String description;
  final IconData icon;
  final String? categoryText;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final List<Widget> inputs;
  final List<Widget> results;
  final Widget? actionButton;
  final Widget? formulaCard;
  final Widget? breakdownCard;
  final List<Widget>? bottomWidgets;
  final bool showRelatedTools;
  final VoidCallback? onShare;

  const FinancialToolScaffold({
    super.key,
    this.toolId,
    required this.title,
    required this.description,
    required this.icon,
    this.categoryText,
    required this.onBack,
    required this.onRefresh,
    required this.inputs,
    required this.results,
    this.actionButton,
    this.formulaCard,
    this.breakdownCard,
    this.bottomWidgets,
    this.showRelatedTools = true,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: toolId,
      title: title,
      description: description,
      icon: icon,
      categoryText: categoryText,
      onBack: onBack,
      onRefresh: onRefresh,
      inputs: inputs,
      results: results,
      actionButton: actionButton,
      formulaCard: formulaCard,
      breakdownCard: breakdownCard,
      bottomWidgets: bottomWidgets,
      showRelatedTools: showRelatedTools,
      onShare: onShare,
    );
  }
}

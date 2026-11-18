import '../domain/tool_definition.dart';
import '../data/tools_registry.dart';
import 'recent_tools_provider.dart';

class ToolRecommendations {
  ToolRecommendations._();

  static List<ToolDefinition> getRecommendations(
    List<RecentToolItem> recentItems, [
    int limit = 5,
  ]) {
    if (recentItems.isEmpty) {
      return ToolsRegistry.allTools.take(limit).toList();
    }

    // Find favorite categories based on recent usage
    final categoryFrequency = <ToolCategory, int>{};
    final recentIds = <String>{};

    for (final item in recentItems) {
      recentIds.add(item.toolId);
      final tool = ToolsRegistry.getToolById(item.toolId);
      if (tool != null) {
        categoryFrequency[tool.category] =
            (categoryFrequency[tool.category] ?? 0) + item.usageCount;
      }
    }

    final sortedCats = categoryFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recommendations = <ToolDefinition>[];

    // Pick tools from top categories that haven't been used yet
    for (final entry in sortedCats) {
      final catTools = ToolsRegistry.getToolsByCategory(entry.key);
      for (final tool in catTools) {
        if (!recentIds.contains(tool.id) && !recommendations.contains(tool)) {
          recommendations.add(tool);
          if (recommendations.length >= limit) return recommendations;
        }
      }
    }

    // If still less than limit, fill with general tools
    for (final tool in ToolsRegistry.allTools) {
      if (!recommendations.contains(tool)) {
        recommendations.add(tool);
        if (recommendations.length >= limit) break;
      }
    }

    return recommendations;
  }
}

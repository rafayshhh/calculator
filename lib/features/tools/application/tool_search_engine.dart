import '../domain/tool_definition.dart';
import '../data/tools_registry.dart';

class ToolSearchEngine {
  ToolSearchEngine._();

  static List<ToolDefinition> search(String query, [List<ToolDefinition>? pool]) {
    final clean = query.trim().toLowerCase();
    final tools = pool ?? ToolsRegistry.allTools;
    if (clean.isEmpty) return tools;

    final scored = <(ToolDefinition, int)>[];

    for (final tool in tools) {
      int score = 0;
      final title = tool.title.toLowerCase();
      final desc = tool.description.toLowerCase();
      final cat = tool.category.displayName.toLowerCase();

      if (title == clean) {
        score += 100;
      } else if (title.startsWith(clean)) {
        score += 50;
      } else if (title.contains(clean)) {
        score += 30;
      }

      for (final kw in tool.keywords) {
        final k = kw.toLowerCase();
        if (k == clean) {
          score += 40;
        } else if (k.contains(clean)) {
          score += 20;
        }
      }

      if (cat.contains(clean)) {
        score += 15;
      }

      if (desc.contains(clean)) {
        score += 10;
      }

      if (score > 0) {
        scored.add((tool, score));
      }
    }

    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.map((e) => e.$1).toList();
  }
}

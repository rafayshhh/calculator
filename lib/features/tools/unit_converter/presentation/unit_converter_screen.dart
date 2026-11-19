import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/constants/k_radius.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../domain/conversion_category.dart';
import '../domain/unit_definition.dart';
import '../data/unit_registry.dart';
import '../providers/unit_converter_provider.dart';
import 'widgets/category_selector.dart';

class UnitConverterScreen extends ConsumerStatefulWidget {
  final String? categorySlug;
  final String? initialStateJson;

  const UnitConverterScreen({
    super.key,
    this.categorySlug,
    this.initialStateJson,
  });

  @override
  ConsumerState<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends ConsumerState<UnitConverterScreen> {
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(unitConverterProvider).inputValue;
    _inputController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitConverterProvider);
    final notifier = ref.read(unitConverterProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textPrimary = isDark ? KColors.textPrimaryDark : KColors.textPrimaryLight;
    final textSecondary = isDark ? KColors.textSecondaryDark : KColors.textSecondaryLight;

    // Sync input controller if swapped
    if (_inputController.text != state.inputValue) {
      _inputController.value = TextEditingValue(
        text: state.inputValue,
        selection: TextSelection.collapsed(offset: state.inputValue.length),
      );
    }

    final categoryUnits = UnitRegistry.getUnitsByCategory(state.category);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121418) : const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Unit Converter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: KSpacing.sm),
            CategorySelector(
              selectedCategory: state.category,
              onCategorySelected: (cat) => notifier.setCategory(cat),
            ),
            const SizedBox(height: KSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: KSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Source Card
                    KGlassCard(
                      padding: const EdgeInsets.all(KSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'FROM',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              DropdownButton<UnitDefinition>(
                                value: state.sourceUnit,
                                underline: const SizedBox.shrink(),
                                dropdownColor: isDark ? const Color(0xFF1E222A) : Colors.white,
                                items: categoryUnits.map((u) {
                                  return DropdownMenuItem(
                                    value: u,
                                    child: Text(
                                      '${u.name} (${u.symbol})',
                                      style: TextStyle(color: textPrimary, fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (u) {
                                  if (u != null) notifier.setSourceUnit(u);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: KSpacing.sm),
                          TextField(
                            controller: _inputController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle: TextStyle(color: textSecondary),
                              suffixText: state.sourceUnit.symbol,
                              suffixStyle: TextStyle(color: primaryColor, fontSize: 20),
                            ),
                            onChanged: (val) => notifier.setInputValue(val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: KSpacing.sm),

                    // Swap Button
                    Center(
                      child: IconButton.filledTonal(
                        onPressed: () => notifier.swapUnits(),
                        icon: const Icon(Icons.swap_vert_rounded, size: 26),
                        tooltip: 'Swap Units',
                      ),
                    ),

                    const SizedBox(height: KSpacing.sm),

                    // Target Card
                    KGlassCard(
                      padding: const EdgeInsets.all(KSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TO',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              DropdownButton<UnitDefinition>(
                                value: state.targetUnit,
                                underline: const SizedBox.shrink(),
                                dropdownColor: isDark ? const Color(0xFF1E222A) : Colors.white,
                                items: categoryUnits.map((u) {
                                  return DropdownMenuItem(
                                    value: u,
                                    child: Text(
                                      '${u.name} (${u.symbol})',
                                      style: TextStyle(color: textPrimary, fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (u) {
                                  if (u != null) notifier.setTargetUnit(u);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: KSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SelectableText(
                                  state.resultValue.isEmpty ? '0' : state.resultValue,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 20),
                                color: textSecondary,
                                tooltip: 'Copy result',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: state.resultValue));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Result copied to clipboard'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: KSpacing.xs),
                            Text(
                              state.errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

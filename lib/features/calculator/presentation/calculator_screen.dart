import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_spacing.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/k_page_container.dart';
import '../../history/presentation/history_sheet.dart';
import '../providers/calculator_provider.dart';
import 'widgets/calculator_display.dart';
import 'widgets/morphing_keypad.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const CalculatorScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(calculatorProvider.notifier)
            .restoreState(widget.initialStateJson!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final feedback = ref.watch(feedbackProvider);

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          final logicalKey = event.logicalKey;
          final char = event.character;

          if (logicalKey == LogicalKeyboardKey.enter ||
              logicalKey == LogicalKeyboardKey.numpadEnter ||
              logicalKey == LogicalKeyboardKey.equal) {
            FeedbackService.operatorPress(feedback);
            notifier.calculate();
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.backspace) {
            FeedbackService.buttonPress(feedback);
            notifier.delete();
            return KeyEventResult.handled;
          } else if (logicalKey == LogicalKeyboardKey.escape) {
            FeedbackService.buttonPress(feedback);
            notifier.clear();
            return KeyEventResult.handled;
          } else if (char != null) {
            if (RegExp(r'[0-9\.]').hasMatch(char)) {
              FeedbackService.buttonPress(feedback);
              notifier.append(char);
              return KeyEventResult.handled;
            } else if (RegExp(r'[\+\-\*\/\%\^\(\)]').hasMatch(char)) {
              FeedbackService.operatorPress(feedback);
              notifier.append(char);
              return KeyEventResult.handled;
            } else if (char.toLowerCase() == 's') {
              FeedbackService.operatorPress(feedback);
              notifier.appendFunction('sin');
              return KeyEventResult.handled;
            } else if (char.toLowerCase() == 'c') {
              FeedbackService.operatorPress(feedback);
              notifier.appendFunction('cos');
              return KeyEventResult.handled;
            } else if (char.toLowerCase() == 't') {
              FeedbackService.operatorPress(feedback);
              notifier.appendFunction('tan');
              return KeyEventResult.handled;
            } else if (char.toLowerCase() == 'l') {
              FeedbackService.operatorPress(feedback);
              notifier.appendFunction('log');
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return _buildDesktopLayout(context, state, notifier, feedback);
          }
          return _buildMobileLayout(context, state, notifier, feedback);
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, dynamic state, dynamic notifier, dynamic feedback) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textSecondaryColor =
        isDark ? KColors.textSecondaryDark : KColors.textSecondaryLight;
    final keypadContainerBg =
        isDark ? KColors.backgroundElevatedDark : KColors.surfaceElevatedLight;

    return KPageContainer(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            children: [
              // Top Action Bar: History (Top Left) & Scientific Toggle (Top Right)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KSpacing.md,
                  vertical: KSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Left: History Button
                    IconButton(
                      icon: const Icon(Icons.history_rounded),
                      color: textSecondaryColor,
                      tooltip: 'History',
                      onPressed: () {
                        FeedbackService.toolSelect(feedback);
                        HistorySheet.show(context);
                      },
                    ),

                    // Center Title Branding with Mode Navigation
                    Flexible(
                      child: PopupMenuButton<String>(
                        tooltip: 'Calculator Workspace Modes',
                        color: isDark
                            ? KColors.surfaceElevatedDark
                            : KColors.surfaceElevatedLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (route) {
                          FeedbackService.toolSelect(feedback);
                          if (route.isNotEmpty) context.push(route);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: '/calculator/equation',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.functions_rounded,
                                  size: 18,
                                  color: KColors.primary,
                                ),
                                SizedBox(width: 8),
                                Text('Equation Solver (f(x)=0)'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: '/calculator/graph',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.show_chart_rounded,
                                  size: 18,
                                  color: Color(0xFF00E676),
                                ),
                                SizedBox(width: 8),
                                Text('2D Graphing Canvas'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: '/calculator/table',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.table_chart_rounded,
                                  size: 18,
                                  color: Color(0xFFFFB300),
                                ),
                                SizedBox(width: 8),
                                Text('Function Table (x & f(x))'),
                              ],
                            ),
                          ),
                        ],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'CALCULATOR',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: textSecondaryColor.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: textSecondaryColor.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top Right: Scientific Mode Toggle
                    IconButton(
                      icon: Icon(
                        state.isScientific
                            ? Icons.calculate_rounded
                            : Icons.science_rounded,
                        color: state.isScientific
                            ? primaryColor
                            : textSecondaryColor,
                      ),
                      tooltip: state.isScientific
                          ? 'Switch to Basic'
                          : 'Switch to Scientific',
                      onPressed: () {
                        FeedbackService.settingChange(feedback);
                        notifier.toggleMode();
                      },
                    ),
                  ],
                ),
              ),

              // Calculator Display (Interactive & Cursor Controlled)
              Expanded(
                flex: state.isScientific ? 3 : 4,
                child: CalculatorDisplay(
                  state: state,
                  notifier: notifier,
                ),
              ),

              // Keypad Area with Dynamic In-Place Keypad Morphing
              Expanded(
                flex: state.isScientific ? 7 : 6,
                child: Container(
                  padding: const EdgeInsets.all(KSpacing.md),
                  decoration: BoxDecoration(
                    color: keypadContainerBg,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    border: Border.all(
                      color: isDark
                          ? KColors.glassBorderDark
                          : KColors.glassBorderLight,
                    ),
                  ),
                  child: MorphingKeypad(
                    state: state,
                    notifier: notifier,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, dynamic state, dynamic notifier, dynamic feedback) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textSecondaryColor =
        isDark ? KColors.textSecondaryDark : KColors.textSecondaryLight;
    final keypadContainerBg =
        isDark ? KColors.backgroundElevatedDark : KColors.surfaceElevatedLight;

    return KPageContainer(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Column: Display and History
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Action Bar equivalent for Desktop
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CALCULATOR',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: isDark ? KColors.textPrimaryDark : KColors.textPrimaryLight,
                        ),
                      ),
                      // Scientific Mode Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: keypadContainerBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? KColors.glassBorderDark
                                : KColors.glassBorderLight,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.calculate_rounded),
                              color: !state.isScientific ? primaryColor : textSecondaryColor,
                              tooltip: 'Basic Calculator',
                              onPressed: state.isScientific ? () {
                                FeedbackService.settingChange(feedback);
                                notifier.toggleMode();
                              } : null,
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: isDark ? KColors.glassBorderDark : KColors.glassBorderLight,
                            ),
                            IconButton(
                              icon: const Icon(Icons.science_rounded),
                              color: state.isScientific ? primaryColor : textSecondaryColor,
                              tooltip: 'Scientific Calculator',
                              onPressed: !state.isScientific ? () {
                                FeedbackService.settingChange(feedback);
                                notifier.toggleMode();
                              } : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Main Display
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: keypadContainerBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? KColors.glassBorderDark
                              : KColors.glassBorderLight,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CalculatorDisplay(
                        state: state,
                        notifier: notifier,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Inline History View Placeholder
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: keypadContainerBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? KColors.glassBorderDark
                              : KColors.glassBorderLight,
                        ),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.history_rounded, color: primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'RECENT HISTORY',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textSecondaryColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => HistorySheet.show(context),
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const Divider(),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'History will appear here.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Right Column: Keypad
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: keypadContainerBg,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? KColors.glassBorderDark
                        : KColors.glassBorderLight,
                  ),
                ),
                child: MorphingKeypad(
                  state: state,
                  notifier: notifier,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


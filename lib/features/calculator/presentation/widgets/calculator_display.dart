import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../share/domain/calculation_share_data.dart';
import '../../../share/presentation/dialogs/share_image_preview_dialog.dart';
import '../../domain/math_engine.dart';
import '../../providers/calculator_provider.dart';

/// Highly interactive, editable, cursor-controlled calculator display area.
class CalculatorDisplay extends ConsumerStatefulWidget {
  final CalculatorState state;
  final CalculatorNotifier notifier;

  const CalculatorDisplay({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  ConsumerState<CalculatorDisplay> createState() => _CalculatorDisplayState();
}

class _CalculatorDisplayState extends ConsumerState<CalculatorDisplay> {
  late TextEditingController _expressionController;
  final FocusNode _expressionFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _expressionController = TextEditingController(text: widget.state.expression);
    _expressionController.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant CalculatorDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.expression != widget.state.expression) {
      if (_expressionController.text != widget.state.expression) {
        final previousSelection = _expressionController.selection;
        _expressionController.text = widget.state.expression;
        // Keep cursor in valid bounds
        if (previousSelection.isValid) {
          final newOffset = previousSelection.baseOffset
              .clamp(0, widget.state.expression.length);
          _expressionController.selection =
              TextSelection.collapsed(offset: newOffset);
        } else {
          _expressionController.selection = TextSelection.collapsed(
            offset: widget.state.expression.length,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _expressionController.removeListener(_onControllerChanged);
    _expressionController.dispose();
    _expressionFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final text = _expressionController.text;
    if (text != widget.state.expression) {
      widget.notifier.setExpression(text);
    }
  }

  void _copyResult(BuildContext context, String text) {
    if (text.isEmpty || text == '0') return;
    final feedback = ref.read(feedbackProvider);
    FeedbackService.selection(feedback);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Result copied: $text'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _pasteValidated(BuildContext context) async {
    final feedback = ref.read(feedbackProvider);
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty) return;

    // Validate paste content: allow numbers, arithmetic operators, decimal, parentheses, basic math functions
    final sanitized = text.replaceAll(RegExp(r'\s+'), '');
    final validPattern = RegExp(r'^[0-9\.\+\-\*\/\%\^\(\)a-zA-Z]+$');
    if (!validPattern.hasMatch(sanitized)) {
      if (context.mounted) {
        FeedbackService.error(feedback);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot paste: invalid mathematical content'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    FeedbackService.selection(feedback);
    final currentSelection = _expressionController.selection;
    if (currentSelection.isValid &&
        currentSelection.start != currentSelection.end) {
      widget.notifier.replaceRange(
        currentSelection.start,
        currentSelection.end,
        sanitized,
      );
    } else {
      final offset = currentSelection.isValid
          ? currentSelection.baseOffset
          : _expressionController.text.length;
      widget.notifier.insertAt(offset, sanitized);
    }
  }

  void _shareAsImage(BuildContext context) {
    final feedback = ref.read(feedbackProvider);
    FeedbackService.toolSelect(feedback);

    final expression = widget.state.expression;
    final result = widget.state.result.isEmpty ? '0' : widget.state.result;

    final shareData = CalculationShareData.standard(
      expression: expression,
      result: result,
      isScientific: widget.state.isScientific,
      angleMode: widget.state.isScientific ? widget.state.angleMode.name.toUpperCase() : null,
      timestamp: DateTime.now(),
    );

    ShareImagePreviewDialog.show(context, shareData);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textPrimaryColor =
        isDark ? KColors.textPrimaryDark : KColors.textPrimaryLight;
    final textSecondaryColor =
        isDark ? KColors.textSecondaryDark : KColors.textSecondaryLight;
    final state = widget.state;
    final notifier = widget.notifier;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        KSpacing.lg,
        KSpacing.sm,
        KSpacing.lg,
        KSpacing.md,
      ),
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Top Status & Quick Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Angle Mode & Memory Badges
              Row(
                children: [
                  // Angle Mode Switcher (DEG/RAD/GRAD)
                  if (state.isScientific)
                    InkWell(
                      onTap: () {
                        FeedbackService.toolSelect(ref.read(feedbackProvider));
                        notifier.toggleAngleMode();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          state.angleMode == AngleMode.degrees
                              ? 'DEG'
                              : state.angleMode == AngleMode.radians
                                  ? 'RAD'
                                  : 'GRAD',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                  if (state.memoryValue != null) ...[
                    const SizedBox(width: KSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              const Color(0xFF00E676).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'M',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00E676),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Undo / Redo / Paste / Share Action Badges
              Row(
                children: [
                  // Undo
                  if (state.canUndo)
                    IconButton(
                      icon: const Icon(Icons.undo_rounded, size: 20),
                      color: textSecondaryColor,
                      tooltip: 'Undo (Ctrl+Z)',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        FeedbackService.buttonPress(
                          ref.read(feedbackProvider),
                        );
                        notifier.undo();
                      },
                    ),

                  // Redo
                  if (state.canRedo)
                    IconButton(
                      icon: const Icon(Icons.redo_rounded, size: 20),
                      color: textSecondaryColor,
                      tooltip: 'Redo (Ctrl+Y)',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        FeedbackService.buttonPress(
                          ref.read(feedbackProvider),
                        );
                        notifier.redo();
                      },
                    ),

                  // Paste
                  IconButton(
                    icon: const Icon(Icons.paste_rounded, size: 20),
                    color: textSecondaryColor,
                    tooltip: 'Paste into expression',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _pasteValidated(context),
                  ),

                  // Share as Image
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 20),
                    color: primaryColor,
                    tooltip: 'Share Calculation as Image',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _shareAsImage(context),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Editable Expression Line with Selection & Cursor Control
          Container(
            alignment: Alignment.centerRight,
            child: TextField(
              controller: _expressionController,
              focusNode: _expressionFocusNode,
              textAlign: TextAlign.right,
              readOnly: true, // We allow touch cursor positioning & selection
              showCursor: true,
              cursorColor: primaryColor,
              cursorWidth: 2.5,
              cursorRadius: const Radius.circular(2),
              style: GoogleFonts.inter(
                fontSize: 26,
                color: textSecondaryColor,
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              contextMenuBuilder: (context, editableTextState) {
                return AdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                );
              },
            ),
          ),

          const SizedBox(height: KSpacing.xs),

          // Error Indicator
          if (state.hasError && state.errorType != null)
            Container(
              margin: const EdgeInsets.only(bottom: KSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: KColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: KColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                state.errorType!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KColors.error,
                ),
              ),
            )
                .animate(key: ValueKey(state.errorType))
                .fadeIn()
                .shakeX(amount: 3),

          // Result Line (Selectable / Copyable on Tap)
          GestureDetector(
            onTap: () => _copyResult(
              context,
              state.result.isEmpty ? '0' : state.result,
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: SelectableText(
                state.result.isEmpty ? '0' : state.result,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                  fontSize: state.result.length > 12 ? 40 : 54,
                  fontWeight: FontWeight.bold,
                  color: state.hasError ? KColors.error : textPrimaryColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

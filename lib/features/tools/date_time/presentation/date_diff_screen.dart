import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_page_container.dart';
import '../../../../core/widgets/k_buttons.dart';
import '../../../../core/widgets/specialized_tool_header.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../providers/date_diff_provider.dart';

class DateDiffScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;

  const DateDiffScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DateDiffScreen> createState() => _DateDiffScreenState();
}

class _DateDiffScreenState extends ConsumerState<DateDiffScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialStateJson != null) {
        ref
            .read(dateDiffProvider.notifier)
            .restoreFromJson(widget.initialStateJson!);
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final state = ref.read(dateDiffProvider);
    final initialDate = isStart
        ? (state.startDate ?? DateTime.now())
        : (state.endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isStart) {
        ref.read(dateDiffProvider.notifier).setStartDate(picked);
      } else {
        ref.read(dateDiffProvider.notifier).setEndDate(picked);
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dateDiffProvider);
    final notifier = ref.read(dateDiffProvider.notifier);

    return KPageContainer(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            notifier.reset();
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.reset,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: KSpacing.md,
          vertical: KSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SpecializedToolHeader(
              title: 'Date Difference',
              description: 'Calculate the exact time between two dates (also works for Age).',
              icon: Icons.date_range,
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: KSpacing.xl),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.all(KSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Date',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(state.startDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: KSpacing.md),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: const EdgeInsets.all(KSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Date',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(state.endDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: KSpacing.xl),

            if (state.totalDays.isNotEmpty || state.hasError) ...[
              if (state.hasError && state.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    state.errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ResultDisplayCard(
                    label: 'Exact Difference',
                    value: state.hasError ? 'Error' : state.formattedDifference,
                    secondaryLabel: state.hasError ? null : 'Total Days',
                    secondaryValue: state.hasError ? null : state.totalDays,
                    isError: state.hasError,
                  )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.95, 0.95)),
              const SizedBox(height: KSpacing.lg),

              if (!state.hasError)
                Center(
                  child: KPrimaryButton(
                    text: 'Save to History',
                    onPressed: () {
                      notifier.saveToHistory();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to history')),
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}

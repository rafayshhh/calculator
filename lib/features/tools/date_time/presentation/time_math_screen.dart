import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_page_container.dart';
import '../../../../core/widgets/k_buttons.dart';
import '../../../../core/widgets/specialized_tool_header.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../providers/time_math_provider.dart';

class TimeMathScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;

  const TimeMathScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<TimeMathScreen> createState() => _TimeMathScreenState();
}

class _TimeMathScreenState extends ConsumerState<TimeMathScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialStateJson != null) {
        ref
            .read(timeMathProvider.notifier)
            .restoreFromJson(widget.initialStateJson!);
      }
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final state = ref.read(timeMathProvider);
    final initialDate = state.initialDate ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (!context.mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        final finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        ref.read(timeMathProvider.notifier).setInitialDate(finalDateTime);
      } else {
        ref.read(timeMathProvider.notifier).setInitialDate(pickedDate);
      }
    }
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'Select Date & Time';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timeMathProvider);
    final notifier = ref.read(timeMathProvider.notifier);

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
              title: 'Add/Subtract Time',
              description: 'Add or subtract years, months, days, and time from a specific date.',
              icon: Icons.update,
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: KSpacing.xl),

            InkWell(
              onTap: () => _selectDateTime(context),
              child: Container(
                width: double.infinity,
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
                      'Initial Date & Time',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDateTime(state.initialDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: KSpacing.md),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Add'),
                Switch(
                  value: state.isSubtract,
                  onChanged: (v) => notifier.toggleOperation(),
                  activeThumbColor: Colors.redAccent,
                  inactiveThumbColor: Colors.greenAccent,
                  inactiveTrackColor: Colors.greenAccent.withValues(alpha: 0.5),
                ),
                const Text('Subtract'),
              ],
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: KSpacing.md),

            Row(
              children: [
                Expanded(
                  child: PremiumNumericField(
                    label: 'Years',
                    value: state.years,
                    onChanged: notifier.setYears,
                    suffix: '',
                  ),
                ),
                const SizedBox(width: KSpacing.md),
                Expanded(
                  child: PremiumNumericField(
                    label: 'Months',
                    value: state.months,
                    onChanged: notifier.setMonths,
                    suffix: '',
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: KSpacing.md),

            Row(
              children: [
                Expanded(
                  child: PremiumNumericField(
                    label: 'Days',
                    value: state.days,
                    onChanged: notifier.setDays,
                    suffix: '',
                  ),
                ),
                const SizedBox(width: KSpacing.md),
                Expanded(
                  child: PremiumNumericField(
                    label: 'Hours',
                    value: state.hours,
                    onChanged: notifier.setHours,
                    suffix: '',
                  ),
                ),
                const SizedBox(width: KSpacing.md),
                Expanded(
                  child: PremiumNumericField(
                    label: 'Minutes',
                    value: state.minutes,
                    onChanged: notifier.setMinutes,
                    suffix: '',
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: KSpacing.xl),

            if (state.resultDate.isNotEmpty || state.hasError) ...[
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
                    label: 'Resulting Date & Time',
                    value: state.hasError ? 'Error' : state.resultDate,
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

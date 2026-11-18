import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_radius.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/k_page_container.dart';

class HapticsSettingsScreen extends ConsumerWidget {
  const HapticsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intensity = ref.watch(feedbackProvider);
    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);

    return KPageContainer(
      appBar: AppBar(
        title: const Text('Haptics & Audio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: ListView(
        padding: const EdgeInsets.all(KSpacing.md),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: KSpacing.sm, bottom: KSpacing.sm),
            child: Text(
              'HAPTIC FEEDBACK INTENSITY',
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keypad Vibration Response',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: KSpacing.xs),
                Text(
                  'Fine-tune tactile vibrations on button clicks, formula selections, and error states.',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
                const SizedBox(height: KSpacing.md),
                ...FeedbackIntensity.values.map((val) {
                  final isSelected = val == intensity;
                  return RadioListTile<FeedbackIntensity>(
                    value: val,
                    groupValue: intensity,
                    activeColor: primaryColor,
                    title: Text(
                      val.label,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onChanged: (newVal) {
                      if (newVal != null) {
                        ref.read(feedbackProvider.notifier).setIntensity(newVal);
                        FeedbackService.buttonPress(newVal);
                      }
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.xl),
          Padding(
            padding: const EdgeInsets.only(left: KSpacing.sm, bottom: KSpacing.sm),
            child: Text(
              'TEST TACTILE PROFILES',
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.touch_app_rounded, color: primaryColor),
                  title: Text('Standard Button Tap', style: TextStyle(color: textPrimary)),
                  trailing: OutlinedButton(
                    onPressed: () => FeedbackService.buttonPress(intensity),
                    child: const Text('Test'),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.calculate_rounded, color: Colors.amber),
                  title: Text('Operator Press', style: TextStyle(color: textPrimary)),
                  trailing: OutlinedButton(
                    onPressed: () => FeedbackService.operatorPress(intensity),
                    child: const Text('Test'),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  title: Text('Error Shockwave', style: TextStyle(color: textPrimary)),
                  trailing: OutlinedButton(
                    onPressed: () => FeedbackService.error(intensity),
                    child: const Text('Test'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

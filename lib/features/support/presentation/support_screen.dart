import 'package:flutter/material.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_spacing.dart';
import '../../../core/constants/kreate_links.dart';
import '../../../core/widgets/k_glass_card.dart';
import '../../../core/widgets/k_page_container.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);

    return KPageContainer(
      appBar: AppBar(
        title: const Text('Community & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: ListView(
        padding: const EdgeInsets.all(KSpacing.md),
        children: [
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline_rounded, color: primaryColor, size: 24),
                    const SizedBox(width: KSpacing.md),
                    Text(
                      'Open Source Community',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KSpacing.xs),
                Text(
                  'Have questions, found a bug, or want to contribute a new calculation engine? Connect with the project on GitHub.',
                  style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.lg),
          Padding(
            padding: const EdgeInsets.only(left: KSpacing.sm, bottom: KSpacing.sm),
            child: Text(
              'CHANNELS & CONTRIBUTION',
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
                  leading: const Icon(Icons.bug_report_outlined, color: Colors.amber),
                  title: Text('Submit an Issue / Bug', style: TextStyle(color: textPrimary)),
                  subtitle: Text('Report formula inaccuracies or UI crashes', style: TextStyle(color: textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => KreateLinks.launchUrlExternal(context, KreateLinks.issues),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.forum_outlined, color: primaryColor),
                  title: Text('GitHub Discussions', style: TextStyle(color: textPrimary)),
                  subtitle: Text('Suggest ideas and talk with contributors', style: TextStyle(color: textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => KreateLinks.launchUrlExternal(context, KreateLinks.discussions),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.handshake_outlined, color: Colors.green),
                  title: Text('Contributing Guidelines', style: TextStyle(color: textPrimary)),
                  subtitle: Text('Review how to build and PR new tool engines', style: TextStyle(color: textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => KreateLinks.launchUrlExternal(context, '${KreateLinks.repo}/blob/main/Documentation/CONTRIBUTING.md'),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.lg),
          Padding(
            padding: const EdgeInsets.only(left: KSpacing.sm, bottom: KSpacing.sm),
            child: Text(
              'FREQUENTLY ASKED QUESTIONS',
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildFaq(
            context,
            question: 'Does Calculator require internet?',
            answer: 'No. The entire engine runs 100% offline on pure-Dart algorithms without network requests.',
          ),
          const SizedBox(height: KSpacing.sm),
          _buildFaq(
            context,
            question: 'Is my calculation history kept private?',
            answer: 'Yes. All history entries and preferences are stored locally in Hive boxes on your device storage.',
          ),
          const SizedBox(height: KSpacing.sm),
          _buildFaq(
            context,
            question: 'Can I request a specialized scientific calculator?',
            answer: 'Yes! Open a discussion or feature request on GitHub with the desired equations and unit models.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaq(BuildContext context, {required String question, required String answer}) {
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);

    return KGlassCard(
      padding: const EdgeInsets.all(KSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(answer, style: TextStyle(color: textSecondary, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}

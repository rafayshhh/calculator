import 'package:flutter/material.dart';

import '../constants/k_colors.dart';
import '../constants/k_spacing.dart';
import '../constants/kreate_links.dart';
import 'k_glass_card.dart';

class SocialPlatformItem {
  final String name;
  final String url;
  final IconData icon;
  final Color color;
  final String description;

  const SocialPlatformItem({
    required this.name,
    required this.url,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class KSocialLinksView extends StatelessWidget {
  const KSocialLinksView({super.key});

  static const List<SocialPlatformItem> platforms = [
    SocialPlatformItem(
      name: 'GitHub Repository',
      url: KreateLinks.repo,
      icon: Icons.code_rounded,
      color: Color(0xFF24292E),
      description: 'Source code & releases',
    ),
    SocialPlatformItem(
      name: 'Author Profile',
      url: KreateLinks.github,
      icon: Icons.person_rounded,
      color: Color(0xFF0366D6),
      description: '@rafayshhh',
    ),
    SocialPlatformItem(
      name: 'Issue Tracker',
      url: KreateLinks.issues,
      icon: Icons.bug_report_rounded,
      color: Color(0xFFD73A49),
      description: 'Report formula issues',
    ),
    SocialPlatformItem(
      name: 'Discussions',
      url: KreateLinks.discussions,
      icon: Icons.forum_rounded,
      color: Color(0xFF28A745),
      description: 'Suggest new math tools',
    ),
    SocialPlatformItem(
      name: 'Documentation',
      url: KreateLinks.docs,
      icon: Icons.menu_book_rounded,
      color: Color(0xFF6F42C1),
      description: 'Formulas & architecture',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        return Wrap(
          spacing: KSpacing.sm,
          runSpacing: KSpacing.sm,
          children: platforms.map((platform) {
            final itemWidth = isWide
                ? (constraints.maxWidth - KSpacing.sm) / 2
                : constraints.maxWidth;
            return SizedBox(
              width: itemWidth,
              child: Semantics(
                button: true,
                label: 'Visit ${platform.name}',
                child: KGlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KSpacing.md,
                    vertical: KSpacing.sm,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => KreateLinks.launchUrlExternal(
                      context,
                      platform.url,
                      successMessage: 'Opening ${platform.name}...',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: platform.color.withValues(
                                alpha: isDark ? 0.2 : 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              platform.icon,
                              color: platform.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: KSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  platform.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  platform.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                            color: textSecondary.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

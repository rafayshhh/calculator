import 'package:flutter/material.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_spacing.dart';
import '../../../core/constants/kreate_links.dart';
import '../../../core/widgets/k_glass_card.dart';
import '../../../core/widgets/k_page_container.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);

    return KPageContainer(
      appBar: AppBar(
        title: const Text('About Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: ListView(
        padding: const EdgeInsets.all(KSpacing.md),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.calculate_rounded,
                      size: 44,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: KSpacing.md),
                Text(
                  'Calculator',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0 · 150 Mathematical Tools Suite',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created by Muhammad Abdul Rafay (@rafayshhh)',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.xl),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ABOUT THE PROJECT',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: KSpacing.sm),
                Text(
                  'Calculator is a high-precision, offline-first mathematical suite featuring 150 specialized tools spanning Mathematics, Calculus, Linear Algebra, Geometry, Discrete Mathematics, Statistics, Classical Physics, Engineering, Chemistry, and Financial Analysis. Engineered for maximum speed, accuracy, and total offline privacy with zero tracking.',
                  style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.lg),
          Padding(
            padding: const EdgeInsets.only(left: KSpacing.sm, bottom: KSpacing.sm),
            child: Text(
              'CREATOR & SOCIALS',
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.sm),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_rounded, color: Color(0xFF00E5FF)),
                  title: Text('Muhammad Abdul Rafay', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('GitHub: @rafayshhh', style: TextStyle(color: textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => KreateLinks.launchUrlExternal(context, KreateLinks.github),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFFE1306C)),
                  title: Text('Instagram', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('@kreatekode', style: TextStyle(color: textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => KreateLinks.launchUrlExternal(context, KreateLinks.instagram),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: Color(0xFF00E676)),
                  title: Text('KreateKode Website', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('kreatekode.website', style: TextStyle(color: textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => KreateLinks.launchUrlExternal(context, KreateLinks.website),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shop_rounded, color: Color(0xFFFFB300)),
                  title: Text('Google Play Store', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('KreateKode Developer Apps', style: TextStyle(color: textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => KreateLinks.launchUrlExternal(context, KreateLinks.playStore),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code_rounded, color: primaryColor),
                  title: Text('Source Code Repository', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('github.com/rafayshhh/calculator', style: TextStyle(color: textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => KreateLinks.launchUrlExternal(context, KreateLinks.repo),
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.xxl),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../../core/constants/k_spacing.dart';
import '../../../../core/constants/kreate_links.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/k_page_container.dart';

class EcosystemScreen extends StatelessWidget {
  const EcosystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);

    return KPageContainer(
      appBar: AppBar(
        title: const Text('Open Source Ecosystem'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: ListView(
        padding: const EdgeInsets.all(KSpacing.md),
        children: [
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.code_rounded, color: primaryColor, size: 28),
                    const SizedBox(width: KSpacing.md),
                    Expanded(
                      child: Text(
                        'Calculator Project',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KSpacing.sm),
                Text(
                  'A completely open-source, offline-first mathematical toolbox and high-precision calculator engine developed by Muhammad Abdul Rafay (@rafayshhh). Built with Flutter, Riverpod, and pure-Dart computation algorithms.',
                  style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: KSpacing.md),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('View GitHub Repository'),
                  onPressed: () {
                    KreateLinks.launchUrlExternal(context, KreateLinks.repo);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: KSpacing.xl),
          Padding(
            padding: const EdgeInsets.only(left: KSpacing.sm, bottom: KSpacing.sm),
            child: Text(
              'MODULE ARCHITECTURE',
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildModuleTile(
            context,
            icon: Icons.functions_rounded,
            title: 'Mathematics & Statistics',
            description: 'Recursive-descent math parser, quadratic solvers, matrices, vectors, polynomial differentiation, prime testing, combinations, and permutations.',
          ),
          const SizedBox(height: KSpacing.sm),
          _buildModuleTile(
            context,
            icon: Icons.science_rounded,
            title: 'Chemistry & Molecular Science',
            description: 'IUPAC atomic weight table, formula mass evaluation, stoichiometry yield, molarity, dilution, gas laws, and pH equilibrium.',
          ),
          const SizedBox(height: KSpacing.sm),
          _buildModuleTile(
            context,
            icon: Icons.speed_rounded,
            title: 'Physics & Classical Mechanics',
            description: 'Kinematics, dynamics, electrical power, Ohm\'s law, work and energy, fluid pressure, density, and wave speeds.',
          ),
          const SizedBox(height: KSpacing.sm),
          _buildModuleTile(
            context,
            icon: Icons.engineering_rounded,
            title: 'Engineering & Circuit Analysis',
            description: 'Torque, Hooke\'s law, gear ratios, Young\'s modulus, RC time constants, and series/parallel RLC networks.',
          ),
          const SizedBox(height: KSpacing.sm),
          _buildModuleTile(
            context,
            icon: Icons.attach_money_rounded,
            title: 'Finance & Everyday Utility',
            description: 'Compound interest, mortgage amortization, break-even analysis, profit margins, CAGR, unit prices, and date differences.',
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final primaryColor = KColors.primaryAdaptive(context);
    final textPrimary = KColors.textPrimaryAdaptive(context);
    final textSecondary = KColors.textSecondaryAdaptive(context);

    return KGlassCard(
      padding: const EdgeInsets.all(KSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: KSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    height: 1.4,
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

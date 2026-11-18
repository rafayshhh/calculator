import 'package:flutter/material.dart';

enum ToolCategory {
  everyday,
  finance,
  mathematics,
  statistics,
  physics,
  engineering,
  chemistry,
  developer,
  dateTime,
  conversion,
  other,
}

enum ToolSubcategory {
  general,
  arithmetic,
  numberTheory,
  algebra,
  geometry,
  statistics,
  descriptiveStatistics,
  probability,
  mechanicsKinematics,
  energyMotion,
  electricity,
  wavesFluids,
  thermodynamics,
  mechanical,
  electrical,
  generalChemistry,
  stoichiometry,
  gases,
  acidsBases,
  numberSystems,
  bitwise,
  developerUtils,
  dateCalendar,
  time,
  timestamps,
  timerStopwatch,
  construction,
  personal,
  business,
  investments,
  linearAlgebra,
  calculus,
  discreteMath,
  analysis,
}

extension ToolCategoryExtension on ToolCategory {
  String get displayName {
    switch (this) {
      case ToolCategory.everyday:
        return 'Everyday';
      case ToolCategory.finance:
        return 'Finance';
      case ToolCategory.mathematics:
        return 'Mathematics';
      case ToolCategory.statistics:
        return 'Statistics & Probability';
      case ToolCategory.physics:
        return 'Physics';
      case ToolCategory.engineering:
        return 'Engineering';
      case ToolCategory.chemistry:
        return 'Chemistry';
      case ToolCategory.developer:
        return 'Developer & CS';
      case ToolCategory.dateTime:
        return 'Date & Time';
      case ToolCategory.conversion:
        return 'Conversion';
      case ToolCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ToolCategory.everyday:
        return Icons.coffee_outlined;
      case ToolCategory.finance:
        return Icons.account_balance_wallet_outlined;
      case ToolCategory.mathematics:
        return Icons.functions_outlined;
      case ToolCategory.statistics:
        return Icons.analytics_outlined;
      case ToolCategory.physics:
        return Icons.electric_bolt_outlined;
      case ToolCategory.engineering:
        return Icons.handyman_outlined;
      case ToolCategory.chemistry:
        return Icons.science_outlined;
      case ToolCategory.developer:
        return Icons.terminal_outlined;
      case ToolCategory.dateTime:
        return Icons.schedule_outlined;
      case ToolCategory.conversion:
        return Icons.swap_horiz_outlined;
      case ToolCategory.other:
        return Icons.category_outlined;
    }
  }
}

extension ToolSubcategoryExtension on ToolSubcategory {
  String get displayName {
    switch (this) {
      case ToolSubcategory.general:
        return 'General';
      case ToolSubcategory.arithmetic:
        return 'Arithmetic';
      case ToolSubcategory.numberTheory:
        return 'Number Theory';
      case ToolSubcategory.algebra:
        return 'Algebra';
      case ToolSubcategory.geometry:
        return 'Geometry';
      case ToolSubcategory.statistics:
        return 'Statistics';
      case ToolSubcategory.descriptiveStatistics:
        return 'Descriptive Statistics';
      case ToolSubcategory.probability:
        return 'Probability & Combinatorics';
      case ToolSubcategory.mechanicsKinematics:
        return 'Mechanics & Kinematics';
      case ToolSubcategory.energyMotion:
        return 'Energy & Motion';
      case ToolSubcategory.electricity:
        return 'Electricity';
      case ToolSubcategory.wavesFluids:
        return 'Waves & Fluids';
      case ToolSubcategory.thermodynamics:
        return 'Thermodynamics';
      case ToolSubcategory.mechanical:
        return 'Mechanical';
      case ToolSubcategory.electrical:
        return 'Electrical';
      case ToolSubcategory.generalChemistry:
        return 'General Chemistry';
      case ToolSubcategory.stoichiometry:
        return 'Stoichiometry';
      case ToolSubcategory.gases:
        return 'Gases';
      case ToolSubcategory.acidsBases:
        return 'Acids & Bases';
      case ToolSubcategory.numberSystems:
        return 'Number Systems';
      case ToolSubcategory.bitwise:
        return 'Bitwise Operations';
      case ToolSubcategory.developerUtils:
        return 'Developer Utilities';
      case ToolSubcategory.dateCalendar:
        return 'Date & Calendar';
      case ToolSubcategory.time:
        return 'Time Calculation';
      case ToolSubcategory.timestamps:
        return 'Timestamps & Formats';
      case ToolSubcategory.timerStopwatch:
        return 'Timers & Stopwatch';
      case ToolSubcategory.construction:
        return 'Construction';
      case ToolSubcategory.personal:
        return 'Personal';
      case ToolSubcategory.business:
        return 'Business & Commerce';
      case ToolSubcategory.investments:
        return 'Investments & Growth';
      case ToolSubcategory.linearAlgebra:
        return 'Linear Algebra';
      case ToolSubcategory.calculus:
        return 'Calculus & Numerical';
      case ToolSubcategory.discreteMath:
        return 'Discrete Mathematics';
      case ToolSubcategory.analysis:
        return 'Mathematical Analysis';
    }
  }
}

class ToolDefinition {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final ToolCategory category;
  final ToolSubcategory subcategory;
  final String route;
  final List<String> keywords;
  final bool isAvailable;

  const ToolDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.subcategory = ToolSubcategory.general,
    required this.route,
    this.keywords = const [],
    this.isAvailable = true,
  });
}

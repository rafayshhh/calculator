import 'package:flutter/material.dart';

enum ConversionCategory {
  length('Length', Icons.straighten_outlined, 'm'),
  area('Area', Icons.crop_square_outlined, 'm²'),
  volume('Volume', Icons.view_in_ar_outlined, 'L'),
  mass('Mass & Weight', Icons.scale_outlined, 'kg'),
  temperature('Temperature', Icons.thermostat_outlined, '°C'),
  time('Time', Icons.schedule_outlined, 's'),
  speed('Speed', Icons.speed_outlined, 'm/s'),
  pressure('Pressure', Icons.compress_outlined, 'Pa'),
  energy('Energy', Icons.bolt_outlined, 'J'),
  power('Power', Icons.offline_bolt_outlined, 'W'),
  digitalStorage('Digital Storage', Icons.sd_storage_outlined, 'B'),
  frequency('Frequency', Icons.graphic_eq_outlined, 'Hz'),
  angle('Angle', Icons.rotate_right_outlined, 'rad'),
  force('Force', Icons.fitness_center_outlined, 'N'),
  torque('Torque', Icons.cached_outlined, 'N·m');

  final String displayName;
  final IconData icon;
  final String baseUnitSymbol;

  const ConversionCategory(this.displayName, this.icon, this.baseUnitSymbol);
}

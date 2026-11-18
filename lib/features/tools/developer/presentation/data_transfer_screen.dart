import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_formula_card.dart';
import '../../../../core/widgets/k_stat_row.dart';
import '../../../../core/widgets/premium_numeric_field.dart';
import '../../../../core/widgets/result_display_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../../../history/providers/history_provider.dart';
import '../domain/developer_engine.dart';

class DataTransferScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DataTransferScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DataTransferScreen> createState() => _DataTransferScreenState();
}

class _DataTransferScreenState extends ConsumerState<DataTransferScreen> {
  String _fileSize = '5.0';
  String _fileUnit = 'GB';
  String _speed = '100.0';
  String _speedUnit = 'Mbps';

  DataTransferResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStateJson != null) {
      try {
        final data = jsonDecode(widget.initialStateJson!) as Map<String, dynamic>;
        _fileSize = data['fileSize']?.toString() ?? '5.0';
        _fileUnit = data['fileUnit'] ?? 'GB';
        _speed = data['speed']?.toString() ?? '100.0';
        _speedUnit = data['speedUnit'] ?? 'Mbps';
      } catch (_) {}
    }
    _calculate();
  }

  void _calculate() {
    final size = double.tryParse(_fileSize);
    final spd = double.tryParse(_speed);
    if (size == null || spd == null || size < 0 || spd <= 0) {
      setState(() {
        _result = null;
        _error = 'Please enter positive transfer size and network speed';
      });
      return;
    }

    try {
      final res = DeveloperEngine.calculateDataTransferTime(
        fileSize: size,
        fileUnit: _fileUnit,
        speed: spd,
        speedUnit: _speedUnit,
      );
      setState(() {
        _error = null;
        _result = res;
      });

      final stateJson = jsonEncode({'fileSize': _fileSize, 'fileUnit': _fileUnit, 'speed': _speed, 'speedUnit': _speedUnit});
      ref.read(historyProvider.notifier).add(
        'Transfer: $_fileSize $_fileUnit @ $_speed $_speedUnit',
        res.formattedDuration,
        toolRoute: '/tools/developer/data_transfer',
        toolStateJson: stateJson,
      );
    } catch (e) {
      setState(() {
        _result = null;
        _error = e.toString().replaceAll('ArgumentError: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _fileSize = '5.0';
      _fileUnit = 'GB';
      _speed = '100.0';
      _speedUnit = 'Mbps';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'data_transfer',
      title: 'Data Transfer Time',
      description: 'Compute download/upload ETA based on file size and connection bandwidth.',
      icon: Icons.cloud_download_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: PremiumNumericField(
                label: 'File Size',
                value: _fileSize,
                onChanged: (v) {
                  _fileSize = v;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _fileUnit,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12)),
                items: ['B', 'KB', 'MB', 'GB', 'TB'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _fileUnit = v);
                    _calculate();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: PremiumNumericField(
                label: 'Transfer Bandwidth Speed',
                value: _speed,
                onChanged: (v) {
                  _speed = v;
                  _calculate();
                },
              ),
            ),
            const SizedBox(width: KSpacing.sm),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _speedUnit,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12)),
                items: ['Kbps', 'Mbps', 'Gbps', 'KB/s', 'MB/s', 'GB/s'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _speedUnit = v);
                    _calculate();
                  }
                },
              ),
            ),
          ],
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else if (_result != null) ...[
          ResultDisplayCard(
            label: 'Estimated Transfer Duration',
            value: _result!.formattedDuration,
            secondaryLabel: 'Total Seconds',
            secondaryValue: '\${_result!.totalSeconds.toStringAsFixed(1)} s',
            formula: 'Time = Total Bits / Transfer Speed',
            substitution: '\$_fileSize \$_fileUnit @ \$_speed \$_speedUnit',
            onShare: () {},
          ),
          const SizedBox(height: KSpacing.md),
          KStatRow(label: 'Total Bytes', value: '\${_result!.totalBytes.toInt()} B'),
        ],
      ],
    );
  }
}

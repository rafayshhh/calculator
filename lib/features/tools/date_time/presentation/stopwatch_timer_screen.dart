import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';

class StopwatchTimerScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const StopwatchTimerScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<StopwatchTimerScreen> createState() => _StopwatchTimerScreenState();
}

class _StopwatchTimerScreenState extends ConsumerState<StopwatchTimerScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<String> _laps = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStop() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _timer?.cancel();
      } else {
        _stopwatch.start();
        _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
          setState(() {});
        });
      }
    });
  }

  void _reset() {
    setState(() {
      _stopwatch.reset();
      _laps.clear();
    });
  }

  void _lap() {
    if (_stopwatch.isRunning) {
      setState(() {
        _laps.insert(0, _formattedTime);
      });
    }
  }

  String get _formattedTime {
    final ms = _stopwatch.elapsedMilliseconds;
    final hundreds = (ms ~/ 10) % 100;
    final seconds = (ms ~/ 1000) % 60;
    final minutes = (ms ~/ 60000) % 60;
    final hours = ms ~/ 3600000;
    if (hours > 0) {
      return '\${hours.toString().padLeft(2, '0')}:\${minutes.toString().padLeft(2, '0')}:\${seconds.toString().padLeft(2, '0')}.\${hundreds.toString().padLeft(2, '0')}';
    }
    return '\${minutes.toString().padLeft(2, '0')}:\${seconds.toString().padLeft(2, '0')}.\${hundreds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'timer',
      title: 'Stopwatch & Timer',
      description: 'High-precision lap timer and millisecond stopwatch.',
      icon: Icons.timer_rounded,
      onBack: () => context.pop(),
      onRefresh: _reset,
      inputs: [
        Center(
          child: Column(
            children: [
              Text(
                _formattedTime,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 2.0),
              ),
              const SizedBox(height: KSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _stopwatch.isRunning ? Colors.redAccent : Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: Icon(_stopwatch.isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_stopwatch.isRunning ? 'Pause' : 'Start'),
                    onPressed: _startStop,
                  ),
                  const SizedBox(width: KSpacing.md),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.flag_rounded),
                    label: const Text('Lap'),
                    onPressed: _stopwatch.isRunning ? _lap : null,
                  ),
                  const SizedBox(width: KSpacing.md),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _reset,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      results: [
        if (_laps.isNotEmpty)
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Laps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: KSpacing.sm),
                ..._laps.asMap().entries.map((e) => ListTile(
                  dense: true,
                  leading: Text('Lap \${_laps.length - e.key}'),
                  trailing: Text(e.value, style: const TextStyle(fontFamily: 'monospace')),
                )),
              ],
            ),
          ),
      ],
    );
  }
}

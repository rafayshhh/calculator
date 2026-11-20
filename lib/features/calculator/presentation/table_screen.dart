import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_spacing.dart';
import '../domain/math_engine.dart';

class TableScreen extends StatefulWidget {
  final String? initialStateJson;
  const TableScreen({super.key, this.initialStateJson});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  String _func = 'x^2';
  late final TextEditingController _controller;
  double _start = -5;
  double _end = 5;
  double _step = 1;

  final List<(double, String)> _rows = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _func);
    _generate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    _rows.clear();
    for (double x = _start; x <= _end; x += _step) {
      try {
        final sub = _func.replaceAll('x', '($x)').replaceAll('X', '($x)');
        final y = MathEngine.evaluate(sub, angleMode: AngleMode.radians);
        _rows.add((x, y));
      } catch (_) {
        _rows.add((x, 'Error'));
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textPrimary = isDark ? KColors.textPrimaryDark : KColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121418) : const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Function Value Table'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(KSpacing.md),
              child: Row(
                children: [
                  Text('f(x) = ', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'e.g. x^2, 2*x + 1',
                        filled: true,
                        fillColor: isDark ? Colors.black26 : Colors.black12,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) {
                        _func = val.trim();
                        _generate();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: KSpacing.md),
                itemCount: _rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final (x, y) = _rows[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('x = ${x % 1 == 0 ? x.toInt() : x}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                        Text('f(x) = $y', style: TextStyle(color: primaryColor, fontFamily: 'monospace')),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

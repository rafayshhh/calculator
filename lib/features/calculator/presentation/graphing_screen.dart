import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/k_colors.dart';
import '../../../core/constants/k_spacing.dart';
import 'widgets/graph_canvas.dart';

class GraphingScreen extends StatefulWidget {
  final String? initialStateJson;
  const GraphingScreen({super.key, this.initialStateJson});

  @override
  State<GraphingScreen> createState() => _GraphingScreenState();
}

class _GraphingScreenState extends State<GraphingScreen> {
  String _expression = 'sin(x)';
  late final TextEditingController _controller;

  double _xMin = -10;
  double _xMax = 10;
  double _yMin = -5;
  double _yMax = 5;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _expression);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KColors.primary : const Color(0xFF0091EA);
    final textPrimary = isDark ? KColors.textPrimaryDark : KColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121418) : const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('2D Function Grapher'),
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
              padding: const EdgeInsets.symmetric(horizontal: KSpacing.md, vertical: KSpacing.sm),
              child: Row(
                children: [
                  Text('f(x) = ', style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g. sin(x), x^2 - 4, cos(2*x)',
                        filled: true,
                        fillColor: isDark ? Colors.black26 : Colors.black12,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (val) {
                        setState(() {
                          _expression = val.trim();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: KSpacing.xs),
                  IconButton(
                    icon: Icon(Icons.check_rounded, color: primaryColor),
                    onPressed: () {
                      setState(() {
                        _expression = _controller.text.trim();
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(KSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GraphCanvas(
                    expression: _expression,
                    xMin: _xMin,
                    xMax: _xMax,
                    yMin: _yMin,
                    yMax: _yMax,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KSpacing.md, vertical: KSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionChip(label: const Text('sin(x)'), onPressed: () => _setPreset('sin(x)')),
                  ActionChip(label: const Text('cos(x)'), onPressed: () => _setPreset('cos(x)')),
                  ActionChip(label: const Text('x^2 - 4'), onPressed: () => _setPreset('x^2 - 4')),
                  ActionChip(label: const Text('sqrt(x)'), onPressed: () => _setPreset('sqrt(x)')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setPreset(String expr) {
    setState(() {
      _expression = expr;
      _controller.text = expr;
    });
  }
}

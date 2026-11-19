import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/widgets/k_glass_card.dart';
import '../../../../core/widgets/tool_page_scaffold.dart';
import '../domain/developer_engine.dart';

class DeveloperUtilitiesScreen extends ConsumerStatefulWidget {
  final String? initialStateJson;
  const DeveloperUtilitiesScreen({super.key, this.initialStateJson});

  @override
  ConsumerState<DeveloperUtilitiesScreen> createState() => _DeveloperUtilitiesScreenState();
}

class _DeveloperUtilitiesScreenState extends ConsumerState<DeveloperUtilitiesScreen> {
  final TextEditingController _inputController = TextEditingController(text: '{"name":"Kreate","open_source":true}');
  String _output = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _formatJson();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _formatJson() {
    try {
      final res = DeveloperEngine.formatJson(_inputController.text);
      setState(() {
        _error = null;
        _output = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('FormatException: ', '');
      });
    }
  }

  void _minifyJson() {
    try {
      final res = DeveloperEngine.minifyJson(_inputController.text);
      setState(() {
        _error = null;
        _output = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('FormatException: ', '');
      });
    }
  }

  void _base64Encode() {
    final res = DeveloperEngine.encodeBase64(_inputController.text);
    setState(() {
      _error = null;
      _output = res;
    });
  }

  void _base64Decode() {
    try {
      final res = DeveloperEngine.decodeBase64(_inputController.text);
      setState(() {
        _error = null;
        _output = res;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid Base64 string';
      });
    }
  }

  void _urlEncode() {
    final res = DeveloperEngine.encodeUrl(_inputController.text);
    setState(() {
      _error = null;
      _output = res;
    });
  }

  void _urlDecode() {
    final res = DeveloperEngine.decodeUrl(_inputController.text);
    setState(() {
      _error = null;
      _output = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageScaffold(
      toolId: 'utilities',
      title: 'Developer Utilities',
      description: 'Format JSON, minify strings, URL encode/decode, and Base64 convert.',
      icon: Icons.terminal_rounded,
      onBack: () => context.pop(),
      onRefresh: () {
        _inputController.text = '{"name":"Kreate","open_source":true}';
        _formatJson();
      },
      inputs: [
        TextField(
          controller: _inputController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Input Payload',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: KSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(icon: const Icon(Icons.code), label: const Text('Format JSON'), onPressed: _formatJson),
            ElevatedButton.icon(icon: const Icon(Icons.compress), label: const Text('Minify JSON'), onPressed: _minifyJson),
            OutlinedButton(onPressed: _base64Encode, child: const Text('Base64 Encode')),
            OutlinedButton(onPressed: _base64Decode, child: const Text('Base64 Decode')),
            OutlinedButton(onPressed: _urlEncode, child: const Text('URL Encode')),
            OutlinedButton(onPressed: _urlDecode, child: const Text('URL Decode')),
          ],
        ),
      ],
      results: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.redAccent))
        else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Processed Output', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _output));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                },
              ),
            ],
          ),
          const SizedBox(height: KSpacing.xs),
          KGlassCard(
            padding: const EdgeInsets.all(KSpacing.md),
            child: SelectableText(
              _output.isEmpty ? 'No output' : _output,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }
}

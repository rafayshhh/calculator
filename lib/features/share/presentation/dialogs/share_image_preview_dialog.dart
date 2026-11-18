import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/k_spacing.dart';
import '../../../../core/theme/k_theme_extension.dart';
import '../../domain/calculation_share_data.dart';
import '../../services/image_share_service.dart';
import '../widgets/calculation_share_card.dart';

class ShareImagePreviewDialog extends ConsumerStatefulWidget {
  final CalculationShareData data;

  const ShareImagePreviewDialog({
    super.key,
    required this.data,
  });

  static Future<void> show(
    BuildContext context,
    CalculationShareData data,
  ) {
    return showDialog(
      context: context,
      builder: (context) => ShareImagePreviewDialog(data: data),
    );
  }

  @override
  ConsumerState<ShareImagePreviewDialog> createState() =>
      _ShareImagePreviewDialogState();
}

class _ShareImagePreviewDialogState
    extends ConsumerState<ShareImagePreviewDialog> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isProcessing = false;

  Future<void> _shareImage() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final bytes = await ImageShareService.capturePng(_boundaryKey);
    if (bytes != null && mounted) {
      final filename =
          'kreate_calc_${DateTime.now().millisecondsSinceEpoch ~/ 1000}.png';
      await ImageShareService.shareImageFile(
        context,
        bytes,
        filename,
        text:
            '${widget.data.title}: ${widget.data.result} #KreateCalculator',
      );
    }
    if (mounted) {
      setState(() => _isProcessing = false);
      Navigator.of(context).pop();
    }
  }

  Future<void> _copyImage() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final bytes = await ImageShareService.capturePng(_boundaryKey);
    if (bytes != null && mounted) {
      final filename =
          'kreate_calc_${DateTime.now().millisecondsSinceEpoch ~/ 1000}.png';
      await ImageShareService.saveImageToDevice(context, bytes, filename);
    }
    if (mounted) {
      setState(() => _isProcessing = false);
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveImage() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final bytes = await ImageShareService.capturePng(_boundaryKey);
    if (bytes != null && mounted) {
      final filename =
          'kreate_calc_${DateTime.now().millisecondsSinceEpoch ~/ 1000}.png';
      await ImageShareService.saveImageToDevice(context, bytes, filename);
    }
    if (mounted) {
      setState(() => _isProcessing = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.kPalette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = palette.textPrimary;
    final textMuted = palette.textMuted;
    final primaryAccent = palette.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: palette.backgroundElevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: palette.glassBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.lg,
                  KSpacing.md,
                  KSpacing.sm,
                  KSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share as Image',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(
                color: palette.glassBorder,
                height: 1,
              ),

              // Preview Card Area
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(KSpacing.md),
                  child: Center(
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: CalculationShareCard(
                        data: widget.data,
                      ),
                    ),
                  ),
                ),
              ),

              Divider(
                color: palette.glassBorder,
                height: 1,
              ),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.all(KSpacing.md),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: KSpacing.sm,
                  runSpacing: KSpacing.xs,
                  children: [
                    TextButton(
                      onPressed: _isProcessing
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        'Close',
                        style: TextStyle(color: textMuted),
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Image'),
                      onPressed: _isProcessing ? null : _copyImage,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Save Image'),
                      onPressed: _isProcessing ? null : _saveImage,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      icon: _isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                            )
                          : const Icon(Icons.share_rounded, size: 16),
                      label: Text(
                        _isProcessing ? 'Processing...' : 'Share',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isProcessing ? null : _shareImage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

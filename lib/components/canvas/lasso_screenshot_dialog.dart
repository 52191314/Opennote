/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:super_clipboard/super_clipboard.dart';

/// Modal dialog displaying a high-resolution raster screenshot preview
/// of lasso-selected content with copy-to-clipboard and share actions.
class LassoScreenshotDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final VoidCallback? onCopied;

  const LassoScreenshotDialog({
    super.key,
    required this.imageBytes,
    this.onCopied,
  });

  @override
  State<LassoScreenshotDialog> createState() => _LassoScreenshotDialogState();
}

class _LassoScreenshotDialogState extends State<LassoScreenshotDialog> {
  var _isCopying = false;
  var _isSharing = false;

  Future<void> _copyToClipboard() async {
    if (_isCopying) return;
    setState(() => _isCopying = true);

    try {
      final item = DataWriterItem();
      item.add(Formats.png(widget.imageBytes));
      await SystemClipboard.instance?.write([item]);
      HapticFeedback.mediumImpact();

      if (!mounted) return;
      widget.onCopied?.call();
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isCopying = false);
    }
  }

  Future<void> _shareImage() async {
    if (_isSharing) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    final origin = renderBox != null
        ? renderBox.localToGlobal(Offset.zero) & renderBox.size
        : null;

    setState(() => _isSharing = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/lasso_screenshot_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(widget.imageBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
          sharePositionOrigin: origin,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      title: Row(
        children: [
          Icon(Icons.crop_free_rounded, color: colorScheme.primary, size: 24),
          const SizedBox(width: 10),
          Text(
            'Screenshot',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 380,
          maxHeight: 340,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          padding: const EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: InteractiveViewer(
              maxScale: 3.0,
              child: Image.memory(
                widget.imageBytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: [
        OutlinedButton.icon(
          onPressed: _shareImage,
          icon: _isSharing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.share_rounded, size: 18),
          label: const Text('Share'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: _copyToClipboard,
          icon: _isCopying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.copy_rounded, size: 18),
          label: const Text('Copy'),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

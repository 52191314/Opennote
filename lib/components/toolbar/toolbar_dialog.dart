/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/material.dart';

/// A rounded dialog with an icon, a title, and a close button above [child].
///
/// The editor's toolbars show their settings in these.
class ToolbarDialog extends StatelessWidget {
  const ToolbarDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.iconSize = 20,
    this.titleSize = 16,
    this.maxWidth = 380,
    this.verticalPadding = 16,
  });

  /// The icon shown before [title].
  final IconData icon;

  /// The size of [icon].
  final double iconSize;

  /// What the dialog is for.
  final String title;

  /// The font size of [title].
  final double titleSize;

  /// The widest the dialog may grow.
  final double maxWidth;

  /// The space above the title and below [child].
  final double verticalPadding;

  /// The settings shown under the title.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: verticalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: iconSize, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

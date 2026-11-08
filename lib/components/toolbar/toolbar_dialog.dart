/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/material.dart';

/// An Opennote Studio floating popover card dialog with an icon badge,
/// a title, a subtle header divider, and a close button above [child].
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
      elevation: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.96, end: 1.0),
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        builder: (context, scale, dialogCard) =>
            Transform.scale(scale: scale, child: dialogCard),
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.65),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
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
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.65,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        icon,
                        size: iconSize,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                thickness: 0.75,
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Floating callout action pill appearing directly above/below a lasso selection
/// providing quick in-context actions (Cut, Copy, Duplicate, Color, Delete).
class LassoCalloutMenu extends StatefulWidget {
  final VoidCallback onCut;
  final VoidCallback onCopy;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final void Function(Color color) onSetColor;
  final Color? currentColor;
  final bool cropPossible;
  final bool cropActive;
  final VoidCallback? onToggleCrop;
  final double currentScale;

  const LassoCalloutMenu({
    super.key,
    required this.onCut,
    required this.onCopy,
    required this.onDuplicate,
    required this.onDelete,
    required this.onSetColor,
    this.currentColor,
    this.cropPossible = false,
    this.cropActive = false,
    this.onToggleCrop,
    this.currentScale = 1.0,
  });

  @override
  State<LassoCalloutMenu> createState() => _LassoCalloutMenuState();
}

class _LassoCalloutMenuState extends State<LassoCalloutMenu> {
  var _showColorPicker = false;

  static const _quickColors = [
    Color(0xFF000000), // Black
    Color(0xFF1976D2), // Blue
    Color(0xFFD32F2F), // Red
    Color(0xFF388E3C), // Green
    Color(0xFFFBC02D), // Yellow
    Color(0xFF7B1FA2), // Purple
    Color(0xFFF57C00), // Orange
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final divider = Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
    );

    // Counter-scale so the callout maintains a comfortable readable size on zoomed canvas
    final scaleMultiplier = (1.0 / widget.currentScale).clamp(0.65, 1.4);

    return Transform.scale(
      scale: scaleMultiplier,
      alignment: Alignment.center,
      child: Material(
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 0.75,
            ),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: _showColorPicker
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setState(() => _showColorPicker = false),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      divider,
                      const SizedBox(width: 4),
                      for (final color in _quickColors)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkResponse(
                            radius: 14,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onSetColor(color);
                            },
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CalloutButton(
                        icon: Icons.content_cut_rounded,
                        label: 'Cut',
                        onTap: widget.onCut,
                      ),
                      divider,
                      _CalloutButton(
                        icon: Icons.copy_rounded,
                        label: 'Copy',
                        onTap: widget.onCopy,
                      ),
                      divider,
                      _CalloutButton(
                        icon: Icons.control_point_duplicate_rounded,
                        label: 'Duplicate',
                        onTap: widget.onDuplicate,
                      ),
                      divider,
                      _CalloutButton(
                        icon: Icons.palette_outlined,
                        label: 'Color',
                        onTap: () => setState(() => _showColorPicker = true),
                      ),
                      divider,
                      _CalloutButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        isDestructive: true,
                        onTap: widget.onDelete,
                      ),
                      if (widget.cropPossible) ...[
                        divider,
                        _CalloutButton(
                          icon: widget.cropActive
                              ? Icons.check_rounded
                              : Icons.crop_rounded,
                          label: widget.cropActive ? 'Done' : 'Crop',
                          onTap: widget.onToggleCrop,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CalloutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _CalloutButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? Colors.redAccent
        : theme.colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

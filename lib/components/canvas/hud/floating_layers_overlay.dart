/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/data/editor/page.dart';

/// A floating HUD widget that provides quick, non-intrusive access to canvas layers.
///
/// Features:
/// - Collapsed pill badge indicating active layer and lock state.
/// - Smooth expanding card with layer list, active selector, visibility/lock toggles,
///   layer deletion, and quick "+ Add Layer" creation.
class FloatingLayersOverlay extends StatefulWidget {
  final EditorPage? page;
  final VoidCallback onChanged;

  const FloatingLayersOverlay({
    super.key,
    required this.page,
    required this.onChanged,
  });

  @override
  State<FloatingLayersOverlay> createState() => _FloatingLayersOverlayState();
}

class _FloatingLayersOverlayState extends State<FloatingLayersOverlay>
    with SingleTickerProviderStateMixin {
  var _expanded = false;

  void _addLayer() {
    final page = widget.page;
    if (page == null) return;
    setState(() {
      final newIndex = page.layers.length + 1;
      page.layers.add(Layer(name: 'Layer $newIndex'));
      page.activeLayerIndex = page.layers.length - 1;
    });
    widget.onChanged();
  }

  void _removeLayer(int index) {
    final page = widget.page;
    if (page == null || page.layers.length <= 1) return;
    setState(() {
      page.layers.removeAt(index);
      if (page.activeLayerIndex >= page.layers.length) {
        page.activeLayerIndex = page.layers.length - 1;
      }
    });
    widget.onChanged();
  }

  void _toggleVisibility(int index) {
    final page = widget.page;
    if (page == null) return;
    setState(() {
      page.layers[index].visible = !page.layers[index].visible;
    });
    widget.onChanged();
  }

  void _toggleLock(int index) {
    final page = widget.page;
    if (page == null) return;
    setState(() {
      page.layers[index].locked = !page.layers[index].locked;
    });
    widget.onChanged();
  }

  void _selectActiveLayer(int index) {
    final page = widget.page;
    if (page == null) return;
    setState(() {
      page.activeLayerIndex = index;
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    if (page == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeLayer = page.activeLayer;

    if (!_expanded) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _expanded = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: activeLayer.locked
                    ? colorScheme.error.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  activeLayer.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (activeLayer.locked) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.lock, size: 13, color: colorScheme.error),
                ],
                const SizedBox(width: 4),
                Icon(
                  Icons.unfold_more,
                  size: 14,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 270,
        constraints: const BoxConstraints(maxHeight: 340),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 6,
                top: 8,
                bottom: 4,
              ),
              child: Row(
                children: [
                  Icon(Icons.layers, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Layers (${page.layers.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    tooltip: 'Add Layer',
                    visualDensity: VisualDensity.compact,
                    onPressed: _addLayer,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _expanded = false),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Layer list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                itemCount: page.layers.length,
                separatorBuilder: (context, _) => const SizedBox(height: 3),
                itemBuilder: (context, index) {
                  final layer = page.layers[index];
                  final isActive = index == page.activeLayerIndex;

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primaryContainer.withValues(alpha: 0.7)
                          : colorScheme.surface.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: isActive
                          ? Border.all(color: colorScheme.primary, width: 1.5)
                          : null,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _selectActiveLayer(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            // Active indicator
                            Icon(
                              isActive
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: 16,
                              color: isActive
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.6,
                                    ),
                            ),
                            const SizedBox(width: 8),

                            // Layer title & stroke count
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    layer.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${layer.strokes.length} strokes',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Visibility toggle
                            IconButton(
                              icon: Icon(
                                layer.visible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 16,
                                color: layer.visible
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.outline,
                              ),
                              tooltip: layer.visible
                                  ? 'Hide Layer'
                                  : 'Show Layer',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 26,
                                minHeight: 26,
                              ),
                              onPressed: () => _toggleVisibility(index),
                            ),

                            // Lock toggle
                            IconButton(
                              icon: Icon(
                                layer.locked ? Icons.lock : Icons.lock_open,
                                size: 16,
                                color: layer.locked
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant,
                              ),
                              tooltip: layer.locked
                                  ? 'Unlock Layer'
                                  : 'Lock Layer',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 26,
                                minHeight: 26,
                              ),
                              onPressed: () => _toggleLock(index),
                            ),

                            // Delete button (if >1 layer)
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: page.layers.length > 1
                                    ? colorScheme.error.withValues(alpha: 0.8)
                                    : colorScheme.outline.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                              tooltip: page.layers.length > 1
                                  ? 'Delete Layer'
                                  : null,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 26,
                                minHeight: 26,
                              ),
                              onPressed: page.layers.length > 1
                                  ? () => _removeLayer(index)
                                  : null,
                            ),
                          ],
                        ),
                      ),
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

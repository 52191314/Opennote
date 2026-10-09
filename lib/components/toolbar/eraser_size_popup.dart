/// 🤖 Generated wholely or partially with DeepSeek v4 Flash; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

/// A popup dialog that allows the user to change the eraser size and options.
/// Triggered by long-pressing or tapping the eraser toolbar button.
class EraserSizePopup extends StatefulWidget {
  const EraserSizePopup({super.key, this.onClearPage});

  final VoidCallback? onClearPage;

  @override
  State<EraserSizePopup> createState() => _EraserSizePopupState();
}

class _EraserSizePopupState extends State<EraserSizePopup> {
  double _eraserSize = stows.eraserSize.value;

  static const double _minSize = 10;
  static const double _maxSize = 100;

  void _onSliderChanged(double value) {
    setState(() {
      _eraserSize = value;
      stows.eraserSize.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.eraser,
                    size: 20,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.editor.eraser.settings,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                t.editor.eraser.style,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment<String>(
                    value: 'object',
                    label: Text(t.editor.eraser.object),
                    icon: const Icon(Icons.blur_linear_rounded, size: 16),
                  ),
                  ButtonSegment<String>(
                    value: 'precision',
                    label: Text(t.editor.eraser.precision),
                    icon: const Icon(Icons.adjust_rounded, size: 16),
                  ),
                ],
                selected: {stows.eraserMode.value},
                onSelectionChanged: (selected) {
                  if (selected.isNotEmpty) {
                    setState(() {
                      stows.eraserMode.value = selected.first;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    t.editor.penOptions.size,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _eraserSize.round().toString(),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: colorScheme.primary,
                  inactiveTrackColor: colorScheme.onSurface.withValues(
                    alpha: 0.2,
                  ),
                  thumbColor: colorScheme.primary,
                  overlayColor: colorScheme.primary.withValues(alpha: 0.12),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _eraserSize,
                  min: _minSize,
                  max: _maxSize,
                  divisions: 18, // steps of 5
                  onChanged: _onSliderChanged,
                ),
              ),
              const SizedBox(height: 6),
              // Preview circle showing the actual eraser size
              SizedBox(
                height: 40,
                child: Center(
                  child: Container(
                    width: (_eraserSize / _maxSize) * 80,
                    height: (_eraserSize / _maxSize) * 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 24),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(t.editor.eraser.autoDeselect),
                subtitle: Text(t.editor.eraser.autoDeselectDescription),
                value: stows.disableEraserAfterUse.value,
                onChanged: (val) {
                  setState(() {
                    stows.disableEraserAfterUse.value = val;
                  });
                },
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(t.editor.eraser.highlighterOnly),
                subtitle: Text(t.editor.eraser.highlighterOnlyDescription),
                value: stows.eraserEraseHighlighterOnly.value,
                onChanged: (val) {
                  setState(() {
                    stows.eraserEraseHighlighterOnly.value = val;
                  });
                },
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(t.editor.eraser.tapeOnly),
                subtitle: Text(t.editor.eraser.tapeOnlyDescription),
                value: stows.eraserEraseTapeOnly.value,
                onChanged: (val) {
                  setState(() {
                    stows.eraserEraseTapeOnly.value = val;
                  });
                },
              ),
              if (widget.onClearPage != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onClearPage!();
                  },
                  icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                  label: Text(t.editor.eraser.clearPage),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

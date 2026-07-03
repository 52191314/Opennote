/// 🤖 Generated with DeepSeek v4 Flash
library;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

/// A popup dialog that allows the user to change the eraser size.
/// Triggered by long-pressing the eraser toolbar button.
class EraserSizePopup extends StatefulWidget {
  const EraserSizePopup({super.key});

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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.eraser,
                size: 20,
                color: colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                t.editor.toolbar.toggleEraser,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
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
              inactiveTrackColor: colorScheme.onSurface.withValues(alpha: 0.2),
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
          const SizedBox(height: 8),
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
        ],
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

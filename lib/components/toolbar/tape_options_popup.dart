/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/study_tape.dart';

/// A sleek Goodnotes-style options dialog for the [StudyTapeTool].
///
/// Allows choosing between tape patterns (solid, stripes, dots, grid),
/// selecting tape colors, and triggering "Reveal All" or "Conceal All" study actions.
class TapeOptionsPopup extends StatefulWidget {
  const TapeOptionsPopup({
    super.key,
    required this.currentTapeTool,
    this.onRevealAll,
    this.onConcealAll,
    this.onTapeChanged,
  });

  final StudyTapeTool currentTapeTool;
  final VoidCallback? onRevealAll;
  final VoidCallback? onConcealAll;
  final VoidCallback? onTapeChanged;

  @override
  State<TapeOptionsPopup> createState() => _TapeOptionsPopupState();

  static const presetColors = [
    Color(0xFFFFD54F), // Pastel Yellow
    Color(0xFFA5D6A7), // Pastel Mint Green
    Color(0xFF90CAF9), // Pastel Soft Blue
    Color(0xFFF48FB1), // Pastel Pink
    Color(0xFFCE93D8), // Pastel Lavender
    Color(0xFFFFCC80), // Pastel Peach
  ];
}

class _TapeOptionsPopupState extends State<TapeOptionsPopup> {
  late TapePattern _selectedPattern;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedPattern = widget.currentTapeTool.pattern;
    _selectedColor = widget.currentTapeTool.color;
  }

  void _setPattern(TapePattern pattern) {
    setState(() {
      _selectedPattern = pattern;
      widget.currentTapeTool.pattern = pattern;
      stows.studyTapePattern.value = pattern.name;
    });
    widget.onTapeChanged?.call();
  }

  void _setColor(Color color) {
    setState(() {
      _selectedColor = color;
      widget.currentTapeTool.color = color;
    });
    widget.onTapeChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.view_headline_rounded,
                  size: 22,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Study Tape Options',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Tape Pattern',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<TapePattern>(
              segments: const [
                ButtonSegment(
                  value: TapePattern.solid,
                  label: Text('Solid'),
                  icon: Icon(Icons.rectangle, size: 16),
                ),
                ButtonSegment(
                  value: TapePattern.stripes,
                  label: Text('Stripes'),
                  icon: Icon(Icons.texture, size: 16),
                ),
                ButtonSegment(
                  value: TapePattern.dots,
                  label: Text('Dots'),
                  icon: Icon(Icons.blur_on, size: 16),
                ),
                ButtonSegment(
                  value: TapePattern.grid,
                  label: Text('Grid'),
                  icon: Icon(Icons.grid_4x4, size: 16),
                ),
              ],
              selected: {_selectedPattern},
              onSelectionChanged: (selected) {
                if (selected.isNotEmpty) _setPattern(selected.first);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Tape Color',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final color in TapeOptionsPopup.presetColors)
                  GestureDetector(
                    onTap: () => _setColor(color),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? colorScheme.primary
                              : Colors.black26,
                          width: _selectedColor == color ? 2.5 : 1.0,
                        ),
                        boxShadow: [
                          if (_selectedColor == color)
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                      child: _selectedColor == color
                          ? const Icon(
                              Icons.check,
                              size: 20,
                              color: Colors.black87,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
            if (widget.onRevealAll != null || widget.onConcealAll != null) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Active Recall Study Controls',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (widget.onRevealAll != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Reveal All'),
                        onPressed: () {
                          widget.onRevealAll?.call();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  if (widget.onRevealAll != null && widget.onConcealAll != null)
                    const SizedBox(width: 8),
                  if (widget.onConcealAll != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.visibility_off, size: 16),
                        label: const Text('Conceal All'),
                        onPressed: () {
                          widget.onConcealAll?.call();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                ],
              ),
            ],
          ],
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

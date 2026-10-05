/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';

/// Pinned 3-color and 3-thickness quick access palette bar (Goodnotes ergonomics).
/// Allows 1-tap switching between lecture colors and stroke widths.
class QuickPaletteBar extends StatefulWidget {
  const QuickPaletteBar({
    super.key,
    required this.axis,
    required this.currentTool,
    required this.setColor,
    required this.onUpdate,
    this.invert = false,
  });

  final Axis axis;
  final Tool currentTool;
  final ValueChanged<Color> setColor;
  final VoidCallback onUpdate;
  final bool invert;

  @override
  State<QuickPaletteBar> createState() => _QuickPaletteBarState();
}

class _QuickPaletteBarState extends State<QuickPaletteBar> {
  bool get _isHighlighter => widget.currentTool is Highlighter;

  List<int> get _colorSlots => _isHighlighter
      ? stows.quickColorsHighlighter.value
      : stows.quickColorsPen.value;

  List<double> get _sizeSlots => _isHighlighter
      ? stows.quickSizesHighlighter.value
      : stows.quickSizesPen.value;

  int get _activeColorIdx => _isHighlighter
      ? stows.activeQuickColorIndexHighlighter.value
      : stows.activeQuickColorIndexPen.value;

  int get _activeSizeIdx => _isHighlighter
      ? stows.activeQuickSizeIndexHighlighter.value
      : stows.activeQuickSizeIndexPen.value;

  void _setActiveColor(int index) {
    if (index < 0 || index >= _colorSlots.length) return;
    final colorVal = _colorSlots[index];
    final color = Color(colorVal);

    setState(() {
      if (_isHighlighter) {
        stows.activeQuickColorIndexHighlighter.value = index;
      } else {
        stows.activeQuickColorIndexPen.value = index;
      }
    });

    widget.setColor(color);
  }

  void _setActiveSize(int index) {
    if (index < 0 || index >= _sizeSlots.length) return;
    final size = _sizeSlots[index];

    setState(() {
      if (_isHighlighter) {
        stows.activeQuickSizeIndexHighlighter.value = index;
      } else {
        stows.activeQuickSizeIndexPen.value = index;
      }
    });

    if (widget.currentTool is Pen) {
      (widget.currentTool as Pen).options.size = size;
      widget.onUpdate();
    }
  }

  Future<void> _editColorSlot(int index) async {
    final currentColor = Color(_colorSlots[index]);
    final result = await showDialog<Color>(
      context: context,
      builder: (ctx) => _ColorSlotPickerDialog(
        initialColor: currentColor,
        isHighlighter: _isHighlighter,
      ),
    );

    if (result != null && mounted) {
      final updated = List<int>.from(_colorSlots);
      updated[index] = result.toARGB32();
      setState(() {
        if (_isHighlighter) {
          stows.quickColorsHighlighter.value = updated;
        } else {
          stows.quickColorsPen.value = updated;
        }
      });
      _setActiveColor(index);
    }
  }

  Future<void> _editSizeSlot(int index) async {
    final currentSize = _sizeSlots[index];
    final minSize = _isHighlighter ? 5.0 : 1.0;
    final maxSize = _isHighlighter ? 60.0 : 30.0;

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => _SizeSlotSliderDialog(
        initialSize: currentSize,
        minSize: minSize,
        maxSize: maxSize,
      ),
    );

    if (result != null && mounted) {
      final updated = List<double>.from(_sizeSlots);
      updated[index] = result;
      setState(() {
        if (_isHighlighter) {
          stows.quickSizesHighlighter.value = updated;
        } else {
          stows.quickSizesPen.value = updated;
        }
      });
      _setActiveSize(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isVertical = widget.axis == Axis.vertical;

    final colorButtons = List.generate(_colorSlots.length, (idx) {
      final color = Color(_colorSlots[idx]);
      final isSelected = idx == _activeColorIdx;
      final displayColor = color
          .withInversion(widget.invert)
          .withValues(alpha: 1);

      return GestureDetector(
        key: ValueKey('quick_color_$idx'),
        onTap: () => _setActiveColor(idx),
        onLongPress: () => _editColorSlot(idx),
        onDoubleTap: () => _editColorSlot(idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: displayColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.black26,
              width: isSelected ? 2.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: displayColor.computeLuminance() > 0.5
                          ? Colors.black87
                          : Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
      );
    });

    final sizeButtons = List.generate(_sizeSlots.length, (idx) {
      final size = _sizeSlots[idx];
      final isSelected = idx == _activeSizeIdx;
      // Visual dot radius mapped to slot index
      final dotRadius = 3.0 + idx * 2.5;

      return Tooltip(
        message: '${size.toStringAsFixed(1)} pt',
        child: GestureDetector(
          key: ValueKey('quick_size_$idx'),
          onTap: () => _setActiveSize(idx),
          onLongPress: () => _editSizeSlot(idx),
          onDoubleTap: () => _editSizeSlot(idx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Container(
                width: dotRadius * 2,
                height: dotRadius * 2,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Flex(
        direction: widget.axis,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flex(
            direction: widget.axis,
            mainAxisSize: MainAxisSize.min,
            children: colorButtons,
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: isVertical ? 0 : 4,
              vertical: isVertical ? 4 : 0,
            ),
            width: isVertical ? 16 : 1,
            height: isVertical ? 1 : 16,
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          Flex(
            direction: widget.axis,
            mainAxisSize: MainAxisSize.min,
            children: sizeButtons,
          ),
        ],
      ),
    );
  }
}

class _ColorSlotPickerDialog extends StatelessWidget {
  const _ColorSlotPickerDialog({
    required this.initialColor,
    required this.isHighlighter,
  });

  final Color initialColor;
  final bool isHighlighter;

  @override
  Widget build(BuildContext context) {
    final colors = isHighlighter
        ? [
            Colors.yellow,
            Colors.lightGreen,
            Colors.pinkAccent,
            Colors.lightBlueAccent,
            Colors.orangeAccent,
            Colors.purpleAccent,
            const Color(0xFFFFFF00),
            const Color(0xFF66BB6A),
            const Color(0xFFFF80AB),
            const Color(0xFF80D8FF),
          ]
        : [
            Colors.black,
            const Color(0xFF1976D2), // Blue
            const Color(0xFFE53935), // Red
            const Color(0xFF388E3C), // Green
            const Color(0xFF8E24AA), // Purple
            const Color(0xFFF57C00), // Orange
            const Color(0xFF00897B), // Teal
            const Color(0xFF5D4037), // Brown
            const Color(0xFF546E7A), // Blue Grey
            Colors.white,
          ];

    return AlertDialog(
      title: Text(isHighlighter ? 'Highlighter Color Slot' : 'Pen Color Slot'),
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: colors.map((c) {
          final isSelected = c.toARGB32() == initialColor.toARGB32();
          return InkWell(
            onTap: () => Navigator.of(context).pop(c),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black26,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: c.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _SizeSlotSliderDialog extends StatefulWidget {
  const _SizeSlotSliderDialog({
    required this.initialSize,
    required this.minSize,
    required this.maxSize,
  });

  final double initialSize;
  final double minSize;
  final double maxSize;

  @override
  State<_SizeSlotSliderDialog> createState() => _SizeSlotSliderDialogState();
}

class _SizeSlotSliderDialogState extends State<_SizeSlotSliderDialog> {
  late double _currentSize;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.initialSize.clamp(widget.minSize, widget.maxSize);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adjust Stroke Width'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_currentSize.toStringAsFixed(1)} pt',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _currentSize,
            min: widget.minSize,
            max: widget.maxSize,
            divisions: ((widget.maxSize - widget.minSize) * 2).toInt(),
            onChanged: (v) => setState(() => _currentSize = v),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: _currentSize.clamp(2.0, 50.0),
              height: _currentSize.clamp(2.0, 50.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_currentSize),
          child: const Text('Set Width'),
        ),
      ],
    );
  }
}

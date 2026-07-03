import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/components/toolbar/size_picker.dart';
import 'package:saber/data/extensions/axis_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/shape_pen.dart';
import 'package:saber/i18n/strings.g.dart';

/// 🤖 Generated with DeepSeek v4 Flash

class PenModal extends StatefulWidget {
  const PenModal({super.key, required this.getTool, required this.setTool});

  final Tool Function() getTool;
  final void Function(Pen) setTool;

  @override
  State<PenModal> createState() => _PenModalState();
}

class _PenModalState extends State<PenModal> {
  @override
  Widget build(BuildContext context) {
    final axis = stows.editorToolbarAlignment.value.axis.opposite;
    final Tool currentTool = widget.getTool();
    final Pen currentPen;
    if (currentTool is Pen) {
      currentPen = currentTool;
    } else {
      return const SizedBox();
    }

    final content = Flex(
      direction: axis,
      mainAxisAlignment: .center,
      children: [
        SizePicker(axis: axis, pen: currentPen),
        if (currentPen.pressureEnabled) ...[
          const SizedBox.square(dimension: 8),
          _PressureCurveSlider(axis: axis),
        ],
        if (currentPen is! Highlighter && currentPen is! Pencil) ...[
          const SizedBox.square(dimension: 8),
          IconButton(
            onPressed: () => setState(() {
              widget.setTool(Pen.fountainPen());
            }),
            style: TextButton.styleFrom(
              foregroundColor: Pen.currentPen.icon == Pen.fountainPenIcon
                  ? ColorScheme.of(context).secondary
                  : ColorScheme.of(context).onSurface,
              backgroundColor: Pen.currentPen.icon == Pen.fountainPenIcon
                  ? Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: const CircleBorder(),
            ),
            tooltip: t.editor.pens.fountainPen,
            icon: SvgPicture.asset(
              'assets/images/scribble_fountain.svg',
              width: 32,
              height: 32 / 508 * 374,
              theme: SvgTheme(
                currentColor: Pen.currentPen.icon == Pen.fountainPenIcon
                    ? ColorScheme.of(context).secondary
                    : ColorScheme.of(context).onSurface,
              ),
            ),
          ),
          const SizedBox.square(dimension: 8),
          IconButton(
            onPressed: () => setState(() {
              widget.setTool(Pen.ballpointPen());
            }),
            style: TextButton.styleFrom(
              foregroundColor: Pen.currentPen.icon == Pen.ballpointPenIcon
                  ? ColorScheme.of(context).secondary
                  : ColorScheme.of(context).onSurface,
              backgroundColor: Pen.currentPen.icon == Pen.ballpointPenIcon
                  ? Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: const CircleBorder(),
            ),
            tooltip: t.editor.pens.ballpointPen,
            icon: SvgPicture.asset(
              'assets/images/scribble_ballpoint.svg',
              width: 32,
              height: 32 / 508 * 374,
              theme: SvgTheme(
                currentColor: Pen.currentPen.icon == Pen.ballpointPenIcon
                    ? ColorScheme.of(context).secondary
                    : ColorScheme.of(context).onSurface,
              ),
            ),
          ),
          const SizedBox.square(dimension: 8),
          IconButton(
            onPressed: () => setState(() {
              widget.setTool(ShapePen());
            }),
            style: TextButton.styleFrom(
              foregroundColor: Pen.currentPen.icon == ShapePen.shapePenIcon
                  ? ColorScheme.of(context).secondary
                  : ColorScheme.of(context).onSurface,
              backgroundColor: Pen.currentPen.icon == ShapePen.shapePenIcon
                  ? Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: const CircleBorder(),
            ),
            tooltip: t.editor.pens.shapePen,
            icon: const FaIcon(ShapePen.shapePenIcon),
          ),
        ],
        if (currentPen is! Pencil) ...[
          const SizedBox.square(dimension: 8),
          IconButton(
            onPressed: () {
              setState(() {
                stows.scribbleToErase.value = !stows.scribbleToErase.value;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: stows.scribbleToErase.value
                  ? ColorScheme.of(context).secondary
                  : ColorScheme.of(context).onSurface,
              backgroundColor: stows.scribbleToErase.value
                  ? Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: const CircleBorder(),
            ),
            tooltip: stows.scribbleToErase.value
                ? 'Scribble to Erase: ON'
                : 'Scribble to Erase: OFF',
            icon: const FaIcon(FontAwesomeIcons.repeat),
          ),
        ],
      ],
    );

    if (axis == Axis.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: content,
      );
    }
    return content;
  }
}

class _PressureCurveSlider extends StatefulWidget {
  const _PressureCurveSlider({required this.axis});

  final Axis axis;

  @override
  State<_PressureCurveSlider> createState() => _PressureCurveSliderState();
}

class _PressureCurveSliderState extends State<_PressureCurveSlider> {
  @override
  void initState() {
    super.initState();
    stows.penPressureCurve.addListener(onChanged);
  }

  void onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Curve',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: 10,
            height: 1,
          ),
        ),
        Text(stows.penPressureCurve.value.toStringAsFixed(1)),
        SizedBox(
          width: 80,
          child: Slider(
            value: stows.penPressureCurve.value,
            min: 0.3,
            max: 3.0,
            divisions: 27,
            onChanged: (value) {
              stows.penPressureCurve.value = value;
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    stows.penPressureCurve.removeListener(onChanged);
    super.dispose();
  }
}

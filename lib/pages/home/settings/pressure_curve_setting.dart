/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

/// Slider preference row for adjusting stylus pen pressure curve sensitivity.
class PressureCurveSetting extends StatefulWidget {
  const PressureCurveSetting({super.key});

  @override
  State<PressureCurveSetting> createState() => _PressureCurveSettingState();
}

class _PressureCurveSettingState extends State<PressureCurveSetting> {
  @override
  void initState() {
    super.initState();
    stows.penPressureCurve.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.settings.prefLabels.penPressureCurve,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle:
                        stows.penPressureCurve.value !=
                            stows.penPressureCurve.defaultValue
                        ? FontStyle.italic
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.settings.prefDescriptions.penPressureCurve,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            stows.penPressureCurve.value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(
            width: 150,
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
      ),
    );
  }

  @override
  void dispose() {
    stows.penPressureCurve.removeListener(_onChanged);
    super.dispose();
  }
}

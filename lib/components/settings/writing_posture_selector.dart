/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/palm_rejection.dart';
import 'package:saber/i18n/strings.g.dart';

/// Goodnotes-inspired writing posture and palm rejection selector widget.
class WritingPostureSelector extends StatefulWidget {
  const WritingPostureSelector({super.key, this.compact = false});

  /// Whether to render in a compact layout suitable for popups and dialogs.
  final bool compact;

  @override
  State<WritingPostureSelector> createState() => _WritingPostureSelectorState();
}

class _WritingPostureSelectorState extends State<WritingPostureSelector> {
  @override
  void initState() {
    super.initState();
    stows.writingPosture.addListener(_onPrefsChanged);
    stows.palmRejectionSensitivity.addListener(_onPrefsChanged);
  }

  @override
  void dispose() {
    stows.writingPosture.removeListener(_onPrefsChanged);
    stows.palmRejectionSensitivity.removeListener(_onPrefsChanged);
    super.dispose();
  }

  void _onPrefsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final posture = stows.writingPosture.value;
    final sensitivity = stows.palmRejectionSensitivity.value;
    final isRightHanded = posture.isRightHanded;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 0 : 16,
        vertical: widget.compact ? 0 : 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.hand_draw_fill,
                size: 22,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.settings.prefLabels.writingPosture,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      t.settings.prefDescriptions.writingPosture,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Handedness Selector
          Center(
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment<bool>(
                  value: true,
                  label: Text(t.settings.writingPosture.handRight),
                  icon: const Icon(Symbols.pan_tool_rounded, size: 18),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text(t.settings.writingPosture.handLeft),
                  icon: Transform.flip(
                    flipX: true,
                    child: const Icon(Symbols.pan_tool_rounded, size: 18),
                  ),
                ),
              ],
              selected: {isRightHanded},
              onSelectionChanged: (newSelection) {
                final rightHanded = newSelection.first;
                final newPosture = switch (posture) {
                  WritingPosture.rightBelow || WritingPosture.leftBelow =>
                    rightHanded
                        ? WritingPosture.rightBelow
                        : WritingPosture.leftBelow,
                  WritingPosture.rightLevel || WritingPosture.leftLevel =>
                    rightHanded
                        ? WritingPosture.rightLevel
                        : WritingPosture.leftLevel,
                  WritingPosture.rightAbove || WritingPosture.leftAbove =>
                    rightHanded
                        ? WritingPosture.rightAbove
                        : WritingPosture.leftAbove,
                };
                stows.writingPosture.value = newPosture;
              },
            ),
          ),
          const SizedBox(height: 12),

          // 3 Visual Posture Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 420;
              final cards = [
                _buildPostureCard(
                  context: context,
                  targetPosture: isRightHanded
                      ? WritingPosture.rightBelow
                      : WritingPosture.leftBelow,
                  currentPosture: posture,
                  icon: isRightHanded
                      ? Symbols.edit_rounded
                      : Symbols.edit_rounded,
                  title: t.settings.writingPosture.postureBelow,
                  subtitle: t.settings.writingPosture.postureBelowDesc,
                ),
                _buildPostureCard(
                  context: context,
                  targetPosture: isRightHanded
                      ? WritingPosture.rightLevel
                      : WritingPosture.leftLevel,
                  currentPosture: posture,
                  icon: Symbols.border_horizontal_rounded,
                  title: t.settings.writingPosture.postureLevel,
                  subtitle: t.settings.writingPosture.postureLevelDesc,
                ),
                _buildPostureCard(
                  context: context,
                  targetPosture: isRightHanded
                      ? WritingPosture.rightAbove
                      : WritingPosture.leftAbove,
                  currentPosture: posture,
                  icon: Symbols.turn_slight_left_rounded,
                  title: t.settings.writingPosture.postureAbove,
                  subtitle: t.settings.writingPosture.postureAboveDesc,
                ),
              ];

              if (isWide) {
                return Row(
                  children: [
                    for (int i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              } else {
                return Column(
                  children: [
                    for (int i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      cards[i],
                    ],
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Sensitivity Section
          Text(
            t.settings.prefLabels.palmRejectionSensitivity,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            t.settings.prefDescriptions.palmRejectionSensitivity,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SegmentedButton<PalmRejectionSensitivity>(
              segments: [
                ButtonSegment(
                  value: PalmRejectionSensitivity.disabled,
                  label: Text(t.settings.palmRejectionSensitivity.disabled),
                ),
                ButtonSegment(
                  value: PalmRejectionSensitivity.low,
                  label: Text(t.settings.palmRejectionSensitivity.low),
                ),
                ButtonSegment(
                  value: PalmRejectionSensitivity.medium,
                  label: Text(t.settings.palmRejectionSensitivity.medium),
                ),
                ButtonSegment(
                  value: PalmRejectionSensitivity.high,
                  label: Text(t.settings.palmRejectionSensitivity.high),
                ),
              ],
              selected: {sensitivity},
              onSelectionChanged: (newSelection) {
                stows.palmRejectionSensitivity.value = newSelection.first;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostureCard({
    required BuildContext context,
    required WritingPosture targetPosture,
    required WritingPosture currentPosture,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = targetPosture == currentPosture;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.7)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => stows.writingPosture.value = targetPosture,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

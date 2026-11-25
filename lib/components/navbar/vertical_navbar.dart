/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/files/file_tree.dart';
import 'package:saber/components/home/search_dialog.dart';
import 'package:saber/components/home/syncing_button.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';

/// Compact studio navigation rail for tablet and desktop layouts, expanding
/// smoothly into a full workspace sidebar on wide viewports.
class VerticalNavbar extends HookWidget {
  const VerticalNavbar({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
  });

  final List<NavigationRailDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final manualExpanded = useState<bool?>(null);
    final expanded = manualExpanded.value ?? (screenWidth >= 960);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = switch (theme.platform) {
      .linux => Colors.transparent,
      _ =>
        isDark
            ? OpennoteTokens.cardDarkSurface
            : colorScheme.surfaceContainerLow,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      width: expanded ? 252 : 74,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: BorderDirectional(
          end: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.32),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        right: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: OpennoteTokens.s2),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? OpennoteTokens.s3 : 8,
                vertical: OpennoteTokens.s2,
              ),
              child: expanded
                  ? Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(
                              alpha: isDark ? 0.22 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(
                              OpennoteTokens.radiusSm,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Icon(
                              Icons.edit_note_rounded,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: OpennoteTokens.s2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Opennote',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Studio',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Collapse sidebar',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => manualExpanded.value = !expanded,
                          icon: const AdaptiveIcon(
                            icon: Icons.chevron_left_rounded,
                            cupertinoIcon: CupertinoIcons.chevron_left,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: IconButton(
                        tooltip: 'Expand sidebar',
                        onPressed: () => manualExpanded.value = !expanded,
                        icon: const AdaptiveIcon(
                          icon: Icons.chevron_right_rounded,
                          cupertinoIcon: CupertinoIcons.chevron_right,
                        ),
                      ),
                    ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OpennoteTokens.s3,
                  vertical: 4,
                ),
                child: Material(
                  color: colorScheme.surfaceContainerHigh.withValues(
                    alpha: 0.72,
                  ),
                  borderRadius: BorderRadius.circular(
                    OpennoteTokens.radiusPill,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      OpennoteTokens.radiusPill,
                    ),
                    onTap: () => SearchDialog.show(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.home.search.hint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1.5,
                              ),
                              child: Text(
                                '⌘K',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: IconButton(
                  tooltip: t.home.search.hint,
                  icon: const Icon(Icons.search_rounded, size: 20),
                  onPressed: () => SearchDialog.show(context),
                ),
              ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  OpennoteTokens.s3,
                  6,
                  OpennoteTokens.s3,
                  4,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push(RoutePaths.edit),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(t.home.create.newNote),
                    style: FilledButton.styleFrom(
                      alignment: AlignmentDirectional.centerStart,
                      padding: const EdgeInsets.symmetric(
                        horizontal: OpennoteTokens.s3,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          OpennoteTokens.radiusSm,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: IconButton.filledTonal(
                  tooltip: t.home.create.newNote,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  onPressed: () => context.push(RoutePaths.edit),
                ),
              ),
            const SizedBox(height: OpennoteTokens.s1),
            IntrinsicHeight(
              child: NavigationRail(
                destinations: destinations,
                selectedIndex: selectedIndex,
                backgroundColor: Colors.transparent,
                extended: expanded,
                minWidth: 72,
                minExtendedWidth: 236,
                useIndicator: true,
                indicatorColor: colorScheme.primary.withValues(
                  alpha: isDark ? 0.24 : 0.14,
                ),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OpennoteTokens.radiusSm),
                ),
                selectedIconTheme: IconThemeData(
                  color: colorScheme.primary,
                  size: 21,
                ),
                unselectedIconTheme: IconThemeData(
                  color: colorScheme.onSurfaceVariant,
                  size: 21,
                ),
                selectedLabelTextStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
                unselectedLabelTextStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
                onDestinationSelected: onDestinationSelected,
              ),
            ),
            if (expanded) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OpennoteTokens.s3,
                  vertical: OpennoteTokens.s1,
                ),
                child: Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.32),
                ),
              ),
              const Expanded(child: FileTree()),
            ] else
              const Spacer(),
            Padding(
              padding: EdgeInsets.all(expanded ? OpennoteTokens.s3 : 8),
              child: expanded
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(
                          OpennoteTokens.radiusSm,
                        ),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox.square(
                            dimension: 32,
                            child: SyncingButton(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cloud Sync',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: SizedBox.square(
                        dimension: 36,
                        child: SyncingButton(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

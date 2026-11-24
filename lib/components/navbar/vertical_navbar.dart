/// 🤖 Generated wholely or partially with Google Antigravity
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
    final expanded = manualExpanded.value ?? (screenWidth >= 900);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = switch (theme.platform) {
      .linux => Colors.transparent,
      _ => colorScheme.surfaceContainerLow,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      width: expanded ? 260 : 72,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: BorderDirectional(
          end: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
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
            // Studio Header card
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
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              OpennoteTokens.radiusSm,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Icon(
                              Icons.edit_note_rounded,
                              size: 22,
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
                                'Opennote Studio',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Workspace',
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
            // Quick Search / Command Trigger Bar
            if (expanded)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OpennoteTokens.s3,
                  vertical: 4,
                ),
                child: Material(
                  color: colorScheme.surfaceContainerHigh.withValues(
                    alpha: 0.7,
                  ),
                  borderRadius: BorderRadius.circular(OpennoteTokens.radiusSm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      OpennoteTokens.radiusSm,
                    ),
                    onTap: () => SearchDialog.show(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
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
            // Primary + New Note Button
            if (expanded)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OpennoteTokens.s3,
                  vertical: 4,
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
                child: IconButton(
                  tooltip: t.home.create.newNote,
                  icon: const Icon(Icons.add_rounded, size: 22),
                  onPressed: () => context.push(RoutePaths.edit),
                ),
              ),
            const SizedBox(height: OpennoteTokens.s1),
            // Navigation items
            IntrinsicHeight(
              child: NavigationRail(
                destinations: destinations,
                selectedIndex: selectedIndex,
                backgroundColor: Colors.transparent,
                extended: expanded,
                minExtendedWidth: 240,
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
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              const Expanded(child: FileTree()),
            ] else
              const Spacer(),
            // Sync status footer
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

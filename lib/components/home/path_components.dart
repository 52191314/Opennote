/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/data/file_manager/file_manager.dart';

class PathComponents extends StatelessWidget {
  PathComponents(
    String? path, {
    super.key,
    required this.onPathComponentTap,
    this.onItemMoved,
  }) : currentPath = path,
       components = _splitPath(path);

  final String? currentPath;
  final List<String> components;
  final void Function(String? path) onPathComponentTap;
  final void Function(String itemPath, String targetFolderPath)? onItemMoved;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    Widget buildBreadcrumbTarget({
      required String targetPath,
      required String label,
      required VoidCallback onTap,
    }) {
      return DragTarget<String>(
        onWillAcceptWithDetails: (details) {
          final sourcePath = details.data;
          if (sourcePath == targetPath) return false;
          if (targetPath.startsWith('$sourcePath/')) return false;
          final sourceParent = sourcePath.substring(
            0,
            sourcePath.lastIndexOf('/'),
          );
          final normalizedParent = sourceParent.isEmpty ? '/' : sourceParent;
          if (targetPath == normalizedParent) return false;
          return true;
        },
        onAcceptWithDetails: (details) async {
          final sourcePath = details.data;
          final itemName = sourcePath.substring(
            sourcePath.lastIndexOf('/') + 1,
          );
          final targetName = targetPath == '/'
              ? 'root'
              : targetPath.substring(targetPath.lastIndexOf('/') + 1);

          await FileManager.moveItem(sourcePath, targetPath);
          onItemMoved?.call(sourcePath, targetPath);

          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Moved $itemName to $targetName'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovered = candidateData.isNotEmpty;
          return ElevatedButton(
            style: isHovered
                ? ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    side: BorderSide(color: colorScheme.primary, width: 1.5),
                  )
                : null,
            onPressed: onTap,
            child: Text(label),
          );
        },
      );
    }

    return ElevatedButtonTheme(
      data: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.surfaceContainerLow,
          foregroundColor: colorScheme.onSurface,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(28, 30),
          padding: const .symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: const .all(.circular(20)),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      child: Padding(
        padding: const .fromLTRB(16, 10, 16, 4),
        child: Wrap(
          spacing: 4,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (components.isNotEmpty)
              buildBreadcrumbTarget(
                targetPath: '/',
                label: '/',
                onTap: () => onPathComponentTap(null),
              ),
            for (var i = 0; i < components.length; i++) ...[
              Icon(
                Icons.chevron_right,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              if (i < components.length - 1)
                buildBreadcrumbTarget(
                  targetPath: '/${components.sublist(0, i + 1).join('/')}',
                  label: components[i],
                  onTap: () {
                    final path = '/${components.sublist(0, i + 1).join('/')}';
                    onPathComponentTap(path);
                  },
                )
              else
                ElevatedButton(
                  onPressed: () {
                    final path = '/${components.sublist(0, i + 1).join('/')}';
                    onPathComponentTap(path);
                  },
                  child: Text(components[i]),
                ),
            ],
          ],
        ),
      ),
    );
  }

  static List<String> _splitPath(String? path) {
    return (path ?? '')
        .split(RegExp(r'[\\/]'))
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }
}

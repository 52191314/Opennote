/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';

class PathComponents extends StatelessWidget {
  PathComponents(String? path, {super.key, required this.onPathComponentTap})
    : components = _splitPath(path);

  final List<String> components;
  final void Function(String? path) onPathComponentTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
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
              ElevatedButton(
                onPressed: () {
                  onPathComponentTap(null);
                },
                child: const Text('/'),
              ),
            for (var i = 0; i < components.length; i++) ...[
              Icon(
                Icons.chevron_right,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
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

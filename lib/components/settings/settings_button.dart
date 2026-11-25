/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';

/// Action row used inside settings cards for navigation and quick actions.
class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onPressed,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: ListTile(
        contentPadding: const .symmetric(vertical: 4, horizontal: 16),
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: Icon(icon, key: ValueKey(icon)),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(fontSize: 13))
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

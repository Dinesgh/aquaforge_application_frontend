import 'package:flutter/material.dart';

class AquaForgeHeader extends StatelessWidget implements PreferredSizeWidget {
  const AquaForgeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.dashboard_customize, color: theme.primaryColor),
        const SizedBox(width: 8),
        const Text('AquaForge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

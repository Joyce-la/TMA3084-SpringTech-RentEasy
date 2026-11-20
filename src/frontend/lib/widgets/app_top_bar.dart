import 'package:material_ui/material_ui.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.onAssistantTap,
    this.onProfileTap,
  });

  final String title;
  final VoidCallback? onAssistantTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            _HeaderIcon(
              icon: Icons.smart_toy_outlined,
              tooltip: 'AI assistant',
              onTap: onAssistantTap,
            ),
            const SizedBox(width: 8),
            _HeaderIcon(
              icon: Icons.person,
              tooltip: 'Profile',
              onTap: onProfileTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 17,
          backgroundColor: Colors.grey.shade300,
          child: Icon(icon, size: 19, color: Colors.black),
        ),
      ),
    );
  }
}

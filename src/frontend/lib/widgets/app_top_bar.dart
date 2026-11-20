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
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ),
        _HeaderAction(
          label: 'AI assistant',
          onTap: onAssistantTap,
          child: const Text('AI', style: TextStyle(fontSize: 14)),
        ),
        const SizedBox(width: 8),
        _HeaderAction(
          label: 'Profile',
          onTap: onProfileTap,
          child: const Icon(Icons.person, size: 21),
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: Colors.grey.shade200,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

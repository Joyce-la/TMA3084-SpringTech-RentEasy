import 'package:material_ui/material_ui.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.isOwner,
    this.onRoleChanged,
    this.onAssistantTap,
    this.onProfileTap,
    this.activeColor = const Color(0xFF071957),
  });

  final String title;
  final bool? isOwner; // null = 不显示 Owner/Staff 切换
  final ValueChanged<bool>? onRoleChanged;
  final VoidCallback? onAssistantTap;
  final VoidCallback? onProfileTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final showToggle = isOwner != null && onRoleChanged != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            if (showToggle) ...[
              _RoleToggle(
                isOwner: isOwner!,
                onChanged: onRoleChanged!,
                activeColor: activeColor,
              ),
              const SizedBox(width: 8),
            ],
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

class _RoleToggle extends StatelessWidget {
  const _RoleToggle({
    required this.isOwner,
    required this.onChanged,
    required this.activeColor,
  });

  final bool isOwner;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  Widget _option(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _option('Owner', isOwner, () => onChanged(true)),
          _option('Staff', !isOwner, () => onChanged(false)),
        ],
      ),
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

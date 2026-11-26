import 'package:material_ui/material_ui.dart';

class MaintenanceStatusBadge extends StatelessWidget {
  const MaintenanceStatusBadge({super.key, required this.status});

  final String status;

  Color get _color => switch (status) {
    'Overdue' => const Color(0xFFC94F4F),
    'Scheduled' => const Color(0xFFD88935),
    'In Progress' => const Color(0xFF4B83B9),
    'Done' => const Color(0xFF419766),
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon => switch (status) {
    'Overdue' => Icons.warning_amber_rounded,
    'Scheduled' => Icons.event_available_outlined,
    'In Progress' => Icons.build_circle_outlined,
    'Done' => Icons.check_circle_outline,
    _ => Icons.help_outline,
  };
}

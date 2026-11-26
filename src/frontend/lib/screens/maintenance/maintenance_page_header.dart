import 'package:material_ui/material_ui.dart';
import 'package:src/screens/ai_assistant/ai_assistant_screen.dart';
import 'package:src/widgets/app_top_bar.dart';

/// Shared horizontal spacing and back-navigation layout for Maintenance pages.
class MaintenancePageHeader extends StatelessWidget {
  const MaintenancePageHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: AppTopBar(
              title: title,
              onAssistantTap: () => AiAssistantScreen.open(context),
            ),
          ),
        ],
      ),
    );
  }
}

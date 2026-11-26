import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:src/providers/assistant_provider.dart';
import 'package:src/providers/fleet_provider.dart';
import 'package:src/providers/maintenance_provider.dart';
import 'package:src/screens/ai_assistant/ai_assistant_screen.dart';
import 'package:src/screens/reports/report_screen.dart';
import 'package:src/screens/reports/reports_screen.dart';

Widget _wrapReports(Widget child) => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AssistantProvider()),
    ChangeNotifierProvider(create: (_) => FleetProvider()),
    ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
  ],
  child: MaterialApp(home: child),
);

void main() {
  testWidgets('Reports screen switches tabs and opens its AI assistant', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapReports(const ReportsScreen()));

    expect(find.text('Maintenance'), findsWidgets);
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Reports'), findsWidgets);
    expect(find.byType(ReportScreen), findsOneWidget);

    await tester.tap(find.byTooltip('AI assistant'));
    await tester.pumpAndSettle();
    expect(find.byType(AiAssistantScreen), findsOneWidget);
    expect(find.text('AI Assistant'), findsOneWidget);
  });
}

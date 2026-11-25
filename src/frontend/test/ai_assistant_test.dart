import 'package:flutter_test/flutter_test.dart';
import 'package:src/main.dart';
import 'package:src/mock_data/vehicles.dart';
import 'package:src/providers/assistant_provider.dart';
import 'package:src/screens/ai_assistant/ai_assistant_screen.dart';

void main() {
  test('Assistant lists available vehicles', () async {
    final provider = AssistantProvider(replyDelay: Duration.zero);

    await provider.ask('Available vehicles today', mockVehicles);

    expect(provider.messages.length, 3);
    expect(provider.messages.last.fromUser, isFalse);
    expect(
      provider.messages.last.text,
      contains(mockVehicles.first.plateNumber),
    );
  });

  test('Assistant shows maintenance history for a plate', () async {
    final provider = AssistantProvider(replyDelay: Duration.zero);

    await provider.ask('QAA 1234 history', mockVehicles);

    expect(provider.messages.last.text, contains('Maintenance history'));
  });

  test('Assistant ignores empty questions and answers unknown ones', () async {
    final provider = AssistantProvider(replyDelay: Duration.zero);

    await provider.ask('   ', mockVehicles);
    expect(provider.messages.length, 1);

    await provider.ask('What is the weather?', mockVehicles);
    expect(provider.messages.last.text, contains('Sorry'));
  });

  testWidgets('AI icon opens the assistant and a chip gets a reply', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Fleet'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('AI assistant'));
    await tester.pumpAndSettle();
    expect(find.byType(AiAssistantScreen), findsOneWidget);

    await tester.tap(find.text('Available vehicles today'));
    await tester.pump();
    expect(find.text('Thinking...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.textContaining('available today'), findsOneWidget);
  });

  testWidgets('New chat icon resets the conversation', (tester) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Fleet'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('AI assistant'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Overdue rentals'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.textContaining('Overdue rentals:'), findsOneWidget);

    await tester.tap(find.byTooltip('New chat'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Overdue rentals:'), findsNothing);
  });
}

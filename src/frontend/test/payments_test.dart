import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/main.dart';
import 'package:src/screens/home_screen.dart';
import 'package:src/screens/payments/deposit_screen.dart';
import 'package:src/screens/payments/invoice_screen.dart';
import 'package:src/widgets/app_top_bar.dart';
import 'package:src/widgets/deposit_card.dart';
import 'package:src/widgets/invoice_card.dart';

void main() {
  testWidgets('AppTopBar displays its title and calls header actions', (
    tester,
  ) async {
    var assistantTapped = false;
    var profileTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTopBar(
            title: 'Payments',
            onAssistantTap: () => assistantTapped = true,
            onProfileTap: () => profileTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Payments'), findsOneWidget);
    await tester.tap(find.byTooltip('AI assistant'));
    await tester.tap(find.byIcon(Icons.person));
    expect(assistantTapped, isTrue);
    expect(profileTapped, isTrue);
  });

  testWidgets('InvoiceCard shows payment status, balance and progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InvoiceCard(
            invoiceNumber: 'INV-1',
            customerName: 'Kevin Lim',
            plateNumber: 'QA 7345 D',
            date: '9 Nov 2026',
            paidAmount: 300,
            totalAmount: 500,
            status: InvoicePaymentStatus.partiallyPaid,
          ),
        ),
      ),
    );

    expect(find.text('Partially paid'), findsOneWidget);
    expect(find.text('Balance RM 200.00'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0.6,
    );
  });

  testWidgets('DepositCard shows status and invokes its primary action', (
    tester,
  ) async {
    var actionTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DepositCard(
            invoiceNumber: 'INV-2',
            customerName: 'Aisha Rahman',
            plateNumber: 'QK 8821 B',
            status: DepositStatus.eligibleToRefund,
            collectedAmount: 100,
            statusDetail: 'Check ended 7 Nov',
            primaryActionLabel: 'Refund',
            onPrimaryAction: () => actionTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('ELIGIBLE TO REFUND'), findsOneWidget);
    await tester.tap(find.text('Refund'));
    expect(actionTapped, isTrue);
  });

  testWidgets('Invoice screen searches and filters invoices', (tester) async {
    await tester.pumpWidget(const RentEasyApp());

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('The Home screen is coming soon.'), findsOneWidget);
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 0);
    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();

    expect(find.byType(InvoiceScreen), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('INV-20261110-001'), findsOneWidget);

    await tester.tap(find.text('Unpaid 1'));
    await tester.pumpAndSettle();
    expect(find.text('Grace Ling'), findsOneWidget);
    expect(find.text('Kevin Lim'), findsNothing);

    await tester.enterText(find.byKey(const Key('invoice-search')), 'INV-2026');
    await tester.pumpAndSettle();
    expect(find.text('Grace Ling'), findsOneWidget);
  });

  testWidgets('Unimplemented navigation destinations show coming soon text', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());

    for (final destination in {
      'Fleet': 'The Fleet screen is coming soon.',
      'Rentals': 'The Rentals screen is coming soon.',
      'Reports': 'The Reports screen is coming soon.',
    }.entries) {
      await tester.tap(find.text(destination.key));
      await tester.pumpAndSettle();
      expect(find.text(destination.value), findsOneWidget);
    }
  });

  testWidgets('Deposit screen switches tabs and filters deposits', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());

    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deposits'));
    await tester.pumpAndSettle();
    expect(find.byType(DepositScreen), findsOneWidget);
    expect(find.text('Aisha Rahman'), findsOneWidget);
    expect(find.text('Mei Ling Tan'), findsOneWidget);

    await tester.tap(find.text('Checking 1'));
    await tester.pumpAndSettle();
    expect(find.text('Mei Ling Tan'), findsOneWidget);
    expect(find.text('Aisha Rahman'), findsNothing);

    await tester.tap(find.text('Invoice'));
    await tester.pumpAndSettle();
    expect(find.byType(InvoiceScreen), findsOneWidget);
  });
}

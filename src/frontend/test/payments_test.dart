import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:src/main.dart';
import 'package:src/screens/home_screen.dart';
import 'package:src/screens/fleet/fleet_screen.dart';
import 'package:src/screens/payments/deposit_screen.dart';
import 'package:src/screens/payments/invoice_detail_screen.dart';
import 'package:src/screens/payments/invoice_pdf_preview_screen.dart';
import 'package:src/screens/payments/invoice_screen.dart';
import 'package:src/screens/payments/add_payment_screen.dart';
import 'package:src/screens/payments/refund_deposit_screen.dart';
import 'package:src/widgets/app_top_bar.dart';
import 'package:src/widgets/deposit_card.dart';
import 'package:src/widgets/invoice_card.dart';
import 'package:src/providers/invoice_provider.dart';
import 'package:src/providers/deposit_provider.dart';
import 'package:src/mock_data/deposits.dart';

void main() {
  test('InvoiceProvider exposes an unmodifiable invoice list', () {
    final provider = InvoiceProvider();

    expect(
      () => provider.invoices.add(provider.invoices.first),
      throwsUnsupportedError,
    );
  });

  test('Deposit mock conversion produces complete UI data', () {
    expect(mockDeposits, isNotEmpty);
    for (final deposit in mockDeposits) {
      expect(deposit.customerName, isNotEmpty);
      expect(deposit.plateNumber, isNotEmpty);
      expect(deposit.invoiceNumber, isNotEmpty);
      expect(deposit.collectedAmount >= 0, isTrue);
    }

    expect(mockDeposits.map((deposit) => deposit.invoiceNumber), [
      'INV-20261101-002',
      'INV-20261105-001',
      'INV-20261110-001',
      'INV-20261109-003',
      'INV-20261028-001',
    ]);
    expect(mockDeposits.map((deposit) => deposit.status), [
      DepositStatus.eligibleToRefund,
      DepositStatus.checking,
      DepositStatus.pending,
      DepositStatus.holding,
      DepositStatus.partiallyRefunded,
    ]);
    expect(mockDeposits.last.collectedAmount, 100);
    expect(mockDeposits.last.refundedAmount, 60);
    expect(mockDeposits.map((deposit) => deposit.statusDetail), [
      'Check ended 7 Nov',
      'Day 1 of 3 · opens 10 Nov',
      'Awaiting payment',
      'Car not returned · due 18 Nov',
      'Deducted RM 40.00 · damage',
    ]);
  });

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
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();

    expect(find.byType(InvoiceScreen), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('INV-20261110-001'), findsOneWidget);

    await tester.tap(find.byKey(const Key('invoice-filter-unpaid')));
    await tester.pumpAndSettle();
    expect(find.text('Grace Ling'), findsOneWidget);
    expect(find.text('Kevin Lim'), findsNothing);

    await tester.enterText(find.byKey(const Key('invoice-search')), 'INV-2026');
    await tester.pumpAndSettle();
    expect(find.text('Grace Ling'), findsOneWidget);
  });

  testWidgets('Invoice cards open their matching detail screens', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('INV-20261110-001'));
    await tester.pumpAndSettle();
    expect(find.byType(InvoiceDetailScreen), findsOneWidget);
    expect(find.text('Grace Ling'), findsOneWidget);
    expect(find.text('Sedan (Toyota Vios)'), findsOneWidget);
    expect(find.text('RM 890.00'), findsNWidgets(2));
    expect(find.text('No payments yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Preview invoice PDF'));
    await tester.pumpAndSettle();
    expect(find.byType(InvoicePdfPreviewScreen), findsOneWidget);
    expect(find.text('INV-20261110-001.pdf'), findsOneWidget);
    expect(find.text('Grace Ling'), findsOneWidget);
    expect(find.text('RM 890.00'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);

    await tester.tap(find.byTooltip('Back').last);
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('INV-20261109-003'));
    await tester.pumpAndSettle();
    expect(find.text('Kevin Lim'), findsOneWidget);
    expect(find.text('Partially paid'), findsOneWidget);
    expect(find.text('Rental charges'), findsOneWidget);
    expect(find.text('RM 200.00'), findsNWidgets(2));
    expect(find.text('Balance'), findsOneWidget);
    expect(find.byTooltip('AI assistant'), findsOneWidget);
    expect(find.byTooltip('Profile'), findsOneWidget);
  });

  testWidgets('Staff can record a cash payment and reduce the balance', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('INV-20261109-003'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add payment'));
    await tester.pumpAndSettle();
    expect(find.byType(AddPaymentScreen), findsOneWidget);

    await tester.enterText(find.byKey(const Key('payment-total')), '100.00');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('payment-rental')), '100.00');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-payment')));
    await tester.pumpAndSettle();

    expect(find.byType(InvoiceDetailScreen), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('RM 100.00'), findsWidgets);
    expect(find.text('Partially paid'), findsOneWidget);
  });

  testWidgets('Amount to collect groups rental charge components', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('INV-20261109-003'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add payment'));
    await tester.pumpAndSettle();

    expect(find.text('Rental charges'), findsOneWidget);
    expect(find.text('RM 400.00'), findsWidgets);
    expect(find.text('Invoice'), findsWidgets);
    expect(find.text('RM 500.00'), findsWidgets);
  });

  testWidgets('Fully paid deposit allocation is grey and disabled', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('INV-20261109-003'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add payment'));
    await tester.pumpAndSettle();

    final depositField = tester.widget<TextField>(
      find.byKey(const Key('payment-deposit')),
    );
    expect(depositField.readOnly, isTrue);
  });

  testWidgets('Saving deposit updates invoice and deposit statuses', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('INV-20261110-001'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add payment'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('payment-total')), '100.00');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('payment-rental')), '0.00');
    await tester.enterText(find.byKey(const Key('payment-deposit')), '100.00');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-payment')));
    await tester.pumpAndSettle();

    final invoiceProvider = Provider.of<InvoiceProvider>(
      tester.element(find.byType(InvoiceDetailScreen)),
      listen: false,
    );
    final updatedInvoice = invoiceProvider.invoices.firstWhere(
      (invoice) => invoice.invoiceNumber == 'INV-20261110-001',
    );
    expect(updatedInvoice.status, InvoicePaymentStatus.partiallyPaid);
    expect(updatedInvoice.paidAmount, 100);
    final depositProvider = Provider.of<DepositProvider>(
      tester.element(find.byType(InvoiceDetailScreen)),
      listen: false,
    );
    final updatedDeposit = depositProvider.deposits.firstWhere(
      (deposit) => deposit.invoiceNumber == 'INV-20261110-001',
    );
    expect(updatedDeposit.status, DepositStatus.holding);
  });

  testWidgets('Refunded deposits have no card action', (tester) async {
    for (final status in [
      DepositStatus.partiallyRefunded,
      DepositStatus.refunded,
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DepositCard(
              invoiceNumber: 'INV-TERMINAL',
              customerName: 'Customer',
              plateNumber: 'ABC 123',
              status: status,
              collectedAmount: 100,
              statusDetail: 'Refund saved',
              onPrimaryAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Refund'), findsNothing);
      expect(find.text('Record Incident'), findsNothing);
    }
  });

  testWidgets('Invoice detail reads deposit status from DepositProvider', (
    tester,
  ) async {
    final invoiceProvider = InvoiceProvider();
    final depositProvider = DepositProvider();
    addTearDown(invoiceProvider.dispose);
    addTearDown(depositProvider.dispose);

    final invoice = invoiceProvider.invoices.firstWhere(
      (item) => item.invoiceNumber == 'INV-20261105-001',
    );
    final checkingDeposit = depositProvider.deposits.firstWhere(
      (item) => item.invoiceNumber == invoice.invoiceNumber,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: invoiceProvider),
          ChangeNotifierProvider.value(value: depositProvider),
        ],
        child: MaterialApp(home: InvoiceDetailScreen(invoice: invoice)),
      ),
    );
    expect(find.text('3-days CHECKING'), findsOneWidget);

    depositProvider.updateDeposit(
      checkingDeposit.copyWith(
        status: DepositStatus.partiallyRefunded,
        statusDetail: 'Deducted RM 30.00',
      ),
    );
    await tester.pump();

    expect(find.text('PARTIALLY REFUNDED'), findsOneWidget);
    expect(find.text('Deducted RM 30.00'), findsOneWidget);
  });

  testWidgets('Payment above the balance is rejected and not saved', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('INV-20261109-003'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add payment'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('payment-total')), '300.00');
    await tester.pumpAndSettle();

    expect(find.text('Amount exceeds the balance'), findsOneWidget);
    final saveButton = tester.widget<FilledButton>(
      find.byKey(const Key('save-payment')),
    );
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('Fleet tab shows FleetScreen', (tester) async {
    await tester.pumpWidget(const RentEasyApp());

    await tester.tap(find.text('Fleet'));
    await tester.pumpAndSettle();

    expect(find.byType(FleetScreen), findsOneWidget);
  });

  testWidgets('Unimplemented navigation destinations show coming soon text', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());

    for (final destination in {
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

    await tester.tap(find.byKey(const Key('deposit-filter-checking')));
    await tester.pumpAndSettle();
    expect(find.text('Mei Ling Tan'), findsOneWidget);
    expect(find.text('Aisha Rahman'), findsNothing);

    await tester.tap(find.text('Invoice'));
    await tester.pumpAndSettle();
    expect(find.byType(InvoiceScreen), findsOneWidget);
  });

  testWidgets('Eligible deposit opens refund screen and supports full refund', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deposits'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Refund'));
    await tester.pumpAndSettle();
    expect(find.byType(RefundDepositScreen), findsOneWidget);
    expect(find.text('Aisha Rahman'), findsOneWidget);
    expect(find.text('ELIGIBLE TO REFUND'), findsOneWidget);

    await tester.tap(find.byKey(const Key('refund-partial')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('refund-amount')))
          .controller!
          .text,
      isEmpty,
    );
    await tester.tap(find.byKey(const Key('refund-all')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('refund-amount')))
          .controller!
          .text,
      '100.00',
    );

    await tester.tap(find.byKey(const Key('confirm-refund')));
    await tester.pumpAndSettle();
    expect(find.byType(DepositScreen), findsOneWidget);

    final provider = Provider.of<DepositProvider>(
      tester.element(find.byType(DepositScreen)),
      listen: false,
    );
    final deposit = provider.deposits.firstWhere(
      (item) => item.invoiceNumber == 'INV-20261101-002',
    );
    expect(deposit.status, DepositStatus.refunded);
  });

  testWidgets(
    'Checking incident requires partial description and updates status',
    (tester) async {
      await tester.pumpWidget(const RentEasyApp());
      await tester.tap(find.text('Payment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deposits'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Record Incident'));
      await tester.pumpAndSettle();
      expect(find.byType(RefundDepositScreen), findsOneWidget);
      expect(find.text('Refund all'), findsOneWidget);
      expect(find.text('Partial refund'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('refund-amount')))
            .controller!
            .text,
        isEmpty,
      );

      final refundAll = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text('Refund all'),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(refundAll.onPressed, isNull);

      await tester.enterText(find.byKey(const Key('refund-amount')), '70.00');
      await tester.enterText(
        find.byKey(const Key('refund-description')),
        'Vehicle damage: cracked side mirror',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-refund')));
      await tester.pumpAndSettle();

      final provider = Provider.of<DepositProvider>(
        tester.element(find.byType(DepositScreen)),
        listen: false,
      );
      final deposit = provider.deposits.firstWhere(
        (item) => item.invoiceNumber == 'INV-20261105-001',
      );
      expect(deposit.status, DepositStatus.partiallyRefunded);
      expect(deposit.refundedAmount, 70);
    },
  );
}

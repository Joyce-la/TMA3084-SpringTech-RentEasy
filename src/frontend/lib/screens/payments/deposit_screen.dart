import 'package:material_ui/material_ui.dart';

import '../../widgets/app_top_bar.dart';
import '../../widgets/deposit_card.dart';
import 'invoice_screen.dart';
import 'payments_screen_components.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key, this.onInvoiceSelected});

  final VoidCallback? onInvoiceSelected;

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  static const _deposits = [
    DepositCardData(
      invoiceNumber: 'INV-20261101-002',
      customerName: 'Aisha Rahman',
      plateNumber: 'QK 8821 B',
      status: DepositStatus.eligibleToRefund,
      collectedAmount: 100,
      statusDetail: 'Check ended 7 Nov',
      actionLabel: 'Refund',
    ),
    DepositCardData(
      invoiceNumber: 'INV-20261105-001',
      customerName: 'Mei Ling Tan',
      plateNumber: 'QB 4410 M',
      status: DepositStatus.checking,
      collectedAmount: 100,
      statusDetail: 'Day 1 of 3 · opens 15 Nov',
      actionLabel: 'Record Incident',
    ),
    DepositCardData(
      invoiceNumber: 'INV-20261110-001',
      customerName: 'Grace Ling',
      plateNumber: 'QAA 1234',
      status: DepositStatus.pending,
      collectedAmount: 0,
      statusDetail: 'Awaiting payment',
    ),
    DepositCardData(
      invoiceNumber: 'INV-20261030-002',
      customerName: 'Kevin Lim',
      plateNumber: 'QA 7345 D',
      status: DepositStatus.holding,
      collectedAmount: 100,
      statusDetail: 'Car not returned · due 15 Nov',
    ),
    DepositCardData(
      invoiceNumber: 'INV-20261028-001',
      customerName: 'Farid Ismail',
      plateNumber: 'QA 9902 F',
      status: DepositStatus.partiallyRefunded,
      collectedAmount: 100,
      statusDetail: 'Deducted RM 40.00 · damage',
      refundedAmount: 60,
    ),
  ];

  DepositStatus? _selectedStatus;

  List<DepositCardData> get _visibleDeposits {
    if (_selectedStatus == null) return _deposits;
    return _deposits.where((deposit) {
      if (_selectedStatus == DepositStatus.pending) {
        return deposit.status == DepositStatus.pending ||
            deposit.status == DepositStatus.holding ||
            deposit.status == DepositStatus.partiallyRefunded;
      }
      return deposit.status == _selectedStatus;
    }).toList();
  }

  int _countFor(DepositStatus? status) {
    if (status == null) return _deposits.length;
    if (status == DepositStatus.pending) {
      return _deposits.where((deposit) {
        return deposit.status == DepositStatus.pending ||
            deposit.status == DepositStatus.holding ||
            deposit.status == DepositStatus.partiallyRefunded;
      }).length;
    }
    return _deposits.where((deposit) => deposit.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: AppTopBar(
                title: 'Payments',
                onAssistantTap: () => _showMessage('AI assistant'),
                onProfileTap: () => _showMessage('Profile'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: buildPaymentsSectionTabs(
                depositsSelected: true,
                onInvoiceTap: widget.onInvoiceSelected ?? _openInvoiceScreen,
                onDepositsTap: () {},
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('All', null),
                  _filterChip(
                    'Eligible to Refund',
                    DepositStatus.eligibleToRefund,
                  ),
                  _filterChip('Checking', DepositStatus.checking),
                  _filterChip('Other', DepositStatus.pending),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                itemCount: _visibleDeposits.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final deposit = _visibleDeposits[index];
                  return DepositCard(
                    key: ValueKey(deposit.invoiceNumber),
                    invoiceNumber: deposit.invoiceNumber,
                    customerName: deposit.customerName,
                    plateNumber: deposit.plateNumber,
                    status: deposit.status,
                    collectedAmount: deposit.collectedAmount,
                    statusDetail: deposit.statusDetail,
                    refundedAmount: deposit.refundedAmount,
                    primaryActionLabel: deposit.actionLabel,
                    onPrimaryAction: deposit.actionLabel == null
                        ? null
                        : () => _showMessage(deposit.actionLabel!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, DepositStatus? status) {
    final selected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$label ${_countFor(status)}'),
        selected: selected,
        onSelected: (_) => setState(() => _selectedStatus = status),
        selectedColor: const Color(0xFF071957),
        backgroundColor: const Color(0xFFF1F1F5),
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontSize: 13,
        ),
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message action is not available yet.')),
    );
  }

  void _openInvoiceScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const InvoiceScreen()),
    );
  }
}

class DepositCardData {
  const DepositCardData({
    required this.invoiceNumber,
    required this.customerName,
    required this.plateNumber,
    required this.status,
    required this.collectedAmount,
    required this.statusDetail,
    this.refundedAmount,
    this.actionLabel,
  });

  final String invoiceNumber;
  final String customerName;
  final String plateNumber;
  final DepositStatus status;
  final double collectedAmount;
  final String statusDetail;
  final double? refundedAmount;
  final String? actionLabel;
}

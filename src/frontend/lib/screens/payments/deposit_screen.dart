import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_top_bar.dart';
import '../../widgets/deposit_card.dart';
import '../../providers/deposit_provider.dart';
import 'invoice_screen.dart';
import 'payments_screen_components.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key, this.onInvoiceSelected});

  final VoidCallback? onInvoiceSelected;

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  @override
  Widget build(BuildContext context) {
    final depositProvider = context.watch<DepositProvider>();
    final visibleDeposits = depositProvider.visibleDeposits;
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
              height: 48,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip(depositProvider, 'All', null),
                  _filterChip(
                    depositProvider,
                    'Eligible to Refund',
                    DepositStatus.eligibleToRefund,
                  ),
                  _filterChip(depositProvider, 'Checking', DepositStatus.checking),
                  _filterChip(depositProvider, 'Other', DepositStatus.pending),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                itemCount: visibleDeposits.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final deposit = visibleDeposits[index];
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

  Widget _filterChip(
    DepositProvider depositProvider,
    String label,
    DepositStatus? status,
  ) {
    final selected = depositProvider.selectedStatus == status;
    final count = depositProvider.countFor(status);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: selected,
        label: '$label $count',
        child: GestureDetector(
          key: Key('deposit-filter-${status?.name ?? 'all'}'),
          onTap: () => depositProvider.setSelectedStatus(status),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF071957)
                  : const Color(0xFFEDEDF2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white24 : const Color(0xFFD0D2DC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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


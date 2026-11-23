import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../providers/invoice_provider.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/invoice_card.dart';
import 'deposit_screen.dart';
import 'invoice_detail_screen.dart';
import 'payments_screen_components.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key, this.onDepositsSelected});

  final VoidCallback? onDepositsSelected;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  @override
  Widget build(BuildContext context) {
    final invoiceProvider = context.watch<InvoiceProvider>();
    final visibleInvoices = invoiceProvider.visibleInvoices;
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
                depositsSelected: false,
                onInvoiceTap: () {},
                onDepositsTap: widget.onDepositsSelected ?? _openDepositScreen,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: SizedBox(
                height: 48,
                child: TextField(
                  key: const Key('invoice-search'),
                  decoration: InputDecoration(
                    hintText: 'Search customer, plate or invoice no.',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF1F1F5),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: invoiceProvider.setSearchQuery,
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip(invoiceProvider, 'All', null),
                  _filterChip(
                    invoiceProvider,
                    'Unpaid',
                    InvoicePaymentStatus.unpaid,
                  ),
                  _filterChip(
                    invoiceProvider,
                    'Partial',
                    InvoicePaymentStatus.partiallyPaid,
                  ),
                  _filterChip(
                    invoiceProvider,
                    'Paid',
                    InvoicePaymentStatus.paid,
                  ),
                ],
              ),
            ),
            Expanded(
              child: visibleInvoices.isEmpty
                  ? const Center(child: Text('No invoices found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      itemCount: visibleInvoices.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final invoice = visibleInvoices[index];
                        return InvoiceCard(
                          key: ValueKey(invoice.invoiceNumber),
                          invoiceNumber: invoice.invoiceNumber,
                          customerName: invoice.customerName,
                          plateNumber: invoice.plateNumber,
                          date: invoice.date,
                          paidAmount: invoice.paidAmount,
                          totalAmount: invoice.totalAmount,
                          status: invoice.status,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  InvoiceDetailScreen(invoice: invoice),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMessage('Create invoice'),
        backgroundColor: const Color(0xFF071957),
        foregroundColor: Colors.white,
        tooltip: 'Create invoice',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterChip(
    InvoiceProvider invoiceProvider,
    String label,
    InvoicePaymentStatus? status,
  ) {
    final selected = invoiceProvider.selectedStatus == status;
    final count = invoiceProvider.countFor(status);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: selected,
        label: '$label $count',
        child: GestureDetector(
          key: Key('invoice-filter-${status?.name ?? 'all'}'),
          onTap: () => invoiceProvider.setSelectedStatus(status),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$message is not available yet.')));
  }

  void _openDepositScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DepositScreen()),
    );
  }
}

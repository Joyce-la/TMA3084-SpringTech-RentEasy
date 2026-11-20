import 'package:material_ui/material_ui.dart';

import '../../mock_data/invoices.dart';
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
  String _searchQuery = '';
  InvoicePaymentStatus? _selectedStatus;

  List<InvoiceData> get _visibleInvoices {
    final query = _searchQuery.trim().toLowerCase();
    return mockInvoices.where((invoice) {
      final matchesStatus =
          _selectedStatus == null || invoice.status == _selectedStatus;
      final matchesSearch =
          query.isEmpty ||
          invoice.customerName.toLowerCase().contains(query) ||
          invoice.plateNumber.toLowerCase().contains(query) ||
          invoice.invoiceNumber.toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  int _countFor(InvoicePaymentStatus? status) {
    if (status == null) return mockInvoices.length;
    return mockInvoices.where((invoice) => invoice.status == status).length;
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
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('All', null),
                  _filterChip('Unpaid', InvoicePaymentStatus.unpaid),
                  _filterChip('Partial', InvoicePaymentStatus.partiallyPaid),
                  _filterChip('Paid', InvoicePaymentStatus.paid),
                ],
              ),
            ),
            Expanded(
              child: _visibleInvoices.isEmpty
                  ? const Center(child: Text('No invoices found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      itemCount: _visibleInvoices.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final invoice = _visibleInvoices[index];
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

  Widget _filterChip(String label, InvoicePaymentStatus? status) {
    final selected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: selected,
        label: '$label ${_countFor(status)}',
        child: GestureDetector(
          key: Key('invoice-filter-${status?.name ?? 'all'}'),
          onTap: () => setState(() => _selectedStatus = status),
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
                    _countFor(status).toString(),
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

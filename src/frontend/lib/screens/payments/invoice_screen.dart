import 'package:flutter/material.dart';

import '../../widgets/app_top_bar.dart';
import '../../widgets/invoice_card.dart';
import 'deposit_screen.dart';
import 'payments_screen_components.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key, this.onDepositsSelected});

  final VoidCallback? onDepositsSelected;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  static const _invoices = [
    InvoiceCardData(
      invoiceNumber: 'INV-20261110-001',
      customerName: 'Grace Ling',
      plateNumber: 'QAA 1234',
      date: '10 Nov 2026',
      paidAmount: 0,
      totalAmount: 890,
      status: InvoicePaymentStatus.unpaid,
    ),
    InvoiceCardData(
      invoiceNumber: 'INV-20261109-003',
      customerName: 'Kevin Lim',
      plateNumber: 'QA 7345 D',
      date: '9 Nov 2026',
      paidAmount: 300,
      totalAmount: 500,
      status: InvoicePaymentStatus.partiallyPaid,
    ),
    InvoiceCardData(
      invoiceNumber: 'INV-20261105-001',
      customerName: 'Mei Ling Tan',
      plateNumber: 'QB 4410 M',
      date: '5 Nov 2026',
      paidAmount: 500,
      totalAmount: 500,
      status: InvoicePaymentStatus.paid,
    ),
    InvoiceCardData(
      invoiceNumber: 'INV-20261101-002',
      customerName: 'Aisha Rahman',
      plateNumber: 'QK 8821 B',
      date: '1 Nov 2026',
      paidAmount: 500,
      totalAmount: 500,
      status: InvoicePaymentStatus.paid,
    ),
    InvoiceCardData(
      invoiceNumber: 'INV-20261028-001',
      customerName: 'Farid Ismail',
      plateNumber: 'QA 9902 F',
      date: '1 Nov 2026',
      paidAmount: 500,
      totalAmount: 500,
      status: InvoicePaymentStatus.paid,
    ),
  ];

  String _searchQuery = '';
  InvoicePaymentStatus? _selectedStatus;

  List<InvoiceCardData> get _visibleInvoices {
    final query = _searchQuery.trim().toLowerCase();
    return _invoices.where((invoice) {
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
    if (status == null) return _invoices.length;
    return _invoices.where((invoice) => invoice.status == status).length;
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
              height: 48,
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

class InvoiceCardData {
  const InvoiceCardData({
    required this.invoiceNumber,
    required this.customerName,
    required this.plateNumber,
    required this.date,
    required this.paidAmount,
    required this.totalAmount,
    required this.status,
  });

  final String invoiceNumber;
  final String customerName;
  final String plateNumber;
  final String date;
  final double paidAmount;
  final double totalAmount;
  final InvoicePaymentStatus status;
}

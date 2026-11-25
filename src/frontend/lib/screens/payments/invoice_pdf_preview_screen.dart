import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../mock_data/invoices.dart';
import '../../models/deposit.dart';
import '../../providers/deposit_provider.dart';

class InvoicePdfPreviewScreen extends StatelessWidget {
  const InvoicePdfPreviewScreen({super.key, required this.invoice});

  final InvoiceData invoice;

  static const _navy = Color(0xFF071957);

  @override
  Widget build(BuildContext context) {
    final deposit = context
        .watch<DepositProvider>()
        .deposits
        .where((item) => item.invoiceNumber == invoice.invoiceNumber)
        .firstOrNull;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Invoice PDF',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _headerAction(
                        icon: Icons.smart_toy_outlined,
                        tooltip: 'AI assistant',
                        onTap: () => _showMessage(context, 'AI assistant'),
                      ),
                      const SizedBox(width: 8),
                      _headerAction(
                        icon: Icons.person,
                        tooltip: 'Profile',
                        onTap: () => _showMessage(context, 'Profile'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 4, 32, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${invoice.invoiceNumber}.pdf',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    'PDF',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _InvoiceDocument(
                        invoice: invoice,
                        depositSummary: deposit == null
                            ? 'Deposit status unavailable.'
                            : '${deposit.status.label} · ${deposit.statusDetail}',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showMessage(context, 'Print'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _navy,
                        side: const BorderSide(color: _navy),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Print',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showMessage(context, 'Share'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: const Text(
                        'Share',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 17,
          backgroundColor: Colors.grey.shade300,
          child: Icon(icon, size: 19, color: Colors.black),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String action) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$action is not available yet.')));
  }
}

class _InvoiceDocument extends StatelessWidget {
  const _InvoiceDocument({required this.invoice, required this.depositSummary});

  final InvoiceData invoice;
  final String depositSummary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company Name',
                      style: TextStyle(
                        color: Color(0xFF071957),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Car rental',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'INVOICE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    invoice.date,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _documentField('Billed to', invoice.customerName),
              ),
              Expanded(child: _documentField('Vehicle', invoice.carType)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 14),
            child: _documentField(
              'Rental period',
              '${invoice.pickupDate} → ${invoice.returnDate}',
            ),
          ),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Description',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Amount (RM)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Divider(height: 12, color: Colors.black),
          _amountRow('Rental', invoice.rental),
          _amountRow('Delivery', invoice.delivery),
          _amountRow('Outstation', invoice.outstation),
          _amountRow('Deposit (refundable)', invoice.deposit),
          _amountRow('Add-ons', invoice.addOns),
          _amountRow('Discount', invoice.discount, negative: true),
          const Divider(height: 14),
          Row(
            children: [
              const Expanded(child: Text('Total')),
              Text(
                _money(invoice.totalAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 8),
            child: Divider(height: 1),
          ),
          Text(
            depositSummary,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _documentField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        if (label == 'Vehicle') ...[
          const SizedBox(height: 3),
          Text(
            invoice.plateNumber,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ],
    );
  }

  Widget _amountRow(String label, double amount, {bool negative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
          Text(
            '${negative ? '− ' : ''}${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _money(double amount) => 'RM ${amount.toStringAsFixed(2)}';
}

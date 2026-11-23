import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../mock_data/invoices.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/app_top_bar.dart';
import 'add_payment_screen.dart';
import 'invoice_pdf_preview_screen.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key, required this.invoice});

  final InvoiceData invoice;

  static const _navy = Color(0xFF071957);
  static const _panel = Color(0xFFF1F1F5);

  String get _statusLabel => switch (invoice.status) {
    InvoicePaymentStatus.unpaid => 'Unpaid',
    InvoicePaymentStatus.partiallyPaid => 'Partially paid',
    InvoicePaymentStatus.paid => 'Paid',
  };

  @override
  Widget build(BuildContext context) {
    final invoice = context.watch<InvoiceProvider>().invoices.firstWhere(
      (item) => item.invoiceNumber == this.invoice.invoiceNumber,
      orElse: () => this.invoice,
    );
    final progress = invoice.totalAmount == 0
        ? 0.0
        : (invoice.paidAmount / invoice.totalAmount).clamp(0.0, 1.0).toDouble();

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
                  Expanded(
                    child: AppTopBar(
                      title: 'Invoice Details',
                      onAssistantTap: () =>
                          _showMessage(context, 'AI assistant'),
                      onProfileTap: () => _showMessage(context, 'Profile'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            invoice.invoiceNumber,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _invoiceStatus(),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton.filledTonal(
                            tooltip: 'Preview invoice PDF',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    InvoicePdfPreviewScreen(invoice: invoice),
                              ),
                            ),
                            icon: const Icon(
                              Icons.download_for_offline_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _sectionTitle('Customer & Vehicle'),
                    const SizedBox(height: 8),
                    _panelCard(
                      child: Column(
                        children: [
                          _labelValue('Full name', invoice.customerName),
                          _labelValue('Car type', invoice.carType),
                          _labelValue('Plate no.', invoice.plateNumber),
                          _labelValue(
                            'Pickup → Return',
                            '${invoice.pickupDate} → ${invoice.returnDate}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _sectionTitle('Invoice Summary'),
                    const SizedBox(height: 8),
                    _panelCard(
                      child: Column(
                        children: [
                          _summaryRow('Rental', invoice.rental),
                          _summaryRow('Delivery', invoice.delivery),
                          _summaryRow('Outstation', invoice.outstation),
                          _summaryRow('Deposit', invoice.deposit),
                          _summaryRow('Add-ons', invoice.addOns),
                          _summaryRow(
                            'Discount',
                            invoice.discount,
                            negative: true,
                          ),
                          const Divider(height: 18),
                          _summaryRow(
                            'Total',
                            invoice.totalAmount,
                            prominent: true,
                          ),
                          _summaryRow('Paid', invoice.paidAmount),
                          _summaryRow(
                            'Balance',
                            invoice.balance,
                            prominent: true,
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              color: _navy,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _depositCard(),
                    const SizedBox(height: 10),
                    _sectionTitle('Payment History'),
                    const SizedBox(height: 8),
                    _panelCard(
                      child: invoice.payments.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Text(
                                  'No payments yet',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < invoice.payments.length;
                                  index++
                                ) ...[
                                  if (index > 0) const Divider(height: 16),
                                  _paymentRow(invoice.payments[index]),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: invoice.balance > 0
                      ? () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AddPaymentScreen(invoice: invoice),
                          ),
                        )
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    disabledBackgroundColor: _navy,
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    invoice.balance > 0 ? 'Add payment' : 'Paid in full',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceStatus() {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: _navy),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        _statusLabel,
        style: const TextStyle(color: _navy, fontSize: 12),
      ),
    );
  }

  Widget _depositCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD3D3D7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Deposit ${_money(invoice.deposit)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  invoice.depositStatus,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            invoice.depositDetail,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(InvoicePaymentData payment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${payment.date} · ${payment.method}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                payment.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _money(payment.amount),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _labelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double amount, {
    bool negative = false,
    bool prominent = false,
  }) {
    final amountText = '${negative ? '− ' : ''}${_money(amount)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: prominent ? 13 : 12,
                color: prominent ? Colors.black : Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            amountText,
            style: TextStyle(
              fontSize: label == 'Total' ? 20 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
  );

  Widget _panelCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );

  String _money(double amount) => 'RM ${amount.toStringAsFixed(2)}';

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

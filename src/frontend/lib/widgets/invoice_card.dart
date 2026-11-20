import 'package:flutter/material.dart';

enum InvoicePaymentStatus { unpaid, partiallyPaid, paid }

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoiceNumber,
    required this.customerName,
    required this.plateNumber,
    required this.date,
    required this.paidAmount,
    required this.totalAmount,
    required this.status,
  });

  static const Color navyBlue = Color(0xFF071957);

  final String invoiceNumber;
  final String customerName;
  final String plateNumber;
  final String date;
  final double paidAmount;
  final double totalAmount;
  final InvoicePaymentStatus status;

  String get statusLabel => switch (status) {
    InvoicePaymentStatus.unpaid => 'Unpaid',
    InvoicePaymentStatus.partiallyPaid => 'Partially paid',
    InvoicePaymentStatus.paid => 'Paid',
  };

  double get paymentProgress => totalAmount <= 0
      ? 0
      : (paidAmount / totalAmount).clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    final balance = (totalAmount - paidAmount).clamp(0.0, totalAmount);
    final paid = status == InvoicePaymentStatus.paid;

    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFFF1F1F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    invoiceNumber,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          customerName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          ' · $plateNumber',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(label: statusLabel, paid: paid),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: paymentProgress,
                minHeight: 8,
                backgroundColor: Colors.white,
                color: navyBlue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'RM ${paidAmount.toStringAsFixed(2)} of RM ${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
                Text(
                  'Balance RM ${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.paid});

  final String label;
  final bool paid;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: paid ? InvoiceCard.navyBlue : Colors.white,
        border: paid ? null : Border.all(color: InvoiceCard.navyBlue),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: paid ? Colors.white : InvoiceCard.navyBlue,
          fontSize: 12,
        ),
      ),
    );
  }
}

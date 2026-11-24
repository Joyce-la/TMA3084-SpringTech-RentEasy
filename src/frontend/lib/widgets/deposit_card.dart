import 'package:material_ui/material_ui.dart';

import '../models/deposit.dart';

export '../models/deposit.dart' show DepositStatus;

class DepositCard extends StatelessWidget {
  const DepositCard({
    super.key,
    required this.invoiceNumber,
    required this.customerName,
    required this.plateNumber,
    required this.status,
    required this.collectedAmount,
    required this.statusDetail,
    this.refundedAmount,
    this.onPrimaryAction,
  });

  static const Color navyBlue = Color(0xFF071957);

  final String invoiceNumber;
  final String customerName;
  final String plateNumber;
  final DepositStatus status;
  final double collectedAmount;
  final String statusDetail;
  final double? refundedAmount;
  final VoidCallback? onPrimaryAction;

  String? get primaryActionLabel => switch (status) {
    DepositStatus.eligibleToRefund => 'Refund',
    DepositStatus.checking => 'Record Incident',
    _ => null,
  };

  Color get _statusColor => switch (status) {
    DepositStatus.eligibleToRefund => const Color(0xFF48A85A),
    DepositStatus.checking => const Color(0xFFFFBE69),
    DepositStatus.pending => const Color(0xFFC9C9CD),
    DepositStatus.holding => const Color(0xFF98989D),
    DepositStatus.partiallyRefunded => const Color(0xFFC9C9CD),
    DepositStatus.refunded => const Color(0xFFC9C9CD),
  };

  @override
  Widget build(BuildContext context) {
    final refundAmount = refundedAmount;
    final details = refundAmount == null
        ? statusDetail
        : 'Refunded RM ${refundAmount.toStringAsFixed(2)} · $statusDetail';

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
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
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
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Collected RM ${collectedAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
                Flexible(
                  child: Text(
                    details,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            if (primaryActionLabel != null && onPrimaryAction != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onPrimaryAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: navyBlue,
                    backgroundColor: status == DepositStatus.eligibleToRefund
                        ? navyBlue
                        : Colors.white,
                    side: const BorderSide(color: navyBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    primaryActionLabel!,
                    style: TextStyle(
                      color: status == DepositStatus.eligibleToRefund
                          ? Colors.white
                          : navyBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

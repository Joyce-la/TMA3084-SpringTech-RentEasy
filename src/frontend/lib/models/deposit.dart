enum DepositStatus {
  eligibleToRefund,
  checking,
  pending,
  holding,
  partiallyRefunded,
}

class DepositData {
  const DepositData({
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

  DepositData copyWith({
    DepositStatus? status,
    double? collectedAmount,
    String? statusDetail,
  }) {
    return DepositData(
      invoiceNumber: invoiceNumber,
      customerName: customerName,
      plateNumber: plateNumber,
      status: status ?? this.status,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      statusDetail: statusDetail ?? this.statusDetail,
      refundedAmount: refundedAmount,
      actionLabel: actionLabel,
    );
  }
}

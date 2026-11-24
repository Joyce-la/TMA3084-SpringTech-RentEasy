enum DepositStatus {
  eligibleToRefund,
  checking,
  pending,
  holding,
  partiallyRefunded,
  refunded,
}

extension DepositStatusLabel on DepositStatus {
  String get label => switch (this) {
    DepositStatus.eligibleToRefund => 'ELIGIBLE TO REFUND',
    DepositStatus.checking => '3-days CHECKING',
    DepositStatus.pending => 'PENDING',
    DepositStatus.holding => 'HOLDING',
    DepositStatus.partiallyRefunded => 'PARTIALLY REFUNDED',
    DepositStatus.refunded => 'REFUNDED',
  };
}

class DepositData {
  const DepositData({
    required this.invoiceNumber,
    required this.customerName,
    required this.plateNumber,
    required this.status,
    required this.collectedAmount,
    required this.statusDetail,
    this.carType = '',
    this.returnedDate,
    this.refundedAmount,
  });

  final String invoiceNumber;
  final String customerName;
  final String plateNumber;
  final DepositStatus status;
  final double collectedAmount;
  final String statusDetail;
  final String carType;
  final String? returnedDate;
  final double? refundedAmount;

  DepositData copyWith({
    DepositStatus? status,
    double? collectedAmount,
    String? statusDetail,
    String? carType,
    String? returnedDate,
    double? refundedAmount,
  }) {
    return DepositData(
      invoiceNumber: invoiceNumber,
      customerName: customerName,
      plateNumber: plateNumber,
      status: status ?? this.status,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      statusDetail: statusDetail ?? this.statusDetail,
      carType: carType ?? this.carType,
      returnedDate: returnedDate ?? this.returnedDate,
      refundedAmount: refundedAmount ?? this.refundedAmount,
    );
  }
}

enum InvoicePaymentStatus { unpaid, partiallyPaid, paid }

class InvoiceData {
  const InvoiceData({
    required this.invoiceNumber,
    required this.customerName,
    required this.carType,
    required this.plateNumber,
    required this.date,
    required this.pickupDate,
    required this.returnDate,
    required this.rental,
    required this.delivery,
    required this.outstation,
    required this.deposit,
    required this.addOns,
    required this.discount,
    required this.paidAmount,
    required this.status,
    required this.depositStatus,
    required this.depositDetail,
    required this.payments,
  });

  final String invoiceNumber;
  final String customerName;
  final String carType;
  final String plateNumber;
  final String date;
  final String pickupDate;
  final String returnDate;
  final double rental;
  final double delivery;
  final double outstation;
  final double deposit;
  final double addOns;
  final double discount;
  final double paidAmount;
  final InvoicePaymentStatus status;
  final String depositStatus;
  final String depositDetail;
  final List<InvoicePaymentData> payments;

  double get totalAmount =>
      rental + delivery + outstation + deposit + addOns - discount;

  double get balance => totalAmount - paidAmount;

}

class InvoicePaymentData {
  const InvoicePaymentData({
    required this.date,
    required this.method,
    required this.description,
    required this.amount,
  });

  final String date;
  final String method;
  final String description;
  final double amount;
}

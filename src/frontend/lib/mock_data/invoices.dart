import 'database_records.dart';

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

final mockInvoices = List<InvoiceData>.unmodifiable(
  mockDatabase['Invoice']!.map(_invoiceFromRecord),
);

InvoiceData _invoiceFromRecord(Map<String, Object?> invoice) {
  final rental = _recordById('Rental', 'rentalId', invoice['rentalId']);
  final vehicle = _recordById('Vehicle', 'vehicleId', rental['vehicleId']);
  final user = _recordById('User', 'userId', rental['userId']);
  final deposit = mockDatabase['Deposit']!.firstWhere(
    (record) => record['rentalId'] == rental['rentalId'],
  );
  final charges = mockDatabase['RentalCharge']!
      .where((record) => record['rentalId'] == rental['rentalId'])
      .toList();
  final payments = mockDatabase['Payment']!
      .where((record) => record['invoiceId'] == invoice['invoiceId'])
      .map(
        (payment) => InvoicePaymentData(
          date: _displayDate(payment['paymentDateTime'], includeYear: false),
          method: _string(payment, 'paymentMethod'),
          description: _string(payment, 'paymentType'),
          amount: _number(payment, 'paymentAmount'),
        ),
      )
      .toList();

  return InvoiceData(
    invoiceNumber: _string(invoice, 'invoiceNo'),
    customerName: _string(user, 'name'),
    carType: '${_string(vehicle, 'category')} (${_string(vehicle, 'model')})',
    plateNumber: _string(vehicle, 'plateNo'),
    date: _displayDate(invoice['issueDate']),
    pickupDate: _displayDate(rental['pickupDateTime']),
    returnDate: _displayDate(rental['returnDateTime']),
    rental: _number(rental, 'rentalPrice'),
    delivery: _chargeTotal(charges, 'Delivery'),
    outstation: _chargeTotal(charges, 'Outstation'),
    deposit: _number(invoice, 'depositAmount'),
    addOns: _chargeTotal(charges, 'Add-ons'),
    discount: -_chargeTotal(charges, 'Discount'),
    paidAmount: _number(invoice, 'paidAmount'),
    status: switch (_string(invoice, 'paymentStatus')) {
      'unpaid' => InvoicePaymentStatus.unpaid,
      'partiallyPaid' => InvoicePaymentStatus.partiallyPaid,
      'paid' => InvoicePaymentStatus.paid,
      final status => throw StateError(
        'Unknown invoice payment status: $status',
      ),
    },
    depositStatus: _string(deposit, 'depositStatus').toUpperCase(),
    depositDetail: _string(deposit, 'description'),
    payments: List.unmodifiable(payments),
  );
}

Map<String, Object?> _recordById(String table, String idField, Object? id) {
  return mockDatabase[table]!.firstWhere((record) => record[idField] == id);
}

String _string(Map<String, Object?> record, String field) =>
    record[field] as String;

double _number(Map<String, Object?> record, String field) =>
    (record[field] as num).toDouble();

double _chargeTotal(List<Map<String, Object?>> charges, String chargeType) {
  return charges
      .where((charge) => charge['chargeType'] == chargeType)
      .fold(0.0, (total, charge) => total + _number(charge, 'chargeAmount'));
}

String _displayDate(Object? value, {bool includeYear = true}) {
  final date = DateTime.parse(value as String);
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final formatted = '${date.day} ${months[date.month - 1]}';
  return includeYear ? '$formatted ${date.year}' : formatted;
}

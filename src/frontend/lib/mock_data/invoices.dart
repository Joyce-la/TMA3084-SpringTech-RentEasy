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

const mockInvoices = <InvoiceData>[
  InvoiceData(
    invoiceNumber: 'INV-20261110-001',
    customerName: 'Grace Ling',
    carType: 'Sedan (Toyota Vios)',
    plateNumber: 'QAA 1234',
    date: '10 Nov 2026',
    pickupDate: '10 Nov 2026',
    returnDate: '13 Nov 2026',
    rental: 600,
    delivery: 20,
    outstation: 10,
    deposit: 100,
    addOns: 210,
    discount: 50,
    paidAmount: 0,
    status: InvoicePaymentStatus.unpaid,
    depositStatus: 'PENDING',
    depositDetail: 'Not collected yet.',
    payments: [],
  ),
  InvoiceData(
    invoiceNumber: 'INV-20261109-003',
    customerName: 'Kevin Lim',
    carType: 'Hatchback (Perodua Myvi)',
    plateNumber: 'QA 7345 D',
    date: '9 Nov 2026',
    pickupDate: '11 Nov 2026',
    returnDate: '15 Nov 2026',
    rental: 300,
    delivery: 50,
    outstation: 30,
    deposit: 100,
    addOns: 40,
    discount: 20,
    paidAmount: 300,
    status: InvoicePaymentStatus.partiallyPaid,
    depositStatus: 'HOLDING',
    depositDetail: 'Refund opens 3 days after the car is returned and checked.',
    payments: [
      InvoicePaymentData(
        date: '9 Nov',
        method: 'Bank transfer',
        description: 'Rental charges',
        amount: 200,
      ),
      InvoicePaymentData(
        date: '10 Nov',
        method: 'Cash',
        description: 'Deposit',
        amount: 100,
      ),
    ],
  ),
  InvoiceData(
    invoiceNumber: 'INV-20261105-001',
    customerName: 'Mei Ling Tan',
    carType: 'Compact (Perodua Axia)',
    plateNumber: 'QB 4410 M',
    date: '5 Nov 2026',
    pickupDate: '5 Nov 2026',
    returnDate: '7 Nov 2026',
    rental: 350,
    delivery: 20,
    outstation: 0,
    deposit: 100,
    addOns: 50,
    discount: 20,
    paidAmount: 500,
    status: InvoicePaymentStatus.paid,
    depositStatus: 'REFUNDED',
    depositDetail: 'Refunded after the car was returned and checked.',
    payments: [
      InvoicePaymentData(
        date: '5 Nov',
        method: 'Bank transfer',
        description: 'Rental charges',
        amount: 400,
      ),
      InvoicePaymentData(
        date: '5 Nov',
        method: 'Cash',
        description: 'Remaining balance',
        amount: 100,
      ),
    ],
  ),
  InvoiceData(
    invoiceNumber: 'INV-20261101-002',
    customerName: 'Aisha Rahman',
    carType: 'Sedan (Honda City)',
    plateNumber: 'QK 8821 B',
    date: '1 Nov 2026',
    pickupDate: '1 Nov 2026',
    returnDate: '4 Nov 2026',
    rental: 300,
    delivery: 20,
    outstation: 20,
    deposit: 100,
    addOns: 80,
    discount: 20,
    paidAmount: 500,
    status: InvoicePaymentStatus.paid,
    depositStatus: 'REFUNDED',
    depositDetail: 'Refunded after the car was returned and checked.',
    payments: [
      InvoicePaymentData(
        date: '1 Nov',
        method: 'Bank transfer',
        description: 'Invoice paid in full',
        amount: 500,
      ),
    ],
  ),
  InvoiceData(
    invoiceNumber: 'INV-20261028-001',
    customerName: 'Farid Ismail',
    carType: 'SUV (Perodua Aruz)',
    plateNumber: 'QA 9902 F',
    date: '28 Oct 2026',
    pickupDate: '1 Nov 2026',
    returnDate: '3 Nov 2026',
    rental: 400,
    delivery: 0,
    outstation: 0,
    deposit: 100,
    addOns: 20,
    discount: 20,
    paidAmount: 500,
    status: InvoicePaymentStatus.paid,
    depositStatus: 'REFUNDED',
    depositDetail: 'Refunded after the car was returned and checked.',
    payments: [
      InvoicePaymentData(
        date: '1 Nov',
        method: 'Cash',
        description: 'Invoice paid in full',
        amount: 500,
      ),
    ],
  ),
];

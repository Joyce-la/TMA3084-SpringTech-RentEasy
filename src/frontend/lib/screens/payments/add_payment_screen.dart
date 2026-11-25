import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_top_bar.dart';
import '../../models/deposit.dart';
import '../../models/invoice.dart';
import '../../providers/deposit_provider.dart';
import '../../providers/invoice_provider.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key, required this.invoice});

  final InvoiceData invoice;

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  static const navy = Color(0xFF071957);
  static const panel = Color(0xFFF1F1F5);

  late final TextEditingController _totalController;
  late final TextEditingController _dateController;
  final _referenceController = TextEditingController();
  late final TextEditingController _rentalController;
  late final TextEditingController _depositController;

  String _method = 'Cash';
  late DateTime _paymentDate;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _touched = true;
    _paymentDate = DateTime.now();
    _dateController = TextEditingController(text: _formatDate(_paymentDate));
    _totalController = TextEditingController();
    _rentalController = TextEditingController(text: '0.00');
    _depositController = TextEditingController(text: '0.00');
    _totalController.addListener(_onTotalChanged);
  }

  @override
  void dispose() {
    _totalController.removeListener(_onTotalChanged);
    _totalController.dispose();
    _dateController.dispose();
    _referenceController.dispose();
    _rentalController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  double get _paidRental => widget.invoice.payments
      .where((payment) => payment.description == 'Rental charges')
      .fold(0.0, (total, payment) => total + payment.amount);

  double get _paidDeposit => widget.invoice.payments
      .where((payment) => payment.description == 'Deposit')
      .fold(0.0, (total, payment) => total + payment.amount);

  double get _rentalBalance =>
      (widget.invoice.rental +
              widget.invoice.delivery +
              widget.invoice.outstation +
              widget.invoice.addOns -
              widget.invoice.discount -
              _paidRental)
          .clamp(0.0, double.infinity);

  double get _depositBalance =>
      (widget.invoice.deposit - _paidDeposit).clamp(0.0, double.infinity);

  double _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0.0;

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _money(double amount) => 'RM ${amount.toStringAsFixed(2)}';

  void _onTotalChanged() {
    setState(() {});
  }

  bool get _totalExceedsBalance =>
      _parse(_totalController) > widget.invoice.balance;

  bool get _allocationsMismatch {
    final total = _parse(_totalController);
    final rental = _parse(_rentalController);
    final deposit = _parse(_depositController);
    return (rental + deposit - total).abs() > 0.005;
  }

  bool get _canSave {
    final total = _parse(_totalController);
    final rental = _parse(_rentalController);
    final deposit = _parse(_depositController);
    return _touched &&
        total > 0 &&
        _rentalController.text.trim().isNotEmpty &&
        _depositController.text.trim().isNotEmpty &&
        _dateController.text.trim().isNotEmpty &&
        !_totalExceedsBalance &&
        rental <= _rentalBalance &&
        deposit <= _depositBalance &&
        !_allocationsMismatch;
  }

  @override
  Widget build(BuildContext context) {
    final invoice = context.watch<InvoiceProvider>().invoices.firstWhere(
      (item) => item.invoiceNumber == widget.invoice.invoiceNumber,
      orElse: () => widget.invoice,
    );
    final unallocated =
        (_parse(_totalController) -
                _parse(_rentalController) -
                _parse(_depositController))
            .toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  Expanded(
                    child: AppTopBar(
                      title: 'Record Payment',
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
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Invoice'),
                    const SizedBox(height: 8),
                    _panel(
                      child: Column(
                        children: [
                          _labelValue('Invoice no.', invoice.invoiceNumber),
                          _labelValue('Customer', invoice.customerName),
                          _labelValue('Car Type', invoice.carType),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _sectionTitle('Amount to Collect'),
                    const SizedBox(height: 8),
                    _panel(child: _amountTable(invoice)),
                    const SizedBox(height: 10),
                    _sectionTitle('Payment Received'),
                    const SizedBox(height: 8),
                    Text(
                      'Total received (RM) *',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _textField(
                      key: const Key('payment-total'),
                      controller: _totalController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      error: _totalExceedsBalance
                          ? 'Amount exceeds the balance'
                          : (_touched && _parse(_totalController) <= 0
                                ? 'Required'
                                : null),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _methodButton('Cash')),
                        const SizedBox(width: 8),
                        Expanded(child: _methodButton('Bank transfer')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment date *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              _textField(
                                key: const Key('payment-date'),
                                controller: _dateController,
                                readOnly: true,
                                onTap: _pickDate,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reference (optional)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              _textField(
                                key: const Key('payment-reference'),
                                controller: _referenceController,
                                hint: 'e.g. transfer ref.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _sectionTitle('Allocate Payment'),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rental charges *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              _textField(
                                key: const Key('payment-rental'),
                                controller: _rentalController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                onChanged: (_) => setState(() {}),
                                error: _rentalController.text.trim().isEmpty
                                    ? 'Required'
                                    : _parse(_rentalController) > _rentalBalance
                                    ? 'Exceeds rental balance'
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Maximum ${_money(_rentalBalance)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deposit',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              _textField(
                                key: const Key('payment-deposit'),
                                controller: _depositController,
                                readOnly: _depositBalance == 0,
                                fillColor: _depositBalance == 0
                                    ? const Color(0xFFF1F1F5)
                                    : Colors.white,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                onChanged: _depositBalance == 0
                                    ? null
                                    : (_) => setState(() {}),
                                error: _depositController.text.trim().isEmpty
                                    ? 'Required'
                                    : _parse(_depositController) >
                                          _depositBalance
                                    ? 'Exceeds deposit balance'
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _depositBalance == 0
                                    ? 'Fully collected'
                                    : 'Maximum ${_money(_depositBalance)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: unallocated.abs() <= 0.005
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFFD6D6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Unallocated (auto)',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _money(unallocated.abs()),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      unallocated.abs() <= 0.005
                          ? 'Payment allocations are complete.'
                          : 'Save is enabled only when Unallocated is RM 0.00.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: panel,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: FilledButton(
                        key: const Key('save-payment'),
                        onPressed: _canSave
                            ? () => _savePayment(context)
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: navy,
                          disabledBackgroundColor: navy,
                          disabledForegroundColor: Colors.white54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Save payment',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
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

  Widget _amountTable(InvoiceData invoice) {
    final paidRental = _paidRental;
    final paidDeposit = _paidDeposit;
    final rentalCharges =
        invoice.rental +
        invoice.delivery +
        invoice.outstation +
        invoice.addOns -
        invoice.discount;
    final rentalBalance = (rentalCharges - paidRental).clamp(
      0.0,
      double.infinity,
    );
    final depositBalance = (invoice.deposit - paidDeposit).clamp(
      0.0,
      double.infinity,
    );
    final invoiceTotal = rentalCharges + invoice.deposit;
    final invoicePaid = paidRental + paidDeposit;
    final invoiceBalance = rentalBalance + depositBalance.toDouble();
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.1),
        1: FlexColumnWidth(1.05),
        2: FlexColumnWidth(1.05),
        3: FlexColumnWidth(1.05),
      },
      children: [
        TableRow(
          children: [
            _tableLabel('', bold: true),
            _tableText('Total', bold: true),
            _tableText('Paid', bold: true),
            _tableText('Balance', bold: true),
          ],
        ),
        TableRow(
          children: [
            _tableLabel('Rental charges'),
            _tableText(_money(rentalCharges)),
            _tableText(_money(paidRental)),
            _tableText(_money(rentalBalance.toDouble())),
          ],
        ),
        TableRow(
          children: [
            _tableLabel('Deposit'),
            _tableText(_money(invoice.deposit)),
            _tableText(_money(paidDeposit)),
            _tableText(_money(depositBalance.toDouble())),
          ],
        ),
        const TableRow(
          children: [
            SizedBox(height: 8),
            SizedBox(height: 8),
            SizedBox(height: 8),
            SizedBox(height: 8),
          ],
        ),
        TableRow(
          children: [
            _tableLabel('Invoice', bold: true),
            _tableText(_money(invoiceTotal), bold: true),
            _tableText(_money(invoicePaid), bold: true),
            _tableText(_money(invoiceBalance), bold: true),
          ],
        ),
      ],
    );
  }

  Widget _tableLabel(String text, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 12,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      ),
    ),
  );

  Widget _tableText(String text, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 11,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      ),
    ),
  );

  Widget _methodButton(String method) {
    final selected = _method == method;
    return SizedBox(
      height: 46,
      child: FilledButton(
        key: Key('payment-method-${method.toLowerCase().replaceAll(' ', '-')}'),
        onPressed: () => setState(() => _method = method),
        style: FilledButton.styleFrom(
          backgroundColor: selected ? navy : panel,
          foregroundColor: selected ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(method),
      ),
    );
  }

  Widget _textField({
    Key? key,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? hint,
    String? error,
    bool readOnly = false,
    Color fillColor = Colors.white,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      key: key,
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: (value) {
        setState(() => _touched = true);
        onChanged?.call(value);
      },
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        errorText: error,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: error == null ? const Color(0xFFB8B8BD) : Colors.red,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: error == null ? navy : Colors.red,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _panel({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
  );

  Widget _labelValue(String label, String value) => Padding(
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(_paymentDate.year - 5),
      lastDate: DateTime(_paymentDate.year + 5),
    );
    if (picked != null) {
      setState(() {
        _paymentDate = picked;
        _dateController.text = _formatDate(picked);
        _touched = true;
      });
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$message is not available yet.')));
  }

  void _savePayment(BuildContext context) {
    if (!_canSave) return;
    final total = _parse(_totalController);
    final rental = _parse(_rentalController);
    final deposit = _parse(_depositController);
    final provider = context.read<InvoiceProvider>();
    final current = provider.invoices.firstWhere(
      (item) => item.invoiceNumber == widget.invoice.invoiceNumber,
    );
    final paidAmount = current.paidAmount + total;
    final payments = <InvoicePaymentData>[
      if (rental > 0)
        InvoicePaymentData(
          date: _dateController.text,
          method: _method,
          description: 'Rental charges',
          amount: rental,
        ),
      if (deposit > 0)
        InvoicePaymentData(
          date: _dateController.text,
          method: _method,
          description: 'Deposit',
          amount: deposit,
        ),
    ];
    final status = paidAmount >= current.totalAmount
        ? InvoicePaymentStatus.paid
        : paidAmount > 0
        ? InvoicePaymentStatus.partiallyPaid
        : InvoicePaymentStatus.unpaid;
    provider.updateInvoice(
      current.copyWith(
        paidAmount: paidAmount,
        status: status,
        payments: <InvoicePaymentData>[...current.payments, ...payments],
      ),
    );
    if (context.mounted) {
      final depositProvider = context.read<DepositProvider>();
      final matchingDeposit = depositProvider.deposits
          .where((item) => item.invoiceNumber == current.invoiceNumber)
          .firstOrNull;
      if (matchingDeposit != null) {
        final depositCollected = matchingDeposit.collectedAmount + deposit;
        final depositFullyCollected = _paidDeposit + deposit >= current.deposit;
        depositProvider.updateDeposit(
          matchingDeposit.copyWith(
            status: depositFullyCollected
                ? DepositStatus.holding
                : matchingDeposit.status,
            collectedAmount: depositCollected,
            statusDetail: depositFullyCollected
                ? 'Deposit fully collected · held'
                : matchingDeposit.statusDetail,
          ),
        );
      }
    }
    Navigator.of(context).pop();
  }
}

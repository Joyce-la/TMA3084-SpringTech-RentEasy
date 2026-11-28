import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
  static const borderGrey = Color(0xFFB8B8BD);

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
    _paymentDate = DateTime.now();
    _dateController = TextEditingController(text: _formatDate(_paymentDate));
    _totalController = TextEditingController();
    _rentalController = TextEditingController();
    _depositController = TextEditingController();
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
    final paymentDateField = _labeledField(
      'Payment date *',
      _textField(
        key: const Key('payment-date'),
        controller: _dateController,
        readOnly: true,
        onTap: _pickDate,
      ),
    );
    final referenceField = _labeledField(
      'Reference (optional)',
      _textField(
        key: const Key('payment-reference'),
        controller: _referenceController,
        hint: 'e.g. transfer ref.',
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  overscroll: false,
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        'Invoice',
                        Column(
                          children: [
                            _labelValue(
                              'Invoice no.',
                              invoice.invoiceNumber,
                              valueColor: Colors.blue,
                            ),
                            _labelValue('Customer', invoice.customerName),
                            _labelValue('Car Type', invoice.carType),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _sectionCard('Amount to Collect', _amountTable(invoice)),
                      const SizedBox(height: 12),
                      _sectionCard(
                        'Payment Received',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _labeledField(
                              'Total received (RM) *',
                              _textField(
                                key: const Key('payment-total'),
                                controller: _totalController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                error: _totalExceedsBalance
                                    ? 'Amount exceeds the balance'
                                    : (_touched && _parse(_totalController) <= 0
                                          ? 'Required'
                                          : null),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _methodButton('Cash')),
                                const SizedBox(width: 8),
                                Expanded(child: _methodButton('Bank transfer')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_method == 'Bank transfer')
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: paymentDateField),
                                  const SizedBox(width: 10),
                                  Expanded(child: referenceField),
                                ],
                              )
                            else
                              paymentDateField,
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _sectionCard(
                        'Allocate Payment',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _labeledField(
                                    'Rental charges *',
                                    _textField(
                                      key: const Key('payment-rental'),
                                      controller: _rentalController,
                                      hint: '0.00',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9.]'),
                                        ),
                                      ],
                                      error:
                                          _rentalController.text
                                                  .trim()
                                                  .isNotEmpty &&
                                              _parse(_rentalController) >
                                                  _rentalBalance
                                          ? 'Exceeds rental balance'
                                          : null,
                                    ),
                                    helperText:
                                        'Maximum ${_money(_rentalBalance)}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _labeledField(
                                    'Deposit',
                                    _textField(
                                      key: const Key('payment-deposit'),
                                      controller: _depositController,
                                      readOnly: _depositBalance == 0,
                                      fillColor: _depositBalance == 0
                                          ? panel
                                          : Colors.white,
                                      hint: '0.00',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9.]'),
                                        ),
                                      ],
                                      error:
                                          _depositController.text
                                                  .trim()
                                                  .isNotEmpty &&
                                              _parse(_depositController) >
                                                  _depositBalance
                                          ? 'Exceeds deposit balance'
                                          : null,
                                    ),
                                    helperText: _depositBalance == 0
                                        ? 'Fully collected'
                                        : 'Maximum ${_money(_depositBalance)}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Unallocated (auto)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
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
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Record Payment',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9D9DD),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                key: const Key('save-payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _canSave ? () => _savePayment(context) : null,
                child: const Text(
                  'Save payment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _labeledField(String label, Widget field, {String? helperText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        field,
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ],
      ],
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
      height: 52,
      child: OutlinedButton(
        key: Key('payment-method-${method.toLowerCase().replaceAll(' ', '-')}'),
        onPressed: () => setState(() => _method = method),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? navy : Colors.white,
          foregroundColor: selected ? Colors.white : navy,
          side: BorderSide(color: selected ? navy : Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          method,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
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
  }) {
    return TextField(
      key: key,
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: (_) {
        setState(() => _touched = true);
      },
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        errorText: error,
        filled: true,
        fillColor: fillColor,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: _inputBorder(borderGrey),
        enabledBorder: _inputBorder(
          error == null ? borderGrey : Colors.red.shade700,
        ),
        focusedBorder: _inputBorder(
          error == null ? navy : Colors.red.shade700,
          2,
        ),
        errorBorder: _inputBorder(Colors.red.shade700),
        focusedErrorBorder: _inputBorder(Colors.red.shade700, 2),
        errorStyle: const TextStyle(fontSize: 10),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, [double width = 1.5]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _labelValue(
    String label,
    String value, {
    Color valueColor = Colors.black,
  }) => Padding(
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
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
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

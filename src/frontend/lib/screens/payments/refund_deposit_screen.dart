import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/deposit.dart';
import '../../providers/deposit_provider.dart';
import '../../widgets/app_top_bar.dart';

class RefundDepositScreen extends StatefulWidget {
  const RefundDepositScreen({super.key, required this.deposit});

  final DepositData deposit;

  @override
  State<RefundDepositScreen> createState() => _RefundDepositScreenState();
}

class _RefundDepositScreenState extends State<RefundDepositScreen> {
  static const navy = Color(0xFF071957);
  static const panel = Color(0xFFF1F1F5);

  late final TextEditingController _amountController;
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _partial = false;
  String _method = 'Cash';

  bool get _isChecking => widget.deposit.status == DepositStatus.checking;

  @override
  void initState() {
    super.initState();
    _partial = _isChecking;
    _amountController = TextEditingController(
      text: _isChecking
          ? ''
          : widget.deposit.collectedAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0.0;

  double get _deduction => (widget.deposit.collectedAmount - _amount)
      .clamp(0.0, widget.deposit.collectedAmount)
      .toDouble();

  bool get _canConfirm {
    final validAmount =
        _amount > 0 && _amount <= widget.deposit.collectedAmount;
    if (_isChecking) {
      return _partial &&
          validAmount &&
          _descriptionController.text.trim().isNotEmpty;
    }
    return validAmount;
  }

  @override
  Widget build(BuildContext context) {
    final deposit = context.watch<DepositProvider>().deposits.firstWhere(
      (item) => item.invoiceNumber == widget.deposit.invoiceNumber,
      orElse: () => widget.deposit,
    );

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
                  const SizedBox(width: 4),
                  Expanded(
                    child: AppTopBar(
                      title: 'Refund Deposit',
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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Deposit'),
                    const SizedBox(height: 8),
                    _panel(
                      child: Column(
                        children: [
                          _labelValue('Invoice no.', deposit.invoiceNumber),
                          _labelValue('Customer', deposit.customerName),
                          _labelValue(
                            'Car Type',
                            deposit.carType.isEmpty
                                ? deposit.plateNumber
                                : deposit.carType,
                          ),
                          _labelValue(
                            'Deposit collected',
                            _money(deposit.collectedAmount),
                          ),
                          if (deposit.returnedDate != null &&
                              deposit.returnedDate!.isNotEmpty)
                            _labelValue('Returned', deposit.returnedDate!),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF55555E),
                                  ),
                                ),
                              ),
                              _statusChip(deposit.status),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _sectionTitle('Refund Details'),
                    const SizedBox(height: 8),
                    Text(
                      'Refund type *',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _choiceButton(
                            key: const Key('refund-all'),
                            label: 'Refund all',
                            selected: !_partial,
                            enabled: !_isChecking,
                            onTap: () {
                              setState(() {
                                _partial = false;
                                _amountController.text = deposit.collectedAmount
                                    .toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _choiceButton(
                            key: const Key('refund-partial'),
                            label: 'Partial refund',
                            selected: _partial,
                            enabled: true,
                            onTap: () {
                              if (_partial) return;
                              setState(() {
                                _partial = true;
                                _amountController.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_isChecking) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Refund all options after the 3-day check (15 Nov).',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      'Refund amount (RM) *',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      key: const Key('refund-amount'),
                      controller: _amountController,
                      readOnly: !_partial,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                        errorText: _amount <= 0
                            ? 'Required'
                            : (_amount > deposit.collectedAmount
                                  ? 'Amount exceeds deposit'
                                  : null),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'More than 0 and less than or equal to ${_money(deposit.collectedAmount)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _labelValue('Deduction (auto)', _money(_deduction)),
                    const SizedBox(height: 10),
                    Text(
                      'Refund method *',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(child: _methodButton('Cash')),
                        const SizedBox(width: 8),
                        Expanded(child: _methodButton('Bank transfer')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Reference no.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      key: const Key('refund-reference'),
                      controller: _referenceController,
                      decoration: _inputDecoration(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isChecking ? 'Description *' : 'Description',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      key: const Key('refund-description'),
                      controller: _descriptionController,
                      maxLines: 3,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                        hintText: 'Description',
                        errorText:
                            _isChecking &&
                                _descriptionController.text.trim().isEmpty
                            ? 'Required'
                            : null,
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
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: navy,
                          backgroundColor: panel,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        key: const Key('confirm-refund'),
                        onPressed: _canConfirm ? _confirm : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: navy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Confirm refund',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
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

  void _confirm() {
    context.read<DepositProvider>().recordRefund(
      invoiceNumber: widget.deposit.invoiceNumber,
      refundAmount: _amount,
      description: _descriptionController.text,
    );
    Navigator.of(context).pop();
  }

  Widget _choiceButton({
    Key? key,
    required String label,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        key: key,
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? navy : Colors.white,
          foregroundColor: selected ? Colors.white : navy,
          disabledForegroundColor: Colors.grey.shade500,
          side: BorderSide(color: selected ? navy : Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _methodButton(String method) {
    final selected = _method == method;
    return SizedBox(
      height: 52,
      child: OutlinedButton(
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

  Widget _statusChip(DepositStatus status) {
    final label = switch (status) {
      DepositStatus.eligibleToRefund => 'ELIGIBLE TO REFUND',
      DepositStatus.checking => '3-DAYS CHECKING',
      DepositStatus.pending => 'PENDING',
      DepositStatus.holding => 'HOLDING',
      DepositStatus.partiallyRefunded => 'PARTIALLY REFUNDED',
      DepositStatus.refunded => 'REFUNDED',
    };
    final color = switch (status) {
      DepositStatus.eligibleToRefund => const Color(0xFF48A85A),
      DepositStatus.checking => const Color(0xFFFFBE69),
      _ => const Color(0xFFC9C9CD),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );

  Widget _panel({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );

  Widget _labelValue(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF55555E)),
          ),
        ),
        const SizedBox(width: 12),
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

  InputDecoration _inputDecoration({String? hintText, String? errorText}) {
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF888891)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF888891)),
      ),
    );
  }

  String _money(double amount) => 'RM ${amount.toStringAsFixed(2)}';

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message action is not available yet.')),
    );
  }
}

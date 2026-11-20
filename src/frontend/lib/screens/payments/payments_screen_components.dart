import 'package:material_ui/material_ui.dart';

Widget buildPaymentsSectionTabs({
  required bool depositsSelected,
  required VoidCallback onInvoiceTap,
  required VoidCallback onDepositsTap,
}) {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F1F5),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        _PaymentsSectionTab(
          label: 'Invoice',
          selected: !depositsSelected,
          onTap: depositsSelected ? onInvoiceTap : null,
        ),
        _PaymentsSectionTab(
          label: 'Deposits',
          selected: depositsSelected,
          onTap: depositsSelected ? null : onDepositsTap,
        ),
      ],
    ),
  );
}

class _PaymentsSectionTab extends StatelessWidget {
  const _PaymentsSectionTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: Material(
          color: selected ? const Color(0xFF071957) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

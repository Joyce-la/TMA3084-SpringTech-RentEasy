import 'package:material_ui/material_ui.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.plate,
    required this.name,
    required this.type,
    required this.services,
    required this.statusLabel,
    this.taxExpiryDays,
    this.onTap,
  });

  final String plate;
  final String name;
  final String type;
  final int services;
  final String statusLabel;
  final int? taxExpiryDays;
  final VoidCallback? onTap;

  static const Color cardGrey = Color(0xFFE4E4E8);
  static const Color linkBlue = Color(0xFF0D3BFF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardGrey,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.directions_car,
                size: 36,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: linkBlue,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _Pill(
                            text: statusLabel,
                            fontSize: 11,
                            horizontal: 10,
                            vertical: 3,
                          ),
                          if (taxExpiryDays != null) ...[
                            const SizedBox(height: 4),
                            _Pill(
                              text: 'Tax Exp in $taxExpiryDays days',
                              fontSize: 9,
                              horizontal: 6,
                              vertical: 2,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Info(label: 'Type', value: type),
                        ),
                        Expanded(
                          child: _Info(
                            label: 'Services',
                            value: '$services Recorded',
                            valueColor: linkBlue,
                          ),
                        ),
                      ],
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
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.fontSize,
    required this.horizontal,
    required this.vertical,
  });

  final String text;
  final double fontSize;
  final double horizontal;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: fontSize)),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.label,
    required this.value,
    this.valueColor = Colors.black,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black87),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

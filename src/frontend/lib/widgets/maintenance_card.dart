import 'package:material_ui/material_ui.dart';

import 'maintenance_status_badge.dart';

class MaintenanceCard extends StatelessWidget {
  const MaintenanceCard({
    super.key,
    required this.serviceName,
    required this.plateNumber,
    required this.vehicleName,
    required this.dateLabel,
    required this.status,
    this.actionLabel = 'Mark as done',
    this.onTap,
    this.onMarkDone,
  });

  final String serviceName;
  final String plateNumber;
  final String vehicleName;
  final String dateLabel;
  final String status;
  final String actionLabel;
  final VoidCallback? onTap;
  final VoidCallback? onMarkDone;

  Color get _statusColor => switch (status) {
    'Overdue' => const Color(0xFFC94F4F),
    'Scheduled' => const Color(0xFFD88935),
    'In Progress' => const Color(0xFF4B83B9),
    'Done' => const Color(0xFF419766),
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final overdue = status == 'Overdue';
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE7E8EC)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              serviceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          MaintenanceStatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$plateNumber · $vehicleName',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: overdue ? _statusColor : Colors.black87,
                          fontWeight: overdue ? FontWeight.w600 : null,
                        ),
                      ),
                      if (onMarkDone != null) ...[
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 34,
                          child: FilledButton(
                            onPressed: onMarkDone,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE9EEF7),
                              foregroundColor: const Color(0xFF071957),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              visualDensity: VisualDensity.compact,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              actionLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:src/providers/maintenance_provider.dart';
import 'package:src/models/maintenance_record.dart';
import 'package:src/screens/maintenance/maintenance_details_screen.dart';
import 'package:src/screens/maintenance/maintenance_form_screen.dart';
import 'package:src/widgets/maintenance_card.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  static const _statuses = ['Overdue', 'Scheduled', 'In Progress', 'Done'];

  @override
  Widget build(BuildContext context) {
    final maintenance = context.watch<MaintenanceProvider>();
    final records = maintenance.visibleRecords;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
          child: SizedBox(
            height: 48,
            child: TextField(
              key: const Key('maintenance-search'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              onChanged: maintenance.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search service, plate or model',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF1F1F5),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip(maintenance, 'All'),
                ..._statuses.map((status) => _filterChip(maintenance, status)),
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: records.isEmpty
                    ? Center(
                        child: Text(
                          'No maintenance records found.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        // Leave room for the floating Add button so the final
                        // card can scroll completely above it.
                        padding: const EdgeInsets.fromLTRB(24, 14, 24, 96),
                        itemCount: records.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final record = records[index];
                          final status = maintenance.statusFor(record);
                          final vehicle = maintenance.vehicleFor(
                            record.vehicleId,
                          );
                          return MaintenanceCard(
                            key: ValueKey(record.maintenanceId),
                            serviceName: record.serviceType,
                            plateNumber:
                                vehicle?.plateNumber ?? 'Unknown vehicle',
                            vehicleName: vehicle?.name ?? '',
                            dateLabel: _dateLabel(record, status),
                            status: status,
                            actionLabel: record.category.isCompliance
                                ? 'Mark as renewed'
                                : 'Mark as done',
                            onTap: () => Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MaintenanceDetailsScreen(
                                  maintenanceId: record.maintenanceId,
                                ),
                              ),
                            ),
                            onMarkDone: maintenance.canMarkAsDone(record)
                                ? () => maintenance.markAsDone(
                                    record.maintenanceId,
                                  )
                                : null,
                          );
                        },
                      ),
              ),
              Positioned(right: 24, bottom: 14, child: _addButton(context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addButton(BuildContext context) => FilledButton.icon(
    onPressed: () => Navigator.push<MaintenanceRecord>(
      context,
      MaterialPageRoute(builder: (_) => const MaintenanceFormScreen()),
    ),
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF071957),
      foregroundColor: Colors.white,
      minimumSize: const Size(48, 48),
      shape: const StadiumBorder(),
    ),
    icon: const Icon(Icons.add),
    label: const Text(
      'Add',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  Widget _filterChip(MaintenanceProvider provider, String label) {
    final selected = provider.selectedStatus == label;
    final count = provider.countFor(label);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => provider.setSelectedStatus(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF071957) : const Color(0xFFEDEDF2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected ? Colors.white24 : const Color(0xFFD0D2DC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateLabel(MaintenanceRecord record, String status) {
    final startDays = _daysFromToday(record.startDate);
    final endDays = _daysFromToday(record.endDate);
    if (record.category.isCompliance) {
      return switch (status) {
        'Done' =>
          'Renewed ${_formatDate(record.completedDate ?? record.endDate)}',
        'Overdue' => 'Expired ${_formatDate(record.endDate)}',
        _ => 'Expires ${_formatDate(record.endDate)} - in $endDays days',
      };
    }
    return switch (status) {
      'Done' =>
        'Completed ${_formatDate(record.completedDate ?? record.endDate)}',
      'Overdue' =>
        'Was due ${_formatDate(record.endDate)} - ${-endDays} days late',
      'Scheduled' =>
        'Due ${_formatDate(record.startDate)} - in $startDays days',
      _ => 'Started ${_formatDate(record.startDate)}',
    };
  }

  int _daysFromToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(date.year, date.month, date.day).difference(today).inDays;
  }

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
    return '${date.day} ${months[date.month - 1]}';
  }
}

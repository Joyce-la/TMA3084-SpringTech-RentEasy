import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:src/models/maintenance_record.dart';
import 'package:src/providers/maintenance_provider.dart';
import 'package:src/screens/maintenance/maintenance_form_screen.dart';
import 'package:src/screens/maintenance/maintenance_page_header.dart';
import 'package:src/widgets/maintenance_status_badge.dart';

class MaintenanceDetailsScreen extends StatelessWidget {
  const MaintenanceDetailsScreen({super.key, required this.maintenanceId});

  final int maintenanceId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MaintenanceProvider>();
    final record = provider.records.firstWhere(
      (item) => item.maintenanceId == maintenanceId,
    );
    final vehicle = provider.vehicleFor(record.vehicleId);
    final status = provider.statusFor(record);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const MaintenancePageHeader(title: 'Maintenance Details'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.serviceType,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      MaintenanceStatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _detail('Category', record.category.label),
                  _detail(
                    'Vehicle',
                    '${vehicle?.plateNumber ?? 'Unknown'} · ${vehicle?.name ?? ''}',
                  ),
                  _detail(
                    record.category.isCompliance
                        ? 'Effective date'
                        : 'Start date',
                    _formatDate(record.startDate),
                  ),
                  _detail(
                    record.category.isCompliance
                        ? 'Expiry date'
                        : 'Expected finish date',
                    _formatDate(record.endDate),
                  ),
                  if (status == 'Done' && record.completedDate != null)
                    _detail(
                      record.category.isCompliance
                          ? 'Renewed date'
                          : 'Completed date',
                      _formatDate(record.completedDate!),
                    ),
                  _detail(
                    record.category.isCompliance
                        ? 'Insurer / provider'
                        : 'Workshop',
                    record.workshop,
                  ),
                  _detail('Cost', 'RM ${record.cost.toStringAsFixed(2)}'),
                  _detail('Description', record.description),
                  const SizedBox(height: 24),
                  if (provider.canMarkAsDone(record))
                    FilledButton(
                      key: const Key('details-mark-done'),
                      onPressed: () {
                        provider.markAsDone(record.maintenanceId);
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF071957),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                        record.category.isCompliance
                            ? 'Mark as renewed'
                            : 'Mark as done',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (status == 'Done')
                    OutlinedButton(
                      key: const Key('details-reopen'),
                      onPressed: () =>
                          provider.reopenMaintenance(record.maintenanceId),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Reopen'),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.push<MaintenanceRecord>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MaintenanceFormScreen(record: record),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _confirmDelete(
                      context,
                      provider,
                      record,
                      vehicle?.plateNumber ?? 'Unknown vehicle',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB3261E),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666870),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );

  Future<void> _confirmDelete(
    BuildContext context,
    MaintenanceProvider provider,
    MaintenanceRecord record,
    String plateNumber,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFB3261E),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Delete this maintenance record?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        content: Text(
          '${record.serviceType} ($plateNumber) will be permanently deleted. '
          'This can\'t be undone.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: const Color(0xFF3C3D42), height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(96, 44),
                  foregroundColor: const Color(0xFF3F4148),
                  side: const BorderSide(color: Color(0xFF85878F)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB3261E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(96, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final detailsRoute = ModalRoute.of(context);
      Navigator.pop(context);
      // Wait until the details route is removed before notifying listeners.
      // Otherwise this screen can rebuild during its pop transition after its
      // record has been deleted and fail while looking up that record.
      await detailsRoute?.completed;
      provider.removeMaintenance(maintenanceId);
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

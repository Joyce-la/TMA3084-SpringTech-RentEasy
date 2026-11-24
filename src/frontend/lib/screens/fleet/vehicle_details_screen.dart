import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:src/providers/fleet_provider.dart';
import 'package:src/widgets/app_top_bar.dart';

import 'edit_vehicle_screen.dart';

import '../../mock_data/vehicles.dart';

class VehicleDetailsScreen extends StatelessWidget {
  const VehicleDetailsScreen({super.key, required this.vehicle});

  final VehicleData vehicle;

  static const Color navyBlue = Color(0xFF071957);
  static const Color sectionGrey = Color(0xFFF1F1F5);
  static const Color maintenanceGrey = Color(0xFFE4E4E8);

  @override
  Widget build(BuildContext context) {
    final current = context.watch<FleetProvider>().vehicles.firstWhere(
      (v) => v.plateNumber == vehicle.plateNumber,
      orElse: () => vehicle,
    );
    final (make, model) = _splitName(current.name);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.chevron_left, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(child: AppTopBar(title: current.plateNumber)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    _section('Vehicle Info', [
                      _row('Plate Number', current.plateNumber),
                      _row('Vehicle Type', current.type),
                      _row('Make', make),
                      _row('Model', model),
                      _row('Status', _statusText(current.status)),
                    ]),
                    const SizedBox(height: 16),
                    _section('Insurance and Road Tax', [
                      _row(
                        'Insurance Policy No.',
                        current.insuranceNumber.isEmpty
                            ? '-'
                            : current.insuranceNumber,
                      ),
                      _row(
                        'Insurance Expiry',
                        _formatDate(current.insuranceExpiry),
                      ),
                      _row(
                        'Road Tax Expiry',
                        _formatDate(current.roadTaxExpiry),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildButtons(context, current),
                    const SizedBox(height: 16),
                    _buildMaintenance(current),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, VehicleData current) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9D9DD),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _edit(context, current),
              child: const Text(
                'Edit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _confirmRemove(context, current),
              child: const Text(
                'Remove',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _edit(BuildContext context, VehicleData current) async {
    final updated = await Navigator.push<VehicleData>(
      context,
      MaterialPageRoute(builder: (_) => EditVehicleScreen(vehicle: current)),
    );
    if (updated == null || !context.mounted) return;

    context.read<FleetProvider>().updateVehicle(updated);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${updated.plateNumber} updated.')));
  }

  Future<void> _confirmRemove(BuildContext context, VehicleData current) async {
    if (current.status == VehicleStatus.rented) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A rented vehicle cannot be removed.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove vehicle?'),
        content: Text('${current.plateNumber} will be removed from the fleet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    context.read<FleetProvider>().removeVehicle(current.plateNumber);
    Navigator.pop(context);
  }

  Widget _buildMaintenance(VehicleData current) {
    final records = current.maintenanceRecords;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: maintenanceGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service & Component Maintenance',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            Text(
              'No service records yet.',
              style: TextStyle(color: Colors.grey.shade700),
            )
          else
            for (var i = 0; i < records.length; i++) ...[
              if (i > 0) const Divider(height: 24),
              _maintenanceItem(records[i]),
            ],
        ],
      ),
    );
  }

  Widget _maintenanceItem(MaintenanceData record) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.serviceType,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${record.startDate} · ${record.workshop}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        Text(
          'RM ${record.cost.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sectionGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static (String, String) _splitName(String name) {
    final trimmed = name.trim();
    final index = trimmed.indexOf(' ');
    if (index == -1) return (trimmed, '-');
    return (trimmed.substring(0, index), trimmed.substring(index + 1));
  }

  static String _statusText(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return 'Available';
      case VehicleStatus.rented:
        return 'Rented';
      case VehicleStatus.maintenance:
        return 'Maintenance';
      case VehicleStatus.unavailable:
        return 'Unavailable';
    }
  }

  static String _formatDate(DateTime date) {
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
}

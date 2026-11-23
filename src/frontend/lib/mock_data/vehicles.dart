import '../models/vehicle.dart';
import 'database_records.dart';

export '../models/vehicle.dart';

final mockVehicles = List<VehicleData>.unmodifiable(
  mockDatabase['Vehicle']!.map(_vehicleFromRecord),
);

VehicleData _vehicleFromRecord(Map<String, Object?> vehicle) {
  final maintenance = mockDatabase['Maintenance']!
      .where((record) => record['vehicleId'] == vehicle['vehicleId'])
      .map(_maintenanceFromRecord)
      .toList();

  return VehicleData(
    plateNumber: _string(vehicle, 'plateNo'),
    name: _string(vehicle, 'model'),
    type: _string(vehicle, 'category'),
    status: switch (_string(vehicle, 'status')) {
      'available' => VehicleStatus.available,
      'rented' => VehicleStatus.rented,
      'maintenance' => VehicleStatus.maintenance,
      'unavailable' => VehicleStatus.unavailable,
      final status => throw StateError('Unknown vehicle status: $status'),
    },
    insuranceNumber: _string(vehicle, 'insuranceNo'),
    insuranceCompany: _string(vehicle, 'insuranceCompany'),
    insuranceExpiry: DateTime.parse(_string(vehicle, 'insuranceExpiryDate')),
    roadTaxExpiry: DateTime.parse(_string(vehicle, 'roadTaxExpiryDate')),
    maintenanceRecords: List.unmodifiable(maintenance),
  );
}

MaintenanceData _maintenanceFromRecord(Map<String, Object?> record) {
  final endDate = record['endDate'];
  return MaintenanceData(
    serviceType: _string(record, 'serviceType'),
    startDate: _displayDate(DateTime.parse(_string(record, 'startDate'))),
    endDate: endDate == null
        ? null
        : _displayDate(DateTime.parse(endDate as String)),
    cost: _number(record, 'cost'),
    description: _string(record, 'description'),
    workshop: _string(record, 'workshop'),
    status: switch (_string(record, 'serviceStatus')) {
      'scheduled' => MaintenanceStatus.scheduled,
      'inProgress' => MaintenanceStatus.inProgress,
      'completed' => MaintenanceStatus.completed,
      final status => throw StateError('Unknown service status: $status'),
    },
  );
}

String _string(Map<String, Object?> record, String field) =>
    record[field] as String;

double _number(Map<String, Object?> record, String field) =>
    (record[field] as num).toDouble();

String _displayDate(DateTime date) {
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

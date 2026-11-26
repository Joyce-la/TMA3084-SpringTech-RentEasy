import '../models/maintenance_record.dart';
import 'database_records.dart';

final mockMaintenanceRecords = List<MaintenanceRecord>.unmodifiable(
  (mockDatabase['Maintenance'] ?? const <Map<String, Object?>>[]).map(
    _maintenanceFromRecord,
  ),
);

MaintenanceRecord _maintenanceFromRecord(Map<String, Object?> record) {
  final startDate = DateTime.parse(_string(record, 'startDate'));
  final endDate = record['endDate'];
  final completedDate = record['completedDate'];
  return MaintenanceRecord(
    maintenanceId: _integer(record, 'maintenanceId'),
    vehicleId: _integer(record, 'vehicleId'),
    category: _category(record),
    serviceType: _string(record, 'serviceType'),
    startDate: startDate,
    endDate: endDate == null ? startDate : DateTime.parse(endDate as String),
    completedDate: completedDate == null
        ? null
        : DateTime.parse(completedDate as String),
    cost: _number(record, 'cost'),
    description: _string(record, 'description'),
    workshop: _string(record, 'workshop'),
    // Upcoming and overdue are derived from dates by MaintenanceProvider.
    status: switch (_string(record, 'serviceStatus')) {
      'scheduled' ||
      'upcoming' ||
      'overdue' => MaintenanceRecordStatus.scheduled,
      'inProgress' => MaintenanceRecordStatus.inProgress,
      'done' || 'completed' => MaintenanceRecordStatus.completed,
      final status => throw StateError('Unknown service status: $status'),
    },
  );
}

MaintenanceCategory _category(Map<String, Object?> record) {
  final category = record['serviceCategory'];
  if (category == null) {
    return switch (_string(record, 'serviceStatus')) {
      'insurance' => MaintenanceCategory.insurance,
      'roadTax' => MaintenanceCategory.roadTax,
      _ => MaintenanceCategory.repair,
    };
  }
  return switch (category) {
    'repair' => MaintenanceCategory.repair,
    'preventiveUpkeep' => MaintenanceCategory.preventiveUpkeep,
    'insurance' => MaintenanceCategory.insurance,
    'roadTax' => MaintenanceCategory.roadTax,
    final value => throw StateError('Unknown maintenance category: $value'),
  };
}

int _integer(Map<String, Object?> record, String field) => record[field] as int;

String _string(Map<String, Object?> record, String field) =>
    record[field] as String;

double _number(Map<String, Object?> record, String field) =>
    (record[field] as num).toDouble();

import '../models/vehicle.dart';
import 'database_records.dart';

const assistantGreeting =
    'Hello! I am your SpringTech Operational AI Assistant. Ask me anything '
    'about vehicle availability, overdue payments, customer bookings, or '
    'vehicle maintenance histories.';

/// Mock replacement for a real AI call. Swap this for an API request later.
String buildAssistantReply(String question, List<VehicleData> vehicles) {
  final text = question.toLowerCase();
  final compact = text.replaceAll(' ', '');

  VehicleData? mentioned;
  for (final v in vehicles) {
    if (compact.contains(v.plateNumber.toLowerCase().replaceAll(' ', ''))) {
      mentioned = v;
      break;
    }
  }

  if (mentioned != null &&
      (text.contains('history') || text.contains('maintenance'))) {
    return _maintenanceReply(mentioned);
  }
  if (text.contains('overdue')) return _overdueReply();
  if (text.contains('available')) return _availableReply(vehicles);
  if (mentioned != null) {
    return '${mentioned.plateNumber} - ${mentioned.name} is currently '
        '${mentioned.status.name}. Ask for its "history" to see maintenance '
        'records.';
  }
  return 'Sorry, I can only answer questions about available vehicles, '
      'overdue rentals and vehicle maintenance history for now.';
}

String _availableReply(List<VehicleData> vehicles) {
  final available = vehicles
      .where((v) => v.status == VehicleStatus.available)
      .toList();
  if (available.isEmpty) return 'No vehicles are available right now.';

  final lines = [
    for (var i = 0; i < available.length; i++)
      '${i + 1}. ${available[i].plateNumber} - ${available[i].name}',
  ];
  return 'These vehicles are available today (I cannot check future dates '
      'yet):\n${lines.join('\n')}';
}

String _overdueReply() {
  final now = DateTime.now();
  final overdue = mockDatabase['Rental']!.where((rental) {
    if (rental['status'] != 'ongoing') return false;
    return DateTime.parse(rental['returnDateTime'] as String).isBefore(now);
  }).toList();

  if (overdue.isEmpty) return 'There are no overdue rentals.';

  final lines = <String>[];
  for (var i = 0; i < overdue.length; i++) {
    final rental = overdue[i];
    final vehicle = mockDatabase['Vehicle']!.firstWhere(
      (v) => v['vehicleId'] == rental['vehicleId'],
    );
    final user = mockDatabase['User']!.firstWhere(
      (u) => u['userId'] == rental['userId'],
    );
    final due = DateTime.parse(rental['returnDateTime'] as String);
    lines.add(
      '${i + 1}. ${vehicle['plateNo']} - ${user['name']} '
      '(due ${due.day}/${due.month}/${due.year})',
    );
  }
  return 'Overdue rentals:\n${lines.join('\n')}';
}

String _maintenanceReply(VehicleData vehicle) {
  final records = vehicle.maintenanceRecords;
  if (records.isEmpty) {
    return '${vehicle.plateNumber} has no maintenance records yet.';
  }
  final lines = [
    for (var i = 0; i < records.length; i++)
      '${i + 1}. ${records[i].serviceType} - ${records[i].startDate} - '
          'RM ${records[i].cost.toStringAsFixed(2)} (${records[i].workshop})',
  ];
  return 'Maintenance history for ${vehicle.plateNumber} '
      '(${vehicle.name}):\n${lines.join('\n')}';
}

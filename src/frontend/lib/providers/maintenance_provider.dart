import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../mock_data/database_records.dart';
import '../mock_data/maintenance_records.dart';
import '../mock_data/vehicles.dart';
import '../models/maintenance_record.dart';

class MaintenanceProvider extends ChangeNotifier {
  MaintenanceProvider({
    List<MaintenanceRecord>? initialRecords,
    List<VehicleData>? initialVehicles,
  }) : _records = List<MaintenanceRecord>.from(
         initialRecords ?? mockMaintenanceRecords,
       ),
       _vehicles = List<VehicleData>.from(initialVehicles ?? mockVehicles);

  final List<MaintenanceRecord> _records;
  final List<VehicleData> _vehicles;
  String _searchQuery = '';
  String _selectedStatus = 'All';

  List<MaintenanceRecord> get records =>
      UnmodifiableListView<MaintenanceRecord>(_records);
  List<VehicleData> get vehicles =>
      UnmodifiableListView<VehicleData>(_vehicles);
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  int get nextMaintenanceId => _records.isEmpty
      ? 1
      : _records
                .map((record) => record.maintenanceId)
                .reduce((a, b) => a > b ? a : b) +
            1;

  List<MaintenanceRecord> get visibleRecords {
    final query = _searchQuery.trim().toLowerCase();
    final records = _records.where((record) {
      final statusMatches =
          _selectedStatus == 'All' || statusFor(record) == _selectedStatus;
      final vehicle = vehicleFor(record.vehicleId);
      final searchable =
          '${record.serviceType} ${vehicle?.plateNumber ?? ''} '
                  '${vehicle?.name ?? ''}'
              .toLowerCase();
      return statusMatches && (query.isEmpty || searchable.contains(query));
    }).toList();
    records.sort((first, second) {
      final priority =
          _priority(statusFor(first)) - _priority(statusFor(second));
      if (priority != 0) return priority;
      return first.startDate.compareTo(second.startDate);
    });
    return records;
  }

  int _priority(String status) => switch (status) {
    'Overdue' => 0,
    'In Progress' => 1,
    'Scheduled' => 2,
    'Done' => 3,
    _ => 4,
  };

  VehicleData? vehicleFor(int vehicleId) {
    final vehicleRows = mockDatabase['Vehicle'] ?? const [];
    final row = vehicleRows.cast<Map<String, Object?>>().firstWhere(
      (record) => record['vehicleId'] == vehicleId,
      orElse: () => const <String, Object?>{},
    );
    final plateNumber = row['plateNo'];
    if (plateNumber is String) {
      for (final vehicle in _vehicles) {
        if (vehicle.plateNumber == plateNumber) return vehicle;
      }
    }
    final fallbackIndex = vehicleId - 1;
    return fallbackIndex >= 0 && fallbackIndex < _vehicles.length
        ? _vehicles[fallbackIndex]
        : null;
  }

  int? vehicleIdFor(VehicleData vehicle) {
    final vehicleRows = mockDatabase['Vehicle'] ?? const [];
    for (final row in vehicleRows.cast<Map<String, Object?>>()) {
      if (row['plateNo'] == vehicle.plateNumber) {
        final id = row['vehicleId'];
        return id is int ? id : null;
      }
    }
    final fallbackIndex = _vehicles.indexWhere(
      (candidate) => candidate.plateNumber == vehicle.plateNumber,
    );
    return fallbackIndex == -1 ? null : fallbackIndex + 1;
  }

  String statusFor(MaintenanceRecord record, {DateTime? now}) {
    if (record.status == MaintenanceRecordStatus.completed) return 'Done';

    final today = _dateOnly(now ?? DateTime.now());
    final start = _dateOnly(record.startDate);
    final end = _dateOnly(record.endDate);
    if (today.isAfter(end)) return 'Overdue';
    if (record.category.isCompliance) return 'Scheduled';
    if (today.isBefore(start)) return 'Scheduled';
    return 'In Progress';
  }

  bool canMarkAsDone(MaintenanceRecord record, {DateTime? now}) {
    if (record.status == MaintenanceRecordStatus.completed) return false;
    final today = _dateOnly(now ?? DateTime.now());
    if (record.category.isCompliance) {
      final renewalWindowStart = _dateOnly(
        record.endDate.subtract(const Duration(days: 30)),
      );
      return !today.isBefore(renewalWindowStart);
    }
    final status = statusFor(record, now: now);
    return status == 'In Progress' || status == 'Overdue';
  }

  int countFor(String status) {
    if (status == 'All') return _records.length;
    return _records.where((record) => statusFor(record) == status).length;
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void setSelectedStatus(String value) {
    if (_selectedStatus == value) return;
    _selectedStatus = value;
    notifyListeners();
  }

  bool addMaintenance(MaintenanceRecord record) {
    if (_records.any((item) => item.maintenanceId == record.maintenanceId)) {
      return false;
    }
    _records.add(record);
    notifyListeners();
    return true;
  }

  bool updateMaintenance(MaintenanceRecord record) {
    final index = _records.indexWhere(
      (item) => item.maintenanceId == record.maintenanceId,
    );
    if (index == -1) return false;
    _records[index] = record;
    notifyListeners();
    return true;
  }

  bool markAsDone(int maintenanceId, {DateTime? completedDate}) {
    final index = _records.indexWhere(
      (record) => record.maintenanceId == maintenanceId,
    );
    if (index == -1 || !canMarkAsDone(_records[index])) return false;
    _records[index] = _records[index].copyWith(
      status: MaintenanceRecordStatus.completed,
      completedDate: _dateOnly(completedDate ?? DateTime.now()),
    );
    notifyListeners();
    return true;
  }

  bool reopenMaintenance(int maintenanceId) {
    final index = _records.indexWhere(
      (record) => record.maintenanceId == maintenanceId,
    );
    if (index == -1 ||
        _records[index].status != MaintenanceRecordStatus.completed) {
      return false;
    }
    _records[index] = _records[index].copyWith(
      status: MaintenanceRecordStatus.scheduled,
      clearCompletedDate: true,
    );
    notifyListeners();
    return true;
  }

  bool removeMaintenance(int maintenanceId) {
    final exists = _records.any(
      (record) => record.maintenanceId == maintenanceId,
    );
    if (!exists) return false;
    _records.removeWhere((record) => record.maintenanceId == maintenanceId);
    notifyListeners();
    return true;
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

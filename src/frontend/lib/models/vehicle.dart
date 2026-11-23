enum VehicleStatus { available, rented, maintenance, unavailable }

class VehicleData {
  const VehicleData({
    required this.plateNumber,
    required this.name,
    required this.type,
    required this.status,
    required this.insuranceNumber,
    required this.insuranceCompany,
    required this.insuranceExpiry,
    required this.roadTaxExpiry,
    required this.maintenanceRecords,
  });

  final String plateNumber;
  final String name;
  final String type;
  final VehicleStatus status;
  final String insuranceNumber;
  final String insuranceCompany;
  final DateTime insuranceExpiry;
  final DateTime roadTaxExpiry;
  final List<MaintenanceData> maintenanceRecords;

  int get services => maintenanceRecords.length;

  /// Days until road tax expires; null when more than 30 days away.
  int? get taxExpiryDays {
    final now = DateTime.now();
    final days = roadTaxExpiry
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    return days <= 30 ? days : null;
  }
}

enum MaintenanceStatus { scheduled, inProgress, completed }

class MaintenanceData {
  const MaintenanceData({
    required this.serviceType,
    required this.startDate,
    required this.endDate,
    required this.cost,
    required this.description,
    required this.workshop,
    required this.status,
  });

  final String serviceType;
  final String startDate;
  final String? endDate;
  final double cost;
  final String description;
  final String workshop;
  final MaintenanceStatus status;
}

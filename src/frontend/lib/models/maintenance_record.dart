enum MaintenanceRecordStatus { scheduled, inProgress, completed }

enum MaintenanceCategory {
  repair,
  preventiveUpkeep,
  insurance,
  roadTax;

  bool get isCompliance =>
      this == MaintenanceCategory.insurance ||
      this == MaintenanceCategory.roadTax;

  String get label => switch (this) {
    MaintenanceCategory.repair => 'Repair',
    MaintenanceCategory.preventiveUpkeep => 'Preventive upkeep',
    MaintenanceCategory.insurance => 'Insurance',
    MaintenanceCategory.roadTax => 'Road tax',
  };

  String get guidance => switch (this) {
    MaintenanceCategory.repair => 'For fixing a fault or damage, such as brakes, tires, engine, or air conditioning.',
    MaintenanceCategory.preventiveUpkeep => 'For routine work that helps prevent faults, such as oil changes, inspections, or tire rotation.',
    MaintenanceCategory.insurance => 'For insurance policy renewals. Use the end date as the policy expiry date.',
    MaintenanceCategory.roadTax =>
      'For road tax renewals. Use the end date as the road tax expiry date.',
  };
}

class MaintenanceRecord {
  const MaintenanceRecord({
    required this.maintenanceId,
    required this.vehicleId,
    required this.category,
    required this.serviceType,
    required this.startDate,
    required this.endDate,
    required this.completedDate,
    required this.cost,
    required this.description,
    required this.workshop,
    required this.status,
  });

  final int maintenanceId;
  final int vehicleId;
  final MaintenanceCategory category;
  final String serviceType;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? completedDate;
  final double cost;
  final String description;
  final String workshop;
  final MaintenanceRecordStatus status;

  MaintenanceRecord copyWith({
    int? maintenanceId,
    int? vehicleId,
    MaintenanceCategory? category,
    String? serviceType,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? completedDate,
    bool clearCompletedDate = false,
    double? cost,
    String? description,
    String? workshop,
    MaintenanceRecordStatus? status,
  }) => MaintenanceRecord(
    maintenanceId: maintenanceId ?? this.maintenanceId,
    vehicleId: vehicleId ?? this.vehicleId,
    category: category ?? this.category,
    serviceType: serviceType ?? this.serviceType,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    completedDate: clearCompletedDate
        ? null
        : completedDate ?? this.completedDate,
    cost: cost ?? this.cost,
    description: description ?? this.description,
    workshop: workshop ?? this.workshop,
    status: status ?? this.status,
  );
}

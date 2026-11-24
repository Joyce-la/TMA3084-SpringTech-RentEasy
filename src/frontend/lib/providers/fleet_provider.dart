import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../mock_data/vehicles.dart';

class FleetProvider extends ChangeNotifier {
  FleetProvider({List<VehicleData>? initialVehicles})
    : _vehicles = List<VehicleData>.from(initialVehicles ?? mockVehicles);

  final List<VehicleData> _vehicles;
  String _searchQuery = '';
  VehicleStatus? _selectedStatus;

  List<VehicleData> get vehicles =>
      UnmodifiableListView<VehicleData>(_vehicles);
  String get searchQuery => _searchQuery;
  VehicleStatus? get selectedStatus => _selectedStatus;

  List<VehicleData> get visibleVehicles {
    final query = _searchQuery.trim().toLowerCase();
    return _vehicles.where((vehicle) {
      final matchesStatus =
          _selectedStatus == null || vehicle.status == _selectedStatus;
      final matchesSearch =
          query.isEmpty ||
          vehicle.plateNumber.toLowerCase().contains(query) ||
          vehicle.name.toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void setSelectedStatus(VehicleStatus? status) {
    if (_selectedStatus == status) return;
    _selectedStatus = status;
    notifyListeners();
  }

  int countFor(VehicleStatus? status) {
    if (status == null) return _vehicles.length;
    return _vehicles.where((vehicle) => vehicle.status == status).length;
  }

  void addVehicle(VehicleData vehicle) {
    if (hasPlate(vehicle.plateNumber)) return;
    _vehicles.add(vehicle);
    notifyListeners();
  }

  void updateVehicle(VehicleData vehicle) {
    final index = _vehicles.indexWhere(
      (item) => item.plateNumber == vehicle.plateNumber,
    );
    if (index == -1) return;
    if (identical(_vehicles[index], vehicle)) return;
    _vehicles[index] = vehicle;
    notifyListeners();
  }

  void removeVehicle(String plateNumber) {
    final exists = _vehicles.any(
      (vehicle) => vehicle.plateNumber == plateNumber,
    );
    if (!exists) return;
    _vehicles.removeWhere((vehicle) => vehicle.plateNumber == plateNumber);
    notifyListeners();
  }

  bool hasPlate(String plateNumber, {String? except}) {
    final plate = _normalize(plateNumber);
    return _vehicles.any(
      (v) =>
          _normalize(v.plateNumber) == plate &&
          _normalize(v.plateNumber) != _normalize(except ?? ''),
    );
  }

  static String _normalize(String plate) =>
      plate.replaceAll(' ', '').toUpperCase();
}

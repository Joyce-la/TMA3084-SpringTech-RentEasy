import 'package:material_ui/material_ui.dart';
import 'package:src/widgets/app_top_bar.dart';
import 'package:src/widgets/vehicle_card.dart';

import 'add_vehicle_screen.dart';

enum VehicleStatus { available, rented, maintenance, unavailable }

class Vehicle {
  final String plate;
  final String name;
  final String type;
  final int services;
  final VehicleStatus status;
  final int? taxExpiryDays;

  const Vehicle({
    required this.plate,
    required this.name,
    required this.type,
    required this.services,
    required this.status,
    this.taxExpiryDays,
  });
}

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  static const Color navyBlue = Color(0xFF071957);

  String searchQuery = '';
  VehicleStatus? selectedFilter;

  // Sample fleet data (prototype only)
  final List<Vehicle> vehicles = [
    Vehicle(
      plate: 'QAA 1234',
      name: 'Toyota Vios 2022',
      type: 'Sedan',
      services: 3,
      status: VehicleStatus.available,
    ),
    Vehicle(
      plate: 'QAB 4567',
      name: 'Honda City 2021',
      type: 'Sedan',
      services: 5,
      status: VehicleStatus.rented,
      taxExpiryDays: 18,
    ),
    Vehicle(
      plate: 'QAA 7890',
      name: 'Perodua Axia 2023',
      type: 'Hatchback',
      services: 10,
      status: VehicleStatus.available,
    ),
    Vehicle(
      plate: 'QAA 5580',
      name: 'Toyota Vios 2022',
      type: 'Sedan',
      services: 7,
      status: VehicleStatus.maintenance,
    ),
  ];

  List<Vehicle> get filteredVehicles {
    final query = searchQuery.trim().toLowerCase();

    return vehicles.where((v) {
      final matchesFilter =
          selectedFilter == null || v.status == selectedFilter;
      final matchesSearch =
          query.isEmpty ||
          v.plate.toLowerCase().contains(query) ||
          v.name.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  int countFor(VehicleStatus? status) {
    if (status == null) return vehicles.length;
    return vehicles.where((v) => v.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    final list = filteredVehicles;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopBar(title: 'Fleet'),

              const SizedBox(height: 12),

              buildSearchBar(),

              const SizedBox(height: 12),

              buildFilterChips(),

              const SizedBox(height: 14),

              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          'No vehicles found.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final v = list[index];
                          return VehicleCard(
                            plate: v.plate,
                            name: v.name,
                            type: v.type,
                            services: v.services,
                            statusLabel: statusLabel(v.status),
                            taxExpiryDays: v.taxExpiryDays,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${v.plate} details will be developed next.',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: navyBlue,
        foregroundColor: Colors.white,
        onPressed: () async {
          final newVehicle = await Navigator.push<Vehicle>(
            context,
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );

          if (newVehicle != null) {
            setState(() => vehicles.add(newVehicle));

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${newVehicle.plate} added to fleet.')),
            );
          }
        },
        icon: const Icon(Icons.add, size: 26),
        label: const Text(
          'Add',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search plate, make or model',
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
        filled: true,
        fillColor: const Color(0xFFF1F1F5),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          buildChip('All', null),
          buildChip('Available', VehicleStatus.available),
          buildChip('Maintenance', VehicleStatus.maintenance),
          buildChip('Rented', VehicleStatus.rented),
          buildChip('Unavailable', VehicleStatus.unavailable),
        ],
      ),
    );
  }

  Widget buildChip(String label, VehicleStatus? status) {
    final selected = selectedFilter == status;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = status),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? navyBlue : const Color(0xFFEDEDF2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? Colors.white : Colors.grey.shade700,
                ),
              ),

              const SizedBox(width: 6),

              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected ? Colors.white24 : const Color(0xFFD0D2DC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  countFor(status).toString(),
                  style: TextStyle(
                    fontSize: 11,
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

  String statusLabel(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return 'AVAILABLE';
      case VehicleStatus.rented:
        return 'RENTED';
      case VehicleStatus.maintenance:
        return 'MAINTENANCE';
      case VehicleStatus.unavailable:
        return 'UNAVAILABLE';
    }
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:src/providers/fleet_provider.dart';
import 'package:src/widgets/app_top_bar.dart';
import 'package:src/widgets/vehicle_card.dart';

import '../../mock_data/vehicles.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_details_screen.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  static const Color navyBlue = Color(0xFF071957);

  // Only holds the text box; all other state lives in FleetProvider.
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<FleetProvider>().searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fleet = context.watch<FleetProvider>();
    final list = fleet.visibleVehicles;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopBar(
                title: 'Fleet',
                onAssistantTap: () => AiAssistantScreen.open(context),
              ),

              const SizedBox(height: 12),

              _buildSearchBar(fleet),

              const SizedBox(height: 12),

              _buildFilterChips(fleet),

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
                            plate: v.plateNumber,
                            name: v.name,
                            type: v.type,
                            services: v.services,
                            statusLabel: _statusLabel(v.status),
                            taxExpiryDays: v.taxExpiryDays,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    VehicleDetailsScreen(vehicle: v),
                              ),
                            ),
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
          final newVehicle = await Navigator.push<VehicleData>(
            context,
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );

          if (newVehicle != null) {
            fleet.addVehicle(newVehicle);

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${newVehicle.plateNumber} added to fleet.'),
              ),
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

  Widget _buildSearchBar(FleetProvider fleet) {
    return TextField(
      controller: _searchController,
      onChanged: fleet.setSearchQuery,
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

  Widget _buildFilterChips(FleetProvider fleet) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(fleet, 'All', null),
          _buildChip(fleet, 'Available', VehicleStatus.available),
          _buildChip(fleet, 'Maintenance', VehicleStatus.maintenance),
          _buildChip(fleet, 'Rented', VehicleStatus.rented),
          _buildChip(fleet, 'Unavailable', VehicleStatus.unavailable),
        ],
      ),
    );
  }

  Widget _buildChip(FleetProvider fleet, String label, VehicleStatus? status) {
    final selected = fleet.selectedStatus == status;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => fleet.setSelectedStatus(status),
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
                  fleet.countFor(status).toString(),
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

  String _statusLabel(VehicleStatus status) {
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

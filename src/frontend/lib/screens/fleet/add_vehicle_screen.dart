import 'package:material_ui/material_ui.dart';

import '../../mock_data/vehicles.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  static const Color navyBlue = Color(0xFF071957);
  static const Color sectionGrey = Color(0xFFF1F1F5);
  static const Color fieldGrey = Color(0xFFD9D9D9);
  static const Color borderGrey = Color(0xFFB8B8BD);

  final _formKey = GlobalKey<FormState>();

  final plateController = TextEditingController();
  final makeController = TextEditingController();
  final modelController = TextEditingController();
  final policyController = TextEditingController();
  final insuranceDateController = TextEditingController();
  final roadTaxDateController = TextEditingController();

  final List<String> vehicleTypes = const [
    'Sedan',
    'Hatchback',
    'SUV',
    'MPV',
    'Pickup',
  ];
  String selectedType = 'Sedan';
  VehicleStatus selectedStatus = VehicleStatus.available;

  // Picked dates
  DateTime? insuranceExpiry;
  DateTime? roadTaxExpiry;

  @override
  void dispose() {
    plateController.dispose();
    makeController.dispose();
    modelController.dispose();
    policyController.dispose();
    insuranceDateController.dispose();
    roadTaxDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildVehicleInfoSection(),
                      const SizedBox(height: 20),
                      buildInsuranceSection(),
                    ],
                  ),
                ),
              ),
            ),

            buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const Text(
            'Add New Vehicle',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildVehicleInfoSection() {
    return buildSection(
      title: 'Vehicle Info',
      children: [
        buildTwoColumns(
          buildLabeled(
            'Plate Number *',
            TextFormField(
              controller: plateController,
              textCapitalization: TextCapitalization.characters,
              decoration: fieldDecoration('QAA 1234 X'),
              validator: requiredValidator,
            ),
          ),
          buildLabeled(
            'Vehicle Type *',
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: fieldDecoration(null),
              borderRadius: BorderRadius.circular(12),
              items: vehicleTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => selectedType = value);
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        buildTwoColumns(
          buildLabeled(
            'Make *',
            TextFormField(
              controller: makeController,
              textCapitalization: TextCapitalization.words,
              decoration: fieldDecoration('Proton'),
              validator: requiredValidator,
            ),
          ),
          buildLabeled(
            'Model *',
            TextFormField(
              controller: modelController,
              textCapitalization: TextCapitalization.words,
              decoration: fieldDecoration('X50 Flagship'),
              validator: requiredValidator,
            ),
          ),
        ),

        const SizedBox(height: 12),

        buildLabeled(
          'Status *',
          DropdownButtonFormField<VehicleStatus>(
            initialValue: selectedStatus,
            decoration: fieldDecoration(null),
            borderRadius: BorderRadius.circular(12),
            items: VehicleStatus.values
                .map(
                  (s) => DropdownMenuItem(value: s, child: Text(statusText(s))),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => selectedStatus = value);
            },
          ),
        ),
      ],
    );
  }

  Widget buildInsuranceSection() {
    return buildSection(
      title: 'Insurance and Road Tax',
      children: [
        buildLabeled(
          'Insurance Policy No.',
          TextFormField(
            controller: policyController,
            textCapitalization: TextCapitalization.characters,
            decoration: fieldDecoration('POL-998822'),
          ),
        ),

        const SizedBox(height: 12),

        buildTwoColumns(
          buildLabeled(
            'Insurance Expiry Date *',
            buildDateField(
              controller: insuranceDateController,
              onPicked: (date) => insuranceExpiry = date,
            ),
          ),
          buildLabeled(
            'Road Tax Expiry Date *',
            buildDateField(
              controller: roadTaxDateController,
              onPicked: (date) => roadTaxExpiry = date,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSection({required String title, required List<Widget> children}) {
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
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget buildTwoColumns(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  // Label above a field
  Widget buildLabeled(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget buildDateField({
    required TextEditingController controller,
    required ValueChanged<DateTime> onPicked,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: fieldDecoration('dd/mm/yyyy').copyWith(
        suffixIcon: const Icon(Icons.calendar_month, color: Colors.black87),
      ),
      validator: requiredValidator,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 10),
        );

        if (picked != null) {
          onPicked(picked);
          controller.text = formatDate(picked);
        }
      },
    );
  }

  InputDecoration fieldDecoration(String? hint) {
    OutlineInputBorder border(Color color, [double width = 1.5]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      filled: true,
      fillColor: fieldGrey,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: border(borderGrey),
      enabledBorder: border(borderGrey),
      focusedBorder: border(navyBlue, 2),
      errorBorder: border(Colors.red.shade700),
      focusedErrorBorder: border(Colors.red.shade700, 2),
      errorStyle: const TextStyle(fontSize: 10),
    );
  }

  Widget buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9D9DD),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            flex: 4,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: submit,
                child: const Text(
                  'Add',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = VehicleData(
      plateNumber: plateController.text.trim().toUpperCase(),
      name: '${makeController.text.trim()} ${modelController.text.trim()}',
      type: selectedType,
      status: selectedStatus,
      insuranceNumber: policyController.text.trim(),
      insuranceCompany: '',
      insuranceExpiry: insuranceExpiry!,
      roadTaxExpiry: roadTaxExpiry!,
      maintenanceRecords: const [],
    );

    // Send the new vehicle back to FleetScreen
    Navigator.pop(context, vehicle);
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  String statusText(VehicleStatus status) {
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
}

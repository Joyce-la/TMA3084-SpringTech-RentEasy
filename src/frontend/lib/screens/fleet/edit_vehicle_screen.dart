import 'package:material_ui/material_ui.dart';

import '../../mock_data/vehicles.dart';

class EditVehicleScreen extends StatefulWidget {
  const EditVehicleScreen({super.key, required this.vehicle});

  final VehicleData vehicle;

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  static const Color navyBlue = Color(0xFF071957);
  static const Color sectionGrey = Color(0xFFF1F1F5);
  static const Color fieldGrey = Color(0xFFD9D9D9);
  static const Color borderGrey = Color(0xFFB8B8BD);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController plateController;
  late final TextEditingController makeController;
  late final TextEditingController modelController;
  late final TextEditingController policyController;
  late final TextEditingController insuranceDateController;
  late final TextEditingController roadTaxDateController;

  late final List<String> vehicleTypes;
  late String selectedType;
  late VehicleStatus selectedStatus;
  late DateTime insuranceExpiry;
  late DateTime roadTaxExpiry;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;

    final trimmed = v.name.trim();
    final space = trimmed.indexOf(' ');
    final make = space == -1 ? trimmed : trimmed.substring(0, space);
    final model = space == -1 ? '' : trimmed.substring(space + 1);

    plateController = TextEditingController(text: v.plateNumber);
    makeController = TextEditingController(text: make);
    modelController = TextEditingController(text: model);
    policyController = TextEditingController(text: v.insuranceNumber);
    insuranceDateController = TextEditingController(
      text: formatDate(v.insuranceExpiry),
    );
    roadTaxDateController = TextEditingController(
      text: formatDate(v.roadTaxExpiry),
    );

    // Make sure the current type is always a valid dropdown value.
    vehicleTypes = [
      'Sedan',
      'Hatchback',
      'SUV',
      'MPV',
      'Pickup',
      if (!['Sedan', 'Hatchback', 'SUV', 'MPV', 'Pickup'].contains(v.type))
        v.type,
    ];
    selectedType = v.type;
    selectedStatus = v.status;
    insuranceExpiry = v.insuranceExpiry;
    roadTaxExpiry = v.roadTaxExpiry;
  }

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
            tooltip: 'Back',
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const Text(
            'Edit Vehicle',
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
            'Plate Number',
            TextFormField(
              controller: plateController,
              readOnly: true,
              decoration: fieldDecoration(null).copyWith(
                fillColor: const Color(0xFFE9E9EC),
                suffixIcon: const Icon(Icons.lock_outline, size: 18),
              ),
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
              current: () => insuranceExpiry,
              onPicked: (date) => insuranceExpiry = date,
            ),
          ),
          buildLabeled(
            'Road Tax Expiry Date *',
            buildDateField(
              controller: roadTaxDateController,
              current: () => roadTaxExpiry,
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
    required DateTime Function() current,
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
        final existing = current();
        // firstDate must not be after initialDate.
        final earliest = DateTime(now.year - 1);
        final picked = await showDatePicker(
          context: context,
          initialDate: existing,
          firstDate: existing.isBefore(earliest) ? existing : earliest,
          lastDate: DateTime(
            existing.year > now.year + 10 ? existing.year : now.year + 10,
          ),
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
                  'Save',
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

    final original = widget.vehicle;
    final updated = VehicleData(
      plateNumber: original.plateNumber, // id, never changes
      name: '${makeController.text.trim()} ${modelController.text.trim()}',
      type: selectedType,
      status: selectedStatus,
      insuranceNumber: policyController.text.trim(),
      insuranceCompany: original.insuranceCompany,
      insuranceExpiry: insuranceExpiry,
      roadTaxExpiry: roadTaxExpiry,
      maintenanceRecords: original.maintenanceRecords,
    );

    Navigator.pop(context, updated);
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

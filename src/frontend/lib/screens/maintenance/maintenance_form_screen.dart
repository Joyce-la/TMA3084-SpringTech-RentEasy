import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:src/models/maintenance_record.dart';
import 'package:src/providers/maintenance_provider.dart';
import 'package:src/screens/maintenance/maintenance_page_header.dart';

class MaintenanceFormScreen extends StatefulWidget {
  const MaintenanceFormScreen({super.key, this.record});

  final MaintenanceRecord? record;

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceTypeAnchor = GlobalKey();
  final _otherServiceAnchor = GlobalKey();
  final _vehicleAnchor = GlobalKey();
  final _endDateAnchor = GlobalKey();
  final _costAnchor = GlobalKey();
  final _workshopAnchor = GlobalKey();
  final _completionDateAnchor = GlobalKey();
  late final TextEditingController _serviceController;
  late final TextEditingController _workshopController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _costController;
  late DateTime _startDate;
  DateTime? _endDate;
  DateTime? _completionDate;
  String? _endDateError;
  String? _completionDateError;
  bool _hasAttemptedSave = false;
  bool _serviceOtherTouched = false;
  bool _costTouched = false;
  bool _workshopTouched = false;
  bool _isCompleted = false;
  late MaintenanceCategory _category;
  late String _selectedServiceType;
  int? _vehicleId;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _serviceController = TextEditingController();
    _workshopController = TextEditingController(text: record?.workshop ?? '');
    _descriptionController = TextEditingController(
      text: record?.description ?? '',
    );
    _costController = TextEditingController(
      text: record == null ? '' : record.cost.toStringAsFixed(2),
    );
    _startDate = record?.startDate ?? DateTime.now();
    _endDate = record?.endDate;
    _category = record?.category ?? MaintenanceCategory.repair;
    _isCompleted = record?.status == MaintenanceRecordStatus.completed;
    _completionDate = record?.completedDate;
    final serviceOptions = _serviceOptions(_category);
    if (record == null || serviceOptions.contains(record.serviceType)) {
      _selectedServiceType = record?.serviceType ?? serviceOptions.first;
    } else {
      _selectedServiceType = 'Other';
      _serviceController.text = record.serviceType;
    }
    _vehicleId = record?.vehicleId;
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _workshopController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MaintenanceProvider>();
    final vehicles = provider.vehicles;
    _vehicleId ??= vehicles.isEmpty
        ? null
        : provider.vehicleIdFor(vehicles.first);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            MaintenancePageHeader(
              title: widget.record == null
                  ? 'Add Maintenance'
                  : 'Edit Maintenance',
            ),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme
                      .copyWith(error: const Color(0xFFB3261E)),
                  inputDecorationTheme: Theme.of(context).inputDecorationTheme
                      .copyWith(
                        errorStyle: const TextStyle(
                          color: Color(0xFFB3261E),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    children: [
                      DropdownButtonFormField<MaintenanceCategory>(
                        key: const Key('maintenance-category'),
                        initialValue: _category,
                        decoration: InputDecoration(
                          labelText: 'Category *',
                          suffixIcon: IconButton(
                            tooltip: 'About this category',
                            onPressed: _showCategoryHelp,
                            icon: const Icon(Icons.info_outline),
                          ),
                        ),
                        items: MaintenanceCategory.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.label),
                              ),
                            )
                            .toList(),
                        onChanged: (category) {
                          if (category != null) {
                            setState(() {
                              _category = category;
                              _selectedServiceType = _serviceOptions(category)
                                  .first;
                              _serviceController.clear();
                              _endDateError = null;
                              _completionDateError = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      KeyedSubtree(
                        key: _serviceTypeAnchor,
                        child: DropdownButtonFormField<String>(
                          key: const Key('maintenance-service-type'),
                          initialValue: _selectedServiceType,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Service type *',
                          ),
                          items: _serviceOptions(_category)
                              .map(
                                (service) => DropdownMenuItem(
                                  value: service,
                                  child: Text(service),
                                ),
                              )
                              .toList(),
                          onChanged: (service) {
                            if (service != null) {
                              setState(() => _selectedServiceType = service);
                            }
                          },
                          validator: (value) =>
                              value == null ? 'Choose a service type' : null,
                        ),
                      ),
                      if (_selectedServiceType == 'Other') ...[
                        const SizedBox(height: 12),
                        KeyedSubtree(
                          key: _otherServiceAnchor,
                          child: TextFormField(
                            key: const Key('maintenance-service'),
                            controller: _serviceController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onChanged: (_) => setState(() {
                              _serviceOtherTouched = true;
                            }),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Describe the service *',
                            ),
                            validator: _required,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      KeyedSubtree(
                        key: _vehicleAnchor,
                        child: DropdownButtonFormField<int>(
                          key: const Key('maintenance-vehicle'),
                          initialValue: _vehicleId,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF25262B),
                          ),
                          dropdownColor: Colors.white,
                          menuMaxHeight: 240,
                          borderRadius: BorderRadius.circular(12),
                          decoration: const InputDecoration(
                            labelText: 'Vehicle *',
                          ),
                          items: vehicles
                              .map(
                                (vehicle) => DropdownMenuItem(
                                  value: provider.vehicleIdFor(vehicle)!,
                                  child: Text(
                                    '${vehicle.plateNumber} · ${vehicle.name}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF25262B),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _vehicleId = value),
                          validator: (value) =>
                              value == null ? 'Select a vehicle' : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _dateField(
                        fieldKey: const Key('maintenance-start-date-picker'),
                        label: _isComplianceCategory
                            ? 'Effective date *'
                            : 'Start date *',
                        date: _startDate,
                        onPicked: (date) => setState(() {
                          _startDate = date;
                          _endDateError = _endDateRangeValidationError();
                          _completionDateError =
                              _completionDateRangeValidationError();
                        }),
                      ),
                      const SizedBox(height: 12),
                      _dateField(
                        anchorKey: _endDateAnchor,
                        fieldKey: const Key('maintenance-end-date-picker'),
                        label: _isComplianceCategory
                            ? 'Expiry date *'
                            : 'Expected finish date *',
                        date: _endDate,
                        errorText: _hasAttemptedSave || _endDate != null
                            ? _endDateError
                            : null,
                        onPicked: (date) => setState(() {
                          _endDate = date;
                          _endDateError = _endDateRangeValidationError();
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          _statusPreview(),
                          key: const Key('maintenance-status-preview'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4C5361),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      KeyedSubtree(
                        key: _costAnchor,
                        child: TextFormField(
                          key: const Key('maintenance-cost'),
                          controller: _costController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (_) => setState(() {
                            _costTouched = true;
                          }),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Cost (RM) *',
                          ),
                          validator: _validCost,
                        ),
                      ),
                      const SizedBox(height: 12),
                      KeyedSubtree(
                        key: _workshopAnchor,
                        child: TextFormField(
                          key: const Key('maintenance-workshop'),
                          controller: _workshopController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (_) => setState(() {
                            _workshopTouched = true;
                          }),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: _isComplianceCategory
                                ? 'Insurer / provider *'
                                : 'Workshop *',
                          ),
                          validator: _required,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('maintenance-description'),
                        controller: _descriptionController,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        key: const Key('maintenance-already-completed'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Already completed'),
                        subtitle: Text(
                          _isComplianceCategory
                              ? 'Mark this insurance or road tax record as renewed.'
                              : 'Record work that was completed before adding it.',
                        ),
                        value: _isCompleted,
                        onChanged: (value) => setState(() {
                          _isCompleted = value;
                          _completionDateError = null;
                          if (!value) _completionDate = null;
                        }),
                      ),
                      if (_isCompleted) ...[
                        _dateField(
                          anchorKey: _completionDateAnchor,
                          fieldKey: const Key(
                            'maintenance-completion-date-picker',
                          ),
                          label: _isComplianceCategory
                              ? 'Renewed date *'
                              : 'Completion date *',
                          date: _completionDate,
                          errorText: _completionDateError,
                          onPicked: (date) => setState(() {
                            _completionDate = date;
                            _completionDateError =
                                _completionDateRangeValidationError();
                          }),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        key: const Key('save-maintenance'),
                        onPressed: _hasAttemptedSave
                            ? (_allFieldsValid ? _save : null)
                            : (_hasLiveInputError ? null : _save),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF071957),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField({
    Key? anchorKey,
    Key? fieldKey,
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPicked,
    String? errorText,
    VoidCallback? onClear,
  }) {
    return KeyedSubtree(
      key: anchorKey,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffixIcon: onClear == null
              ? const Icon(Icons.calendar_month)
              : IconButton(
                  tooltip: 'Clear end date',
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
        ),
        child: InkWell(
          key: fieldKey,
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? now,
              firstDate: DateTime(now.year - 10),
              lastDate: DateTime(now.year + 20),
            );
            if (picked != null) onPicked(picked);
          },
          child: SizedBox(
            height: 36,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                date == null ? 'Choose date' : _formatDate(date),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    setState(() {
      _hasAttemptedSave = true;
      _endDateError = _endDateValidationError();
      _completionDateError = _completionDateValidationError();
    });
    final formIsValid = _formKey.currentState!.validate();
    if (!formIsValid || _endDateError != null || _completionDateError != null) {
      _scrollToFirstInvalidField();
      return;
    }
    final provider = context.read<MaintenanceProvider>();
    final current = widget.record;
    final record = MaintenanceRecord(
      maintenanceId: current?.maintenanceId ?? provider.nextMaintenanceId,
      vehicleId: _vehicleId!,
      category: _category,
      serviceType: _selectedServiceType == 'Other'
          ? _serviceController.text.trim()
          : _selectedServiceType,
      startDate: _startDate,
      endDate: _endDate!,
      completedDate: _isCompleted ? _dateOnly(_completionDate!) : null,
      cost: double.parse(_costController.text.trim()),
      description: _descriptionController.text.trim(),
      workshop: _workshopController.text.trim(),
      status: _isCompleted
          ? MaintenanceRecordStatus.completed
          : MaintenanceRecordStatus.scheduled,
    );
    final saved = current == null
        ? provider.addMaintenance(record)
        : provider.updateMaintenance(record);
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this maintenance record.'),
        ),
      );
      return;
    }
    Navigator.pop(context, record);
  }

  String? _endDateValidationError() {
    if (_endDate == null) return 'Choose an end date.';
    return _endDateRangeValidationError();
  }

  String? _endDateRangeValidationError() {
    if (_endDate == null) return null;
    final start = _dateOnly(_startDate);
    final end = _dateOnly(_endDate!);
    if (end.isBefore(start)) {
      return _isComplianceCategory
          ? 'Expiry date must be after the effective date.'
          : 'Expected finish date must be on or after the start date.';
    }
    if (_isComplianceCategory && !end.isAfter(start)) {
      return 'Expiry date must be after the effective date.';
    }
    return null;
  }

  String? _completionDateValidationError() {
    if (!_isCompleted) return null;
    if (_completionDate == null) return 'Choose a completion date.';
    return _completionDateRangeValidationError();
  }

  String? _completionDateRangeValidationError() {
    if (!_isCompleted || _completionDate == null) return null;
    final completed = _dateOnly(_completionDate!);
    final today = _dateOnly(DateTime.now());
    if (completed.isAfter(today)) {
      return 'Completion date cannot be in the future.';
    }
    if (!_isComplianceCategory && completed.isBefore(_dateOnly(_startDate))) {
      return 'Completion date cannot be before the start date.';
    }
    return null;
  }

  bool get _allFieldsValid =>
      (_selectedServiceType != 'Other' ||
          _serviceController.text.trim().isNotEmpty) &&
      _vehicleId != null &&
      _endDateValidationError() == null &&
      _costError() == null &&
      _workshopController.text.trim().isNotEmpty &&
      _completionDateValidationError() == null;

  bool get _hasLiveInputError =>
      (_serviceOtherTouched &&
          _selectedServiceType == 'Other' &&
          _required(_serviceController.text) != null) ||
      (_costTouched && _costError() != null) ||
      (_workshopTouched && _required(_workshopController.text) != null) ||
      (_endDate != null && _endDateRangeValidationError() != null) ||
      (_completionDate != null &&
          _completionDateRangeValidationError() != null);

  void _scrollToFirstInvalidField() {
    final GlobalKey invalidField =
        _selectedServiceType == 'Other' &&
            _serviceController.text.trim().isEmpty
        ? _otherServiceAnchor
        : _vehicleId == null
        ? _vehicleAnchor
        : _endDateError != null
        ? _endDateAnchor
        : _costError() != null
        ? _costAnchor
        : _workshopController.text.trim().isEmpty
        ? _workshopAnchor
        : _completionDateError != null
        ? _completionDateAnchor
        : _serviceTypeAnchor;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fieldContext = invalidField.currentContext;
      if (fieldContext == null) return;
      Scrollable.ensureVisible(
        fieldContext,
        alignment: 0.15,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String _statusPreview() {
    if (_isCompleted) {
      return _completionDate == null
          ? 'Choose a completion date to mark this record Done.'
          : _completionDateRangeValidationError() != null
          ? 'Check the highlighted completion date.'
          : 'Status will be: Done';
    }
    if (_endDate == null) return 'Choose an end date to preview the status.';
    if (_endDateRangeValidationError() != null) {
      return 'Check the highlighted end date.';
    }

    final today = _dateOnly(DateTime.now());
    final start = _dateOnly(_startDate);
    final end = _dateOnly(_endDate!);
    if (_isComplianceCategory) {
      if (today.isAfter(end)) return 'Status will be: Overdue';
      final daysToExpiry = end.difference(today).inDays;
      return 'Status will be: Scheduled · Expires in $daysToExpiry days';
    }
    if (today.isAfter(end)) return 'Status will be: Overdue';
    if (today.isBefore(start)) return 'Status will be: Scheduled';
    return 'Status will be: In Progress';
  }

  Future<void> _showCategoryHelp() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(_category.label),
      content: Text(_category.guidance),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<String> _serviceOptions(MaintenanceCategory category) =>
      switch (category) {
        MaintenanceCategory.repair => [
          'Brake inspection',
          'Tire replacement',
          'Engine repair',
          'Electrical repair',
          'Air conditioning repair',
          'Body / glass repair',
          'Other',
        ],
        MaintenanceCategory.preventiveUpkeep => [
          'Scheduled service',
          'Oil & filter change',
          'Tire rotation',
          'Battery check',
          'Fluid service',
          'Other',
        ],
        MaintenanceCategory.insurance => [
          'Insurance renewal',
          'Policy update',
          'Other',
        ],
        MaintenanceCategory.roadTax => ['Road tax renewal', 'Other'],
      };

  bool get _isComplianceCategory => _category.isCompliance;

  String? _validCost(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null || amount < 0) return 'Enter a valid cost';
    return null;
  }

  String? _costError() => _validCost(_costController.text);

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

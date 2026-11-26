import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:src/mock_data/database_records.dart';
import 'package:src/mock_data/maintenance_records.dart';
import 'package:src/models/maintenance_record.dart';
import 'package:src/providers/maintenance_provider.dart';
import 'package:src/screens/maintenance/maintenance_form_screen.dart';
import 'package:src/screens/maintenance/maintenance_screen.dart';
import 'package:src/widgets/maintenance_card.dart';

DateTime _date(int daysFromToday) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).add(
    Duration(days: daysFromToday),
  );
}

MaintenanceRecord _record({
  int id = 900,
  String service = 'Brake inspection',
  MaintenanceCategory category = MaintenanceCategory.repair,
  MaintenanceRecordStatus status = MaintenanceRecordStatus.inProgress,
  int startDays = 0,
  int endDays = 5,
}) => MaintenanceRecord(
  maintenanceId: id,
  vehicleId: mockDatabase['Vehicle']!.first['vehicleId']! as int,
  category: category,
  serviceType: service,
  startDate: _date(startDays),
  endDate: _date(endDays),
  completedDate: status == MaintenanceRecordStatus.completed
      ? _date(0)
      : null,
  cost: 300,
  description: 'Maintenance test record',
  workshop: 'Central Auto',
  status: status,
);

Widget _app(MaintenanceProvider provider, Widget home) =>
    ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(home: home),
    );

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _selectCategory(
  WidgetTester tester,
  MaintenanceCategory category,
) async {
  await tester.tap(find.byKey(const Key('maintenance-category')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(category.label).last);
  await tester.pumpAndSettle();
}

Future<void> _selectService(WidgetTester tester, String service) async {
  await tester.tap(find.byKey(const Key('maintenance-service-type')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(service).last);
  await tester.pumpAndSettle();
}

Future<void> _chooseDate(
  WidgetTester tester,
  String pickerKey,
  DateTime date,
) async {
  final picker = find.byKey(Key(pickerKey));
  await tester.ensureVisible(picker);
  await tester.tap(picker);
  await tester.pumpAndSettle();

  // The pickers open at their existing date (or today for a new end date).
  // Move the calendar header month-by-month until the requested month appears.
  final monthLabel = find.text(_monthYear(date));
  var displayedMonth = DateTime.now();
  for (var attempt = 0;
      monthLabel.evaluate().isEmpty && attempt < 24;
      attempt++) {
    final targetMonth = DateTime(date.year, date.month);
    await tester.tap(
      find.byIcon(
        targetMonth.isBefore(displayedMonth)
            ? Icons.chevron_left
            : Icons.chevron_right,
      ).first,
    );
    await tester.pumpAndSettle();
    displayedMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + (targetMonth.isBefore(displayedMonth) ? -1 : 1),
    );
  }

  // A day can appear in the adjacent month's overflow cells too. Selecting
  // the last matching day targets the active month's calendar cell.
  await tester.tap(find.text(date.day.toString()).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

String _monthYear(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

void main() {
  group('MaintenanceProvider', () {
    test('derives status from dates and keeps completed records Done', () {
      final provider = MaintenanceProvider(
        initialRecords: [
          _record(
            id: 1,
            service: 'Overdue item',
            status: MaintenanceRecordStatus.scheduled,
            startDays: -5,
            endDays: -1,
          ),
          _record(
            id: 2,
            service: 'Active item',
            startDays: -1,
            endDays: 2,
          ),
          _record(
            id: 3,
            service: 'Future item',
            status: MaintenanceRecordStatus.scheduled,
            startDays: 2,
            endDays: 4,
          ),
          _record(
            id: 4,
            service: 'Completed item',
            status: MaintenanceRecordStatus.completed,
            startDays: -3,
            endDays: -1,
          ),
        ],
      );

      expect(provider.statusFor(provider.records[0]), 'Overdue');
      expect(provider.statusFor(provider.records[1]), 'In Progress');
      expect(provider.statusFor(provider.records[2]), 'Scheduled');
      expect(provider.statusFor(provider.records[3]), 'Done');
      expect(provider.visibleRecords.map((item) => item.serviceType), [
        'Overdue item',
        'Active item',
        'Future item',
        'Completed item',
      ]);
      expect(provider.countFor('Overdue'), 1);
      expect(provider.countFor('In Progress'), 1);
      expect(provider.countFor('Scheduled'), 1);
      expect(provider.countFor('Done'), 1);
    });

    test('searches service, plate, and vehicle model and applies filters', () {
      final provider = MaintenanceProvider(
        initialRecords: [
          _record(id: 11, service: 'Oil service'),
          _record(id: 12, service: 'Brake check'),
        ],
      );

      provider.setSearchQuery('oil');
      expect(provider.visibleRecords.map((item) => item.serviceType), [
        'Oil service',
      ]);
      provider.setSearchQuery(provider.vehicles.first.plateNumber);
      expect(provider.visibleRecords, hasLength(2));
      provider.setSelectedStatus('In Progress');
      expect(provider.visibleRecords, hasLength(2));
      provider.setSearchQuery('no match');
      expect(provider.visibleRecords, isEmpty);
    });

    test('adds, updates, completes, reopens, and removes a record', () {
      final provider = MaintenanceProvider(initialRecords: const []);
      final record = _record(
        id: provider.nextMaintenanceId,
        status: MaintenanceRecordStatus.scheduled,
      );

      expect(provider.addMaintenance(record), isTrue);
      expect(provider.addMaintenance(record), isFalse);
      expect(
        provider.updateMaintenance(record.copyWith(serviceType: 'Updated')),
        isTrue,
      );
      expect(provider.records.single.serviceType, 'Updated');
      expect(provider.markAsDone(record.maintenanceId), isTrue);
      expect(provider.statusFor(provider.records.single), 'Done');
      expect(provider.reopenMaintenance(record.maintenanceId), isTrue);
      expect(provider.records.single.completedDate, isNull);
      expect(provider.removeMaintenance(record.maintenanceId), isTrue);
      expect(provider.records, isEmpty);
    });

    test('sample records marked completed remain Done', () {
      final completed = mockMaintenanceRecords.where(
        (record) => record.status == MaintenanceRecordStatus.completed,
      );
      expect(completed, isNotEmpty);
      final provider = MaintenanceProvider();
      for (final record in completed) {
        expect(provider.statusFor(record), 'Done');
      }
    });
  });

  group('Maintenance screens', () {
    testWidgets('maintenance card can invoke Mark as done', (tester) async {
      var markedDone = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaintenanceCard(
              serviceName: 'Brake inspection',
              plateNumber: 'QAA 1234',
              vehicleName: 'Toyota Vios',
              dateLabel: 'Started today',
              status: 'In Progress',
              onMarkDone: () => markedDone = true,
            ),
          ),
        ),
      );

      expect(find.text('In Progress'), findsOneWidget);
      await tester.tap(find.text('Mark as done'));
      expect(markedDone, isTrue);
    });

    testWidgets('search and status filter update visible records', (
      tester,
    ) async {
      final provider = MaintenanceProvider(
        initialRecords: [
          _record(
            id: 20,
            service: 'Overdue brake repair',
            status: MaintenanceRecordStatus.scheduled,
            startDays: -3,
            endDays: -1,
          ),
          _record(id: 21, service: 'Current oil service'),
        ],
      );
      await tester.pumpWidget(
        _app(provider, const Scaffold(body: MaintenanceScreen())),
      );

      expect(find.byKey(const Key('maintenance-search')), findsOneWidget);
      expect(find.text('Overdue brake repair'), findsOneWidget);
      expect(find.text('Current oil service'), findsOneWidget);

      await tester.tap(find.text('Overdue').first);
      await tester.pumpAndSettle();
      expect(find.text('Overdue brake repair'), findsOneWidget);
      expect(find.text('Current oil service'), findsNothing);

      await tester.enterText(
        find.byKey(const Key('maintenance-search')),
        'not a matching record',
      );
      await tester.pumpAndSettle();
      expect(find.text('No maintenance records found.'), findsOneWidget);
    });

    testWidgets('add button opens the maintenance form', (tester) async {
      final provider = MaintenanceProvider(initialRecords: const []);
      await tester.pumpWidget(
        _app(provider, const Scaffold(body: MaintenanceScreen())),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('Add Maintenance'), findsOneWidget);
      expect(find.byKey(const Key('maintenance-category')), findsOneWidget);
    });
  });

  group('Maintenance form validation', () {
    testWidgets('opening and changing category does not show empty errors', (
      tester,
    ) async {
      _useTallViewport(tester);
      await tester.pumpWidget(
        _app(
          MaintenanceProvider(initialRecords: const []),
          const MaintenanceFormScreen(),
        ),
      );

      expect(find.text('Required'), findsNothing);
      expect(find.text('Enter a valid cost'), findsNothing);
      await _selectCategory(tester, MaintenanceCategory.insurance);
      expect(find.text('Required'), findsNothing);
      expect(find.text('Enter a valid cost'), findsNothing);
    });

    testWidgets('Save reveals all missing required fields', (tester) async {
      _useTallViewport(tester);
      await tester.pumpWidget(
        _app(
          MaintenanceProvider(initialRecords: const []),
          const MaintenanceFormScreen(),
        ),
      );

      await tester.ensureVisible(find.byKey(const Key('save-maintenance')));
      await tester.tap(find.byKey(const Key('save-maintenance')));
      await tester.pumpAndSettle();

      expect(find.text('Choose an end date.'), findsOneWidget);
      expect(find.text('Enter a valid cost'), findsOneWidget);
      expect(find.text('Required'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byKey(const Key('save-maintenance')))
            .onPressed,
        isNull,
      );
    });

    testWidgets('invalid cost and end date warn immediately', (tester) async {
      _useTallViewport(tester);
      await tester.pumpWidget(
        _app(
          MaintenanceProvider(initialRecords: const []),
          const MaintenanceFormScreen(),
        ),
      );

      await tester.enterText(find.byKey(const Key('maintenance-cost')), '-12');
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid cost'), findsOneWidget);

      final yesterday = _date(-1);
      await _chooseDate(
        tester,
        'maintenance-end-date-picker',
        yesterday,
      );
      expect(
        find.text('Expected finish date must be on or after the start date.'),
        findsOneWidget,
      );
      expect(
        tester.widget<FilledButton>(find.byKey(const Key('save-maintenance')))
            .onPressed,
        isNull,
      );
    });

    testWidgets('valid repair record saves; description is optional', (
      tester,
    ) async {
      _useTallViewport(tester);
      final provider = MaintenanceProvider(initialRecords: const []);
      await tester.pumpWidget(_app(provider, const MaintenanceFormScreen()));

      await _selectService(tester, 'Brake inspection');
      await tester.enterText(find.byKey(const Key('maintenance-cost')), '125');
      await tester.enterText(
        find.byKey(const Key('maintenance-workshop')),
        'City Auto',
      );
      await _chooseDate(tester, 'maintenance-end-date-picker', _date(1));
      await tester.ensureVisible(find.byKey(const Key('save-maintenance')));
      await tester.tap(find.byKey(const Key('save-maintenance')));
      await tester.pumpAndSettle();

      expect(provider.records, hasLength(1));
      expect(provider.records.single.serviceType, 'Brake inspection');
      expect(provider.records.single.cost, 125);
      expect(provider.records.single.description, isEmpty);
    });

    testWidgets('already completed form saves a Done record', (tester) async {
      _useTallViewport(tester);
      final provider = MaintenanceProvider(initialRecords: const []);
      await tester.pumpWidget(_app(provider, const MaintenanceFormScreen()));

      await tester.enterText(find.byKey(const Key('maintenance-cost')), '75');
      await tester.enterText(
        find.byKey(const Key('maintenance-workshop')),
        'City Auto',
      );
      await _chooseDate(tester, 'maintenance-end-date-picker', _date(1));
      final completedSwitch = find.byKey(
        const Key('maintenance-already-completed'),
      );
      await tester.ensureVisible(completedSwitch);
      await tester.tap(completedSwitch);
      await tester.pumpAndSettle();
      await _chooseDate(
        tester,
        'maintenance-completion-date-picker',
        _date(0),
      );
      await tester.ensureVisible(find.byKey(const Key('save-maintenance')));
      await tester.tap(find.byKey(const Key('save-maintenance')));
      await tester.pumpAndSettle();

      expect(provider.records, hasLength(1));
      expect(provider.statusFor(provider.records.single), 'Done');
      expect(provider.records.single.completedDate, isNotNull);
    });
  });
}

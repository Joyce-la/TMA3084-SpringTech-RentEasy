import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:src/main.dart';
import 'package:src/mock_data/vehicles.dart';
import 'package:src/providers/fleet_provider.dart';
import 'package:src/screens/fleet/fleet_screen.dart';
import 'package:src/screens/fleet/vehicle_details_screen.dart';
import 'package:src/screens/fleet/edit_vehicle_screen.dart';
import 'package:src/widgets/vehicle_card.dart';

VehicleData _testVehicle({String plate = 'TEST 1'}) => VehicleData(
  plateNumber: plate,
  name: 'Test Car',
  type: 'Sedan',
  status: VehicleStatus.rented,
  insuranceNumber: '',
  insuranceCompany: '',
  insuranceExpiry: DateTime(2030, 1, 1),
  roadTaxExpiry: DateTime(2030, 1, 1),
  maintenanceRecords: const [],
);

void main() {
  test('Vehicle mock conversion produces complete UI data', () {
    expect(mockVehicles, isNotEmpty);
    for (final vehicle in mockVehicles) {
      expect(vehicle.plateNumber, isNotEmpty);
      expect(vehicle.name, isNotEmpty);
      expect(vehicle.type, isNotEmpty);
    }
  });

  test('FleetProvider exposes an unmodifiable vehicle list', () {
    final provider = FleetProvider();

    expect(
      () => provider.vehicles.add(provider.vehicles.first),
      throwsUnsupportedError,
    );
  });

  test('FleetProvider filters by search text and status', () {
    final provider = FleetProvider(initialVehicles: [_testVehicle()]);

    provider.setSearchQuery('test 1');
    expect(provider.visibleVehicles, hasLength(1));

    provider.setSearchQuery('no-such-plate');
    expect(provider.visibleVehicles, isEmpty);

    provider.setSearchQuery('');
    provider.setSelectedStatus(VehicleStatus.available);
    expect(provider.visibleVehicles, isEmpty);

    provider.setSelectedStatus(VehicleStatus.rented);
    expect(provider.visibleVehicles, hasLength(1));
  });

  test('FleetProvider adds a vehicle and updates counts', () {
    final provider = FleetProvider(initialVehicles: const []);

    provider.addVehicle(_testVehicle());

    expect(provider.countFor(null), 1);
    expect(provider.countFor(VehicleStatus.rented), 1);
    expect(provider.countFor(VehicleStatus.available), 0);
  });

  test('VehicleData only reports tax expiry within 30 days', () {
    final soon = VehicleData(
      plateNumber: 'SOON 1',
      name: 'Test',
      type: 'Sedan',
      status: VehicleStatus.available,
      insuranceNumber: '',
      insuranceCompany: '',
      insuranceExpiry: DateTime(2030, 1, 1),
      roadTaxExpiry: DateTime.now().add(const Duration(days: 10)),
      maintenanceRecords: const [],
    );

    expect(soon.taxExpiryDays, isNotNull);
    expect(_testVehicle().taxExpiryDays, isNull);
  });

  testWidgets('Fleet screen searches vehicles', (tester) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Fleet'));
    await tester.pumpAndSettle();

    final first = mockVehicles.first.plateNumber;
    await tester.enterText(find.byType(TextField), first);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(VehicleCard), matching: find.text(first)),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'no-such-vehicle');
    await tester.pumpAndSettle();
    expect(find.text('No vehicles found.'), findsOneWidget);
  });

  testWidgets('Added vehicles and search text survive switching tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Fleet'));
    await tester.pumpAndSettle();

    final provider = tester
        .element(find.byType(FleetScreen))
        .read<FleetProvider>();
    provider.addVehicle(_testVehicle(plate: 'KEEP 1'));
    await tester.enterText(find.byType(TextField), 'KEEP 1');
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(VehicleCard),
        matching: find.text('KEEP 1'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Rentals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fleet'));
    await tester.pumpAndSettle();

    expect(provider.vehicles.any((v) => v.plateNumber == 'KEEP 1'), isTrue);
    expect(find.widgetWithText(TextField, 'KEEP 1'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(VehicleCard),
        matching: find.text('KEEP 1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Vehicle card opens its details screen', (tester) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Fleet'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(VehicleCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(VehicleDetailsScreen), findsOneWidget);
    expect(find.text('Vehicle Info'), findsOneWidget);
    expect(find.text('Insurance and Road Tax'), findsOneWidget);
  });

  testWidgets('Editing a vehicle updates the list', (tester) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Fleet'));
    await tester.pumpAndSettle();

    final provider = tester
        .element(find.byType(FleetScreen))
        .read<FleetProvider>();
    final plate = provider.vehicles.first.plateNumber;

    await tester.tap(find.byType(VehicleCard).first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Edit'));
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.byType(EditVehicleScreen), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'Edited Model');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final edited = provider.vehicles.firstWhere((v) => v.plateNumber == plate);
    expect(edited.name.endsWith('Edited Model'), isTrue);
    expect(find.byType(VehicleDetailsScreen), findsOneWidget);
    expect(find.text('Edited Model'), findsOneWidget);
  });

  testWidgets('Edit form keeps the plate number read-only', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: EditVehicleScreen(vehicle: _testVehicle())),
    );

    await tester.enterText(find.byType(TextFormField).first, 'CHANGED 9');
    await tester.pump();

    expect(find.text('TEST 1'), findsOneWidget);
    expect(find.text('CHANGED 9'), findsNothing);
  });

  testWidgets('Removing a vehicle returns to Fleet without it', (tester) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Fleet'));
    await tester.pumpAndSettle();

    final provider = tester
        .element(find.byType(FleetScreen))
        .read<FleetProvider>();
    final before = provider.vehicles.length;

    await tester.tap(find.byType(VehicleCard).first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Remove'));
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Remove'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FleetScreen), findsOneWidget);
    expect(provider.vehicles.length, before - 1);
  });

  testWidgets('A rented vehicle cannot be removed', (tester) async {
    await tester.pumpWidget(const RentEasyApp());
    await tester.tap(find.text('Fleet'));
    await tester.pumpAndSettle();

    final provider = tester
        .element(find.byType(FleetScreen))
        .read<FleetProvider>();
    provider.addVehicle(_testVehicle(plate: 'RENT 1')); // status: rented
    await tester.enterText(find.byType(TextField), 'RENT 1');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(VehicleCard).first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Remove'));
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('A rented vehicle cannot be removed.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(provider.vehicles.any((v) => v.plateNumber == 'RENT 1'), isTrue);
  });
}

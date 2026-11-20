import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/widgets/vehicle_card.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('VehicleCard shows plate, name, status, type and services', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const VehicleCard(
          plate: 'QAA 1234',
          name: 'Toyota Vios 2022',
          type: 'Sedan',
          services: 3,
          statusLabel: 'AVAILABLE',
        ),
      ),
    );

    expect(find.text('QAA 1234'), findsOneWidget);
    expect(find.text('Toyota Vios 2022'), findsOneWidget);
    expect(find.text('AVAILABLE'), findsOneWidget);
    expect(find.text('Sedan'), findsOneWidget);
    expect(find.text('3 Recorded'), findsOneWidget);
  });

  testWidgets('VehicleCard shows tax warning only when taxExpiryDays is set', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const VehicleCard(
          plate: 'QAB 4567',
          name: 'Honda City 2021',
          type: 'Sedan',
          services: 5,
          statusLabel: 'RENTED',
          taxExpiryDays: 18,
        ),
      ),
    );
    expect(find.text('Tax Exp in 18 days'), findsOneWidget);

    await tester.pumpWidget(
      wrap(
        const VehicleCard(
          plate: 'QAA 7890',
          name: 'Perodua Axia 2023',
          type: 'Hatchback',
          services: 10,
          statusLabel: 'MAINTENANCE',
        ),
      ),
    );
    expect(find.textContaining('Tax Exp'), findsNothing);
  });

  testWidgets('VehicleCard calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        VehicleCard(
          plate: 'QAA 5580',
          name: 'Toyota Vios 2022',
          type: 'Sedan',
          services: 7,
          statusLabel: 'UNAVAILABLE',
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.text('QAA 5580'));
    expect(tapped, isTrue);
  });
}

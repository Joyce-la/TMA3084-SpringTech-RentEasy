import 'package:material_ui/material_ui.dart';
import 'package:src/screens/home_screen.dart';
import 'package:src/screens/fleet/fleet_screen.dart';
import 'package:src/screens/payments/deposit_screen.dart';
import 'package:src/screens/payments/invoice_screen.dart';
import 'package:provider/provider.dart';
import 'package:src/providers/deposit_provider.dart';
import 'package:src/providers/invoice_provider.dart';

void main() {
  runApp(const RentEasyApp());
}

class RentEasyApp extends StatelessWidget {
  const RentEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => DepositProvider()),
      ],
      child: MaterialApp(
        title: 'RentEasy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF071957)),
          useMaterial3: true,
        ),
        home: const BottomNav(),
      ),
    );
  }
}

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  bool _showDeposits = false;

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 3) {
        _showDeposits = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSelectedScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            label: 'Fleet',
          ),
          NavigationDestination(
            icon: Icon(Icons.key_outlined),
            label: 'Rentals',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            label: 'Payment',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedScreen() {
    if (_selectedIndex == 0) {
      return const HomeScreen();
    }

    if (_selectedIndex == 1) {
      return const FleetScreen();
    }

    if (_selectedIndex == 3) {
      if (_showDeposits) {
        return DepositScreen(
          onInvoiceSelected: () => setState(() => _showDeposits = false),
        );
      }
      return InvoiceScreen(
        onDepositsSelected: () => setState(() => _showDeposits = true),
      );
    }

    final message = switch (_selectedIndex) {
      2 => 'The Rentals screen is coming soon.',
      4 => 'The Reports screen is coming soon.',
      _ => 'This screen is coming soon.',
    };
    return Center(child: Text(message, textAlign: TextAlign.center));
  }
}

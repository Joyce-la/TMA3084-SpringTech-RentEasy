import 'package:flutter/material.dart';

import 'features/maintenance_reports/screens/reports_screen.dart';

void main() {
  runApp(const RentEasyPreview());
}

class RentEasyPreview extends StatelessWidget {
  const RentEasyPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RentEasy',
      home: ReportsScreen(),
    );
  }
}

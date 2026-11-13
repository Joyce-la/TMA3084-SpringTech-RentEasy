import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Selected reporting period
  String selectedMonth = 'November';
  int selectedYear = 2026;

  // Theme colours
  static const Color navyBlue = Color(0xFF071957);
  static const Color cardGrey = Color(0xFFB7B7BB);
  static const Color lightGrey = Color(0xFFE0E0E0);

  // Available months
  final List<String> months = [
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

  // Available years
  final List<int> years = List.generate(16, (index) => 2020 + index);

  // Sample monthly report data
  // These figures are for prototype demonstration only.
  final Map<String, MonthlyReportData> sampleReports = {
    '2026-11': MonthlyReportData(
      totalRentals: 25,
      totalRevenue: 7500,
      outstandingPayments: 1000,
      maintenanceCost: 800,
      weeklyRevenue: [1500, 2200, 1450, 2350],
    ),

    '2026-10': MonthlyReportData(
      totalRentals: 21,
      totalRevenue: 6200,
      outstandingPayments: 850,
      maintenanceCost: 650,
      weeklyRevenue: [1200, 1800, 1400, 1800],
    ),

    '2026-12': MonthlyReportData(
      totalRentals: 28,
      totalRevenue: 8400,
      outstandingPayments: 1200,
      maintenanceCost: 900,
      weeklyRevenue: [1800, 2100, 1900, 2600],
    ),
  };

  // Get report data for the selected month and year
  MonthlyReportData get currentReport {
    String monthNumber = (months.indexOf(selectedMonth) + 1).toString().padLeft(
      2,
      '0',
    );

    String reportKey = '$selectedYear-$monthNumber';

    return sampleReports[reportKey] ??
        MonthlyReportData(
          totalRentals: 0,
          totalRevenue: 0,
          outstandingPayments: 0,
          maintenanceCost: 0,
          weeklyRevenue: [0, 0, 0, 0],
        );
  }

  @override
  Widget build(BuildContext context) {
    final report = currentReport;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Page header
              buildHeader(),

              const SizedBox(height: 20),

              // 2. Report and Maintenance tabs
              buildTabs(),

              const SizedBox(height: 16),

              // 3. Reporting period selector
              buildPeriodSelector(),

              const SizedBox(height: 12),

              // 4. Summary cards
              buildSummaryCards(report),

              const SizedBox(height: 24),

              // 5. Revenue chart title
              const Text(
                'Monthly Revenue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // 6. Revenue chart
              buildRevenueChart(report),

              const SizedBox(height: 20),

              // 7. Export report button
              buildExportButton(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: buildBottomNavigation(),
    );
  }

  // --------------------------------------------------
  // 1. PAGE HEADER
  // --------------------------------------------------

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            'Reports & Maintenance',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        Row(
          children: [
            buildHeaderIcon(Icons.smart_toy_outlined),
            const SizedBox(width: 8),
            buildHeaderIcon(Icons.person),
          ],
        ),
      ],
    );
  }

  Widget buildHeaderIcon(IconData icon) {
    return CircleAvatar(
      radius: 17,
      backgroundColor: Colors.grey.shade300,
      child: Icon(icon, size: 19, color: Colors.black),
    );
  }

  // --------------------------------------------------
  // 2. REPORT AND MAINTENANCE TABS
  // --------------------------------------------------

  Widget buildTabs() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: navyBlue,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Center(
              child: Text(
                'Report',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 4),

        Expanded(
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maintenance screen will be developed next.'),
                ),
              );
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(child: Text('Maintenance')),
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // 3. REPORTING PERIOD SELECTOR
  // --------------------------------------------------

  Widget buildPeriodSelector() {
    return GestureDetector(
      onTap: showPeriodSelector,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: cardGrey,
          borderRadius: BorderRadius.circular(5),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$selectedMonth $selectedYear',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
      ),
    );
  }

  // Show month and year scrolling dialog
  Future<void> showPeriodSelector() async {
    int selectedMonthIndex = months.indexOf(selectedMonth);
    int selectedYearIndex = years.indexOf(selectedYear);

    final result = await showDialog<Map<String, Object>>(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dialog title
                    const Text(
                      'Select Report Period',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Scroll to select month and year',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Month and year headings
                    Row(
                      children: const [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Month',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        Expanded(
                          child: Center(
                            child: Text(
                              'Year',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Two scrolling wheels
                    Row(
                      children: [
                        // Month picker
                        Expanded(
                          child: SizedBox(
                            height: 150,

                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedMonthIndex,
                              ),

                              itemExtent: 40,
                              magnification: 1.1,
                              useMagnifier: true,

                              onSelectedItemChanged: (index) {
                                dialogSetState(() {
                                  selectedMonthIndex = index;
                                });
                              },

                              children: months.map((month) {
                                return Center(
                                  child: Text(
                                    month,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        // Year picker
                        Expanded(
                          child: SizedBox(
                            height: 150,

                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedYearIndex,
                              ),

                              itemExtent: 40,
                              magnification: 1.1,
                              useMagnifier: true,

                              onSelectedItemChanged: (index) {
                                dialogSetState(() {
                                  selectedYearIndex = index;
                                });
                              },

                              children: years.map((year) {
                                return Center(
                                  child: Text(
                                    year.toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navyBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),

                        onPressed: () {
                          Navigator.pop(dialogContext, {
                            'month': months[selectedMonthIndex],
                            'year': years[selectedYearIndex],
                          });
                        },

                        child: const Text(
                          'Confirm',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Update the report only after Confirm is pressed
    if (result != null) {
      setState(() {
        selectedMonth = result['month'] as String;
        selectedYear = result['year'] as int;
      });
    }
  }

  // --------------------------------------------------
  // 4. SUMMARY CARDS
  // --------------------------------------------------

  Widget buildSummaryCards(MonthlyReportData report) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: buildSummaryCard(
                'Total Rentals',
                report.totalRentals.toString(),
                Icons.directions_car,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: buildSummaryCard(
                'Total Revenue',
                'RM ${formatAmount(report.totalRevenue)}',
                Icons.payments,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: buildSummaryCard(
                'Outstanding Payments',
                'RM ${formatAmount(report.outstandingPayments)}',
                Icons.account_balance_wallet,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: buildSummaryCard(
                'Maintenance Cost',
                'RM ${formatAmount(report.maintenanceCost)}',
                Icons.build,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Individual summary card
  Widget buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(5),
      ),

      child: Row(
        children: [
          Icon(icon, size: 27, color: Colors.white),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                ),

                const SizedBox(height: 4),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Format amounts with commas
  String formatAmount(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  // --------------------------------------------------
  // 5. MONTHLY REVENUE CHART
  // --------------------------------------------------

  Widget buildRevenueChart(MonthlyReportData report) {
    const double maxRevenue = 3000;

    if (report.totalRentals == 0) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No report data available for $selectedMonth $selectedYear.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Container(
      height: 230,
      padding: const EdgeInsets.all(12),

      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('3,000', style: TextStyle(fontSize: 9)),
                    Text('2,000', style: TextStyle(fontSize: 9)),
                    Text('1,000', style: TextStyle(fontSize: 9)),
                    Text('0', style: TextStyle(fontSize: 9)),
                  ],
                ),

                const SizedBox(width: 12),

                // Weekly revenue bars
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: List.generate(report.weeklyRevenue.length, (
                      index,
                    ) {
                      double barHeight =
                          (report.weeklyRevenue[index] / maxRevenue) * 135;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 32,
                            height: barHeight,

                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              border: Border.all(color: Colors.grey.shade700),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Week ${index + 1}',
                            style: const TextStyle(fontSize: 9),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // 6. EXPORT REPORT BUTTON
  // --------------------------------------------------

  Widget buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,

      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyBlue,
          foregroundColor: Colors.white,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),

        onPressed: showExportDialog,

        icon: const Icon(Icons.download),

        label: const Text(
          'Export Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Show PDF and Excel selection dialog
  Future<void> showExportDialog() async {
    String selectedFormat = 'PDF';

    final result = await showDialog<String>(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              title: const Text(
                'Export Monthly Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    '$selectedMonth $selectedYear',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Select export format:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 8),

                  // Radio option (PDF / Excel)
                  RadioGroup<String>(
                    groupValue: selectedFormat,

                    onChanged: (String? value) {
                      if (value != null) {
                        dialogSetState(() {
                          selectedFormat = value;
                        });
                      }
                    },

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // PDF option
                        RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          value: 'PDF',
                          activeColor: navyBlue,

                          title: const Text(
                            'PDF Document',
                            style: TextStyle(fontSize: 14),
                          ),

                          subtitle: const Text(
                            'Formatted report for viewing and printing',
                            style: TextStyle(fontSize: 11),
                          ),

                          secondary: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                          ),
                        ),

                        // Excel option
                        RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          value: 'Excel',
                          activeColor: navyBlue,

                          title: const Text(
                            'Excel Spreadsheet',
                            style: TextStyle(fontSize: 14),
                          ),

                          subtitle: const Text(
                            'Structured report data for analysis',
                            style: TextStyle(fontSize: 11),
                          ),

                          secondary: const Icon(
                            Icons.table_chart,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },

                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navyBlue,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: () {
                    Navigator.pop(dialogContext, selectedFormat);
                  },

                  child: const Text('Export'),
                ),
              ],
            );
          },
        );
      },
    );

    // Simulated export confirmation
    if (result != null && mounted) {
      showExportConfirmation(result);
    }
  }

  // Show simulated export success message
  void showExportConfirmation(String format) {
    showDialog<void>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 55),

              const SizedBox(height: 16),

              const Text(
                'Export Successful!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                'Your $format report for '
                '$selectedMonth $selectedYear '
                'has been successfully exported.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Prototype simulation only. No actual file was generated.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // 7. BOTTOM NAVIGATION
  // --------------------------------------------------

  Widget buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 4,
      selectedItemColor: navyBlue,
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.grey.shade200,
      selectedFontSize: 10,
      unselectedFontSize: 10,

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Fleet',
        ),

        BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: 'Rentals'),

        BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payment'),

        BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Reports'),
      ],

      onTap: (index) {
        if (index != 4) {
          final moduleNames = ['Home', 'Fleet', 'Rentals', 'Payment'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${moduleNames[index]} module is not implemented yet.',
              ),
            ),
          );
        }
      },
    );
  }
}

// --------------------------------------------------
// MONTHLY REPORT DATA MODEL
// --------------------------------------------------

class MonthlyReportData {
  final int totalRentals;
  final double totalRevenue;
  final double outstandingPayments;
  final double maintenanceCost;
  final List<double> weeklyRevenue;

  MonthlyReportData({
    required this.totalRentals,
    required this.totalRevenue,
    required this.outstandingPayments,
    required this.maintenanceCost,
    required this.weeklyRevenue,
  });
}

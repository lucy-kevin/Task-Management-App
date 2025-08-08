import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epr_system/main.dart' hide InventoryScreen;
import 'package:epr_system/screens/dashboard/customers_screens.dart';
import 'package:epr_system/screens/dashboard/dashboard.dart';
import 'package:epr_system/screens/dashboard/report_screen.dart';
import 'package:epr_system/screens/dashboard/sales_screen.dart';
import 'package:epr_system/widgets/appdrawer.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ModernDashboardContent(),
    const ModernInventoryScreen(),
    const ModernSalesScreen(),
    const ModernCustomersScreen(),
    const ModernReportsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Row(
        children: [
          // Sidebar
          AppDrawer(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
          // Main content
          Expanded(
            child: Column(
              children: [
                // App Bar
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning! 👋',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const Text(
                            'Dashboard Overview',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Screen content
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

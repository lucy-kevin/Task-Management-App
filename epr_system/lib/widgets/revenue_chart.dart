import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epr_system/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class RevenueChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.getOrdersSnapshot(), // Use the correct stream method
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No orders data available'));
        }

        final orders = snapshot.data!.docs;
        final monthlyRevenue = _calculateMonthlyRevenue(orders);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Revenue Trend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            getTitlesWidget: (value, meta) {
                              const months = [
                                'J',
                                'F',
                                'M',
                                'A',
                                'M',
                                'J',
                                'J',
                                'A',
                                'S',
                                'O',
                                'N',
                                'D',
                              ];
                              return Text(months[value.toInt()]);
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString());
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      minX: 0,
                      maxX: 11,
                      minY: 0,
                      maxY:
                          monthlyRevenue.reduce((a, b) => a > b ? a : b) * 1.2,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(12, (index) {
                            return FlSpot(
                              index.toDouble(),
                              monthlyRevenue[index],
                            );
                          }),
                          isCurved: true,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.3),
                                const Color(0xFF8B5CF6).withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<double> _calculateMonthlyRevenue(List<QueryDocumentSnapshot> orders) {
    final now = DateTime.now();
    final monthlyRevenue = List<double>.filled(12, 0);

    for (final order in orders) {
      final data = order.data() as Map<String, dynamic>;
      final date = (data['createdAt'] as Timestamp).toDate();

      // Only consider orders from the current year
      if (date.year == now.year) {
        final month = date.month - 1; // Convert to 0-based index
        monthlyRevenue[month] += (data['total'] ?? 0).toDouble();
      }
    }

    return monthlyRevenue;
  }
}

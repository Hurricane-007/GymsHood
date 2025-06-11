import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/revenueDataModel.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';
import 'package:gymshood/pages/createServicesPages/createplansPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


class RevenuePage extends StatefulWidget {
  const RevenuePage({super.key});

  @override
  State<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  String selectedPeriod = 'monthly';
  List<RevenueData> revenueData = [];
  bool isLoading = true;
  String? error;
  String selectedChartType = 'bar'; // 'bar' or 'line'

  @override
  void initState() {
    super.initState();
    fetchRevenueData();
  }

  Future<void> fetchRevenueData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      Authuser? authuser = await AuthService.server().getUser();
      final gyms = await Gymserviceprovider.server().getGymsByowner(authuser!.userid!);
      final gymId = gyms[0].gymid;

      final data = await Gymserviceprovider.server().fetchRevenueData(gymId , period: selectedPeriod);
      setState(() {
            revenueData =  data;
            isLoading = false;
          });} catch(e){
            isLoading = false;
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("error in fetching the revenue data"))
           );
          }
      
  }

  String formatPeriod(Map<String, dynamic> period) {
    if (period.containsKey('day')) {
      return '${period['year']}-${period['month']}-${period['day']}';
    } else if (period.containsKey('week')) {
      return 'Week ${period['week']}, ${period['year']}';
    } else {
      return '${DateFormat('MMMM').format(DateTime(2000, period['month']))} ${period['year']}';
    }
  }

  Widget _buildChart() {
    if (revenueData.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.bar_chart,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Revenue Data Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Start creating gym plans and accepting payments to see your revenue analytics here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePlansPage()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Gym Plans'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      );
    }

    // Group data by plan
    Map<String, List<RevenueData>> planGroups = {};
    for (var data in revenueData) {
      if (!planGroups.containsKey(data.planName)) {
        planGroups[data.planName] = [];
      }
      planGroups[data.planName]!.add(data);
    }

    return Column(
      children: [
        // Chart Type Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.bar_chart,
                  color: selectedChartType == 'bar'
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                onPressed: () => setState(() => selectedChartType = 'bar'),
              ),
              IconButton(
                icon: Icon(
                  Icons.show_chart,
                  color: selectedChartType == 'line'
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                onPressed: () => setState(() => selectedChartType = 'line'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Chart
        SizedBox(
          height: 300,
          child: selectedChartType == 'bar'
              ? _buildBarChart(planGroups)
              : _buildLineChart(planGroups),
        ),
        const SizedBox(height: 20),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: planGroups.keys.map((planName) {
            final index = planGroups.keys.toList().indexOf(planName);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getColorForIndex(index),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  planName,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart(Map<String, List<RevenueData>> planGroups) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxRevenue(planGroups) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBorder: const BorderSide(color: Colors.blueGrey),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= revenueData.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    formatPeriod(revenueData[value.toInt()].period),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _createBarGroups(planGroups),
      ),
    );
  }

  Widget _buildLineChart(Map<String, List<RevenueData>> planGroups) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= revenueData.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    formatPeriod(revenueData[value.toInt()].period),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: _createLineBarsData(planGroups),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(Map<String, List<RevenueData>> planGroups) {
    if (planGroups.isEmpty || revenueData.isEmpty) return [];
    
    List<BarChartGroupData> barGroups = [];
    final plans = planGroups.keys.toList();
    final maxLength = revenueData.length;

    for (int i = 0; i < maxLength; i++) {
      List<BarChartRodData> rods = [];
      for (int j = 0; j < plans.length; j++) {
        final planData = planGroups[plans[j]]!;
        if (i < planData.length) {
          rods.add(
            BarChartRodData(
              toY: planData[i].totalRevenue,
              color: _getColorForIndex(j),
              width: 8,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          );
        }
      }
      if (rods.isNotEmpty) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: rods,
            barsSpace: 4,
          ),
        );
      }
    }
    return barGroups;
  }

  List<LineChartBarData> _createLineBarsData(Map<String, List<RevenueData>> planGroups) {
    if (planGroups.isEmpty) return [];
    
    List<LineChartBarData> lineBars = [];
    final plans = planGroups.keys.toList();

    for (int i = 0; i < plans.length; i++) {
      final planData = planGroups[plans[i]]!;
      if (planData.isNotEmpty) {
        lineBars.add(
          LineChartBarData(
            spots: List.generate(
              planData.length,
              (index) => FlSpot(index.toDouble(), planData[index].totalRevenue),
            ),
            isCurved: true,
            color: _getColorForIndex(i),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: _getColorForIndex(i).withOpacity(0.2),
            ),
          ),
        );
      }
    }
    return lineBars;
  }

  double _getMaxRevenue(Map<String, List<RevenueData>> planGroups) {
    if (planGroups.isEmpty) return 100.0; // Default max value if no data
    
    double maxRevenue = 0;
    for (var planData in planGroups.values) {
      for (var data in planData) {
        if (data.totalRevenue > maxRevenue) {
          maxRevenue = data.totalRevenue;
        }
      }
    }
    return maxRevenue > 0 ? maxRevenue : 100.0; // Return default if no revenue
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Revenue Analytics",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                selectedPeriod = value;
                fetchRevenueData();
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'daily',
                child: Text('Daily'),
              ),
              const PopupMenuItem(
                value: 'weekly',
                child: Text('Weekly'),
              ),
              const PopupMenuItem(
                value: 'monthly',
                child: Text('Monthly'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildChart(),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: revenueData.length,
                            itemBuilder: (context, index) {
                              final data = revenueData[index];
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatPeriod(data.period),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Plan: ${data.planName}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Total Revenue',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                '\$${data.totalRevenue.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text(
                                                'Transactions',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                data.transactionCount.toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }
}
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/revenueDataModel.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';
import 'package:gymshood/pages/createServicesPages/createplansPage.dart';
import 'package:gymshood/pages/createServicesPages/Gyminfopage.dart';
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
  String selectedChartType = 'bar'; // 'bar' or 'pie'
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic>? selectedPeriodData;

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
      final gyms =
          await Gymserviceprovider.server().getGymsByowner(authuser!.userid!);

      if (gyms.isEmpty) {
        setState(() {
          isLoading = false;
          revenueData = [];
        });
        return;
      }

      final gymId = gyms[0].gymid;
      final data = await Gymserviceprovider.server()
          .fetchRevenueData(gymId, period: selectedPeriod);
      setState(() {
        revenueData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Error fetching revenue data";
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error in fetching the revenue data")));
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

  List<DateTime> getAvailableMonths() {
    Set<String> uniqueMonths = {};
    for (var data in revenueData) {
      if (data.period['year'] != null && data.period['month'] != null) {
        uniqueMonths.add('${data.period['year']}-${data.period['month']}');
      }
    }
    return uniqueMonths.map((dateStr) {
      final parts = dateStr.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }).toList()..sort((a, b) => b.compareTo(a));
  }

  String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  Widget _buildChart() {
    if (revenueData.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Revenue Data Available',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Start creating gym plans and accepting payments to see your revenue analytics here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

    // Group data by planName
    final Map<String, List<RevenueData>> planGroups = {};
    for (final data in revenueData) {
      planGroups.putIfAbsent(data.planName, () => []).add(data);
    }

    // Sort each plan's data chronologically
    for (final entries in planGroups.values) {
      entries.sort((a, b) {
        String keyA =
            "${a.period['year'] ?? ''}${a.period['month'] ?? ''}${a.period['week'] ?? ''}${a.period['day'] ?? ''}";
        String keyB =
            "${b.period['year'] ?? ''}${b.period['month'] ?? ''}${b.period['week'] ?? ''}${b.period['day'] ?? ''}";
        return keyA.compareTo(keyB);
      });
    }

    return Column(
      children: [
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
                  Icons.pie_chart,
                  color: selectedChartType == 'pie'
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                onPressed: () => setState(() => selectedChartType = 'pie'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            key: ValueKey(selectedChartType),
            height: 300,
            child: selectedChartType == 'bar'
                ? _buildBarChart(planGroups)
                : _buildPieChart(planGroups),
          ),
        ),
        const SizedBox(height: 20),
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
                Text(planName, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart(Map<String, List<RevenueData>> planGroups) {
    // Get unique periods for x-axis labels
    List<Map<String, dynamic>> uniquePeriods = [];
    for (var data in revenueData) {
      if (!uniquePeriods.any((period) => 
          period['year'] == data.period['year'] && 
          period['month'] == data.period['month'] &&
          period['week'] == data.period['week'] &&
          period['day'] == data.period['day'])) {
        uniquePeriods.add(data.period);
      }
    }

    // Sort periods chronologically
    uniquePeriods.sort((a, b) {
      String keyA = "${a['year'] ?? ''}${a['month'] ?? ''}${a['week'] ?? ''}${a['day'] ?? ''}";
      String keyB = "${b['year'] ?? ''}${b['month'] ?? ''}${b['week'] ?? ''}${b['day'] ?? ''}";
      return keyA.compareTo(keyB);
    });

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
                if (value.toInt() >= uniquePeriods.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    formatPeriod(uniquePeriods[value.toInt()]),
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
                  '₹${value.toInt()}',
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
        barGroups: _createBarGroups(planGroups, uniquePeriods),
      ),
    );
  }

  Widget _buildPieChart(Map<String, List<RevenueData>> planGroups) {
    if (planGroups.isEmpty) return const SizedBox();

    // Get the selected period from the cards section
    final groupedPeriods = _getGroupedPeriods();
    if (groupedPeriods.isEmpty) return const SizedBox();

    // Use the selected period data or default to first period
    final currentPeriod = selectedPeriodData ?? groupedPeriods[0]['period'] as Map<String, dynamic>;
    String periodLabel = formatPeriod(currentPeriod);

    // Calculate total revenue for each plan for the selected period
    Map<String, double> planTotals = {};
    double grandTotal = 0;
    
    for (var entry in planGroups.entries) {
      final periodData = entry.value.where((data) =>
          data.period['year'] == currentPeriod['year'] &&
          data.period['month'] == currentPeriod['month'] &&
          (selectedPeriod == 'monthly' || data.period['week'] == currentPeriod['week']) &&
          (selectedPeriod == 'daily' ? data.period['day'] == currentPeriod['day'] : true)).toList();

      if (periodData.isNotEmpty) {
        double total = periodData.fold(0, (sum, data) => sum + data.totalRevenue);
        planTotals[entry.key] = total;
        grandTotal += total;
      }
    }

    if (planTotals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Revenue Data for $periodLabel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Create pie chart sections
    List<PieChartSectionData> sections = [];
    int index = 0;
    planTotals.forEach((planName, total) {
      final percentage = (total / grandTotal * 100);
      sections.add(
        PieChartSectionData(
          color: _getColorForIndex(index),
          value: total,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Revenue Distribution for $periodLabel',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                startDegreeOffset: -90,
                centerSpaceColor: Colors.white,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // Handle touch events if needed
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legend with plan details
          ...planTotals.entries.map((entry) {
            final index = planTotals.keys.toList().indexOf(entry.key);
            final percentage = (entry.value / grandTotal * 100);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getColorForIndex(index),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${entry.key}: ₹${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          Text(
            'Total Revenue for $periodLabel: ₹${grandTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(
      Map<String, List<RevenueData>> planGroups, List<Map<String, dynamic>> uniquePeriods) {
    if (planGroups.isEmpty || revenueData.isEmpty) return [];

    List<BarChartGroupData> barGroups = [];
    final plans = planGroups.keys.toList();

    for (int i = 0; i < uniquePeriods.length; i++) {
      List<BarChartRodData> rods = [];
      for (int j = 0; j < plans.length; j++) {
        final planData = planGroups[plans[j]]!;
        final matchingData = planData.where((data) =>
            data.period['year'] == uniquePeriods[i]['year'] &&
            data.period['month'] == uniquePeriods[i]['month'] &&
            data.period['week'] == uniquePeriods[i]['week'] &&
            data.period['day'] == uniquePeriods[i]['day']).toList();

        if (matchingData.isNotEmpty) {
          rods.add(
            BarChartRodData(
              toY: matchingData[0].totalRevenue,
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

  List<Map<String, dynamic>> _getGroupedPeriods() {
    Map<String, List<RevenueData>> groupedData = {};
    
    for (var data in revenueData) {
      String key = '${data.period['year']}-${data.period['month']}';
      if (selectedPeriod == 'weekly') {
        key += '-${data.period['week']}';
      } else if (selectedPeriod == 'daily') {
        key += '-${data.period['day']}';
      }
      
      if (!groupedData.containsKey(key)) {
        groupedData[key] = [];
      }
      groupedData[key]!.add(data);
    }

    List<Map<String, dynamic>> result = [];
    groupedData.forEach((key, data) {
      result.add({
        'period': data.first.period,
        'data': data,
      });
    });

    // Sort in descending order
    result.sort((a, b) {
      String keyA = '${a['period']['year']}${a['period']['month']}${a['period']['week'] ?? ''}${a['period']['day'] ?? ''}';
      String keyB = '${b['period']['year']}${b['period']['month']}${b['period']['week'] ?? ''}${b['period']['day'] ?? ''}';
      return keyB.compareTo(keyA);
    });

    return result;
  }

  // Add this method to get the selected period data
  Map<String, dynamic> _getSelectedPeriodData() {
    if (revenueData.isEmpty) return {};
    
    // Get unique periods
    Set<String> uniquePeriods = {};
    for (var data in revenueData) {
      String key = '${data.period['year']}-${data.period['month']}';
      if (selectedPeriod == 'weekly') {
        key += '-${data.period['week']}';
      } else if (selectedPeriod == 'daily') {
        key += '-${data.period['day']}';
      }
      uniquePeriods.add(key);
    }

    // Sort periods in descending order
    List<String> sortedPeriods = uniquePeriods.toList()..sort((a, b) => b.compareTo(a));
    
    // Get the first period's data
    String firstPeriod = sortedPeriods.first;
    final parts = firstPeriod.split('-');
    
    return {
      'year': int.parse(parts[0]),
      'month': int.parse(parts[1]),
      if (selectedPeriod == 'weekly') 'week': int.parse(parts[2]),
      if (selectedPeriod == 'daily') 'day': int.parse(parts[2]),
    };
  }

  // Add this method to get available periods
  List<Map<String, dynamic>> _getAvailablePeriods() {
    if (revenueData.isEmpty) return [];

    Set<String> uniquePeriods = {};
    for (var data in revenueData) {
      String key = '${data.period['year']}-${data.period['month']}';
      if (selectedPeriod == 'weekly') {
        key += '-${data.period['week']}';
      } else if (selectedPeriod == 'daily') {
        key += '-${data.period['day']}';
      }
      uniquePeriods.add(key);
    }

    List<String> sortedPeriods = uniquePeriods.toList()..sort((a, b) => b.compareTo(a));
    
    return sortedPeriods.map((period) {
      final parts = period.split('-');
      return {
        'year': int.parse(parts[0]),
        'month': int.parse(parts[1]),
        if (selectedPeriod == 'weekly') 'week': int.parse(parts[2]),
        if (selectedPeriod == 'daily') 'day': int.parse(parts[2]),
      };
    }).toList();
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
              // color: Colors.white,
              iconColor: Colors.white,
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
                ? Center(
                    child:
                        Text(error!, style: const TextStyle(color: Colors.red)))
                : revenueData.isEmpty
                    ? FutureBuilder<List<Gym>>(
                        future: AuthService.server().getUser().then((user) =>
                            Gymserviceprovider.server()
                                .getGymsByowner(user!.userid!)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          final gyms = snapshot.data ?? [];

                          if (gyms.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.business,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Gym Found',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32.0),
                                    child: Text(
                                      'Create a gym to start tracking your revenue analytics',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Gyminfopage()),
                                      );
                                    },
                                    icon: const Icon(Icons.add_business),
                                    label: const Text('Create Gym'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Revenue Data Available',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32.0),
                                    child: Text(
                                      'Start creating gym plans and accepting payments to see your revenue analytics here.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CreatePlansPage()),
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create Gym Plans'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildChart(),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _getGroupedPeriods().length,
                              itemBuilder: (context, index) {
                                final periodGroup = _getGroupedPeriods()[index];
                                final periodLabel = formatPeriod(periodGroup['period']!);
                                final periodData = periodGroup['data'] as List<RevenueData>;
                                
                                // Calculate total revenue for this period
                                double periodTotal = periodData.fold(
                                    0, (sum, data) => sum + data.totalRevenue);

                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ExpansionTile(
                                    onExpansionChanged: (expanded) {
                                      if (expanded) {
                                        setState(() {
                                          selectedPeriodData = periodGroup['period'] as Map<String, dynamic>;
                                        });
                                      }
                                    },
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          periodLabel,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '₹${periodTotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: periodData.map((data) {
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Plan: ${data.planName}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                      const Text('Revenue',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey)),
                                                Text(
                                                  '₹${data.totalRevenue.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                            fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const Text('Transactions',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey)),
                                                Text(
                                                  data.transactionCount
                                                      .toString(),
                                                  style: const TextStyle(
                                                            fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ));
  }
}

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
  RevenueAnalytics? revenueData;
  bool isLoading = true;
  String? error;
  String selectedChartType = 'bar'; // 'bar' or 'pie'
  String? selectedPeriodData;
  late Size mq;
  Map<String, String> planNameCache = {}; // Cache for plan names

  @override
  void initState() {
    super.initState();
    fetchRevenueData();
  }

  Future<String> getPlanName(String id) async {
    try {
      // Check cache first
      if (planNameCache.containsKey(id)) {
        return planNameCache[id]!;
      }
      
      String name = await Gymserviceprovider.server().getPlanNameById(id);
      // Cache the result
      planNameCache[id] = name;
      return name;
    } catch (e) {
      return "Unknown Plan";
    }
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
          revenueData = null;
        });
        return;
      }

      final gymId = gyms[0].gymid;
      final data = await Gymserviceprovider.server()
          .fetchRevenueData(gymId, period: selectedPeriod);
      
      // Populate plan name cache
      if (data != null && data.planSeries.isNotEmpty) {
        for (String planId in data.planSeries.keys) {
          await getPlanName(planId);
        }
      }
      
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

  String formatPeriod(String period) {
    try {
      // Handle weekly format like "W26" or "2024-W26"
      if (period.startsWith('W') || period.contains('-W')) {
        if (period.startsWith('W')) {
          // Format: W26
          return 'Week ${period.substring(1)}';
        } else {
          // Format: 2024-W26
          final parts = period.split('-W');
          if (parts.length == 2) {
            return 'Week ${parts[1]}, ${parts[0]}';
          }
        }
      }
      
      // Handle daily format: YYYY-MM-DD
      if (period.contains('-') && period.split('-').length == 3) {
        final parts = period.split('-');
        if (parts.length == 3) {
          return DateFormat('MMM dd, yyyy').format(DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2])
          ));
        }
      }
      
      // Handle monthly format: YYYY-MM
      if (period.contains('-') && period.split('-').length == 2) {
        final parts = period.split('-');
        if (parts.length == 2) {
          return DateFormat('MMMM yyyy').format(DateTime(
            int.parse(parts[0]),
            int.parse(parts[1])
          ));
        }
      }
      
      // Handle yearly format: YYYY
      if (period.length == 4 && int.tryParse(period) != null) {
        return period;
      }
      
      // If none of the above formats match, return the original string
      return period;
    } catch (e) {
      // If any parsing fails, return the original string
      return period;
    }
  }

  Widget _buildChart() {
    if (revenueData == null) {
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

    final dates = revenueData!.dates;
    final totals = revenueData!.totals;
    final planSeries = revenueData!.planSeries;

    if (dates.isEmpty) {
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
        ],
      );
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
                ? _buildBarChart(dates, totals, planSeries)
                : _buildPieChart(dates, totals, planSeries),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: planSeries.keys.map((planId) {
            final index = planSeries.keys.toList().indexOf(planId);
            return FutureBuilder<String>(
              future: getPlanName(planId),
              builder: (context, snapshot) {
                final planName = snapshot.data ?? planId;
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
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<String> dates, List<double> totals, Map<String, List<double>> planSeries) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxRevenue(totals, planSeries) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBorder: const BorderSide(color: Colors.blueGrey),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₹${rod.toY.toStringAsFixed(2)}',
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
                if (value.toInt() >= dates.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    formatPeriod(dates[value.toInt()]),
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
        barGroups: _createBarGroups(dates, totals, planSeries),
      ),
    );
  }

  Widget _buildPieChart(List<String> dates, List<double> totals, Map<String, List<double>> planSeries) {
    if (dates.isEmpty) return const SizedBox();

    // Use the selected period or default to the most recent
    final currentIndex = selectedPeriodData != null 
        ? dates.indexOf(selectedPeriodData!) 
        : dates.length - 1;
    
    if (currentIndex < 0) return const SizedBox();

    final currentDate = dates[currentIndex];
    final currentTotal = totals[currentIndex];
    
    // Calculate plan revenues for the selected period
    Map<String, double> planRevenues = {};
    double totalRevenue = 0;
    
    planSeries.forEach((planId, revenues) {
      if (currentIndex < revenues.length) {
        planRevenues[planId] = revenues[currentIndex];
        totalRevenue += revenues[currentIndex];
      }
    });

    if (planRevenues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Revenue Data for ${formatPeriod(currentDate)}',
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
    planRevenues.forEach((planId, revenue) {
      final percentage = (revenue / totalRevenue * 100);
      sections.add(
        PieChartSectionData(
          color: _getColorForIndex(index),
          value: revenue,
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
              'Revenue Distribution for ${formatPeriod(currentDate)}',
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
          ...planRevenues.entries.map((entry) {
            final index = planRevenues.keys.toList().indexOf(entry.key);
            final percentage = (entry.value / totalRevenue * 100);
            return FutureBuilder<String>(
              future: getPlanName(entry.key),
              builder: (context, snapshot) {
                final planName = snapshot.data ?? entry.key;
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
                          '$planName: ₹${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
          const SizedBox(height: 16),
          Text(
            'Total Revenue: ₹${totalRevenue.toStringAsFixed(2)}',
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

  List<BarChartGroupData> _createBarGroups(List<String> dates, List<double> totals, Map<String, List<double>> planSeries) {
    List<BarChartGroupData> barGroups = [];
    final planIds = planSeries.keys.toList();

    for (int i = 0; i < dates.length; i++) {
      List<BarChartRodData> rods = [];
      for (int j = 0; j < planIds.length; j++) {
        final planId = planIds[j];
        final revenues = planSeries[planId] ?? [];
        final revenue = i < revenues.length ? revenues[i] : 0.0;
        
        rods.add(
          BarChartRodData(
            toY: revenue,
            color: _getColorForIndex(j),
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        );
      }
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: rods,
          barsSpace: 4,
        ),
      );
    }
    return barGroups;
  }

  double _getMaxRevenue(List<double> totals, Map<String, List<double>> planSeries) {
    double maxRevenue = 0;
    
    // Check totals
    for (var total in totals) {
      if (total > maxRevenue) {
        maxRevenue = total;
      }
    }
    
    // Check plan series
    for (var revenues in planSeries.values) {
      for (var revenue in revenues) {
        if (revenue > maxRevenue) {
          maxRevenue = revenue;
        }
      }
    }
    
    return maxRevenue > 0 ? maxRevenue : 100.0;
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
              const PopupMenuItem(
                value: 'yearly',
                child: Text('Yearly'),
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
              : revenueData == null
                  ? FutureBuilder<List<Gym>>(
                      future: AuthService.server().getUser().then((user) =>
                          Gymserviceprovider.server()
                              .getGymsByowner(user!.userid!)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final gyms = snapshot.data ?? [];

                        if (gyms.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.business, size: 80, color: Colors.grey[400]),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                                      MaterialPageRoute(builder: (context) => Gyminfopage()),
                                    );
                                  },
                                  icon: const Icon(Icons.add_business),
                                  label: const Text('Create Gym'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                                Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                            ),
                          );
                        }
                      },
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildChart(),
                          if (revenueData != null)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: revenueData!.dates.length,
                              itemBuilder: (context, index) {
                                final date = revenueData!.dates[index];
                                final total = revenueData!.totals[index];
                                
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ExpansionTile(
                                    onExpansionChanged: (expanded) {
                                      if (expanded) {
                                        setState(() {
                                          selectedPeriodData = date;
                                        });
                                      }
                                    },
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatPeriod(date),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '₹${total.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: revenueData!.planSeries.entries.map((entry) {
                                      final planId = entry.key;
                                      final revenues = entry.value;
                                      final revenue = index < revenues.length ? revenues[index] : 0.0;
                                      
                                      return FutureBuilder<String>(
                                        future: getPlanName(planId),
                                        builder: (context, snapshot) {
                                          final planName = snapshot.data ?? planId;
                                          return Card(
                                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Plan: $planName',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
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
                                                            'Revenue',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          Text(
                                                            '₹${revenue.toStringAsFixed(2)}',
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.green,
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
                                      );
                                    }).toList(),
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

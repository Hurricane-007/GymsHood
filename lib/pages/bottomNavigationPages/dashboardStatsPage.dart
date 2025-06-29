import 'package:flutter/material.dart';
import '../../services/Models/memberGrowthModel.dart';
import '../../services/gymInfo/gym_server_provider.dart';

class DashboardStatsPage extends StatefulWidget {
  final String gymId;
  const DashboardStatsPage({Key? key, required this.gymId}) : super(key: key);

  @override
  State<DashboardStatsPage> createState() => _DashboardStatsPageState();
}

class _DashboardStatsPageState extends State<DashboardStatsPage> {
  late Future<DashboardResponse> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = GymServerProvider().fetchMemberResponse(widget.gymId);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = const Color(0xFFF6F8FB);
    final cardColor = Colors.white;
    final accentColor = Colors.white;
    return Container(
      color: backgroundColor,
      child: FutureBuilder<DashboardResponse>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Distribution
                Card(
                  color: accentColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Icon(Icons.people, color: Colors.white),
                    ),
                    title: Text('Total Active Users', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                    subtitle: Text(
                      data.planDistribution.totalActiveUsers.toString(),
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Plan Breakdown:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 8),
                Card(
                  color: cardColor,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: data.planDistribution.byPlan.entries.map((entry) {
                      final planInfo = entry.value;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor.withOpacity(0.1)),
                            ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getPlanIcon(planInfo.planType),
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    planInfo.planName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getPlanTypeColor(planInfo.planType).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      planInfo.planType.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getPlanTypeColor(planInfo.planType),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${planInfo.count}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                          ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 40, thickness: 1.2),
                // Member Growth
                Text('Member Growth', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 8),
                _buildGrowthSection('Daily', data.memberGrowth.daily, primaryColor, accentColor),
                _buildGrowthSection('Weekly', data.memberGrowth.weekly, primaryColor, accentColor),
                _buildGrowthSection('Monthly', data.memberGrowth.monthly, primaryColor, accentColor),
                _buildGrowthSection('Yearly', data.memberGrowth.yearly, primaryColor, accentColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrowthSection(String title, GrowthData growth, Color primaryColor, Color accentColor) {
    return Card(
      color: accentColor,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        title: Text(title, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Count')),
                DataColumn(label: Text('Cumulative')),
              ],
              rows: List.generate(
                growth.dates.length,
                (i) => DataRow(cells: [
                  DataCell(Text(growth.dates[i])),
                  DataCell(Text(growth.counts[i].toString())),
                  DataCell(Text(growth.cumulative[i].toString())),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlanIcon(String planType) {
    switch (planType.toLowerCase()) {
      case 'monthly':
        return Icons.calendar_month;
      case 'weekly':
        return Icons.calendar_view_week;
      case 'daily':
        return Icons.today;
      case 'yearly':
        return Icons.calendar_today;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getPlanTypeColor(String planType) {
    switch (planType.toLowerCase()) {
      case 'monthly':
        return Colors.blue;
      case 'weekly':
        return Colors.green;
      case 'daily':
        return Colors.orange;
      case 'yearly':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 
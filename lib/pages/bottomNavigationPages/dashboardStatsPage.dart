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
                    children: data.planDistribution.byPlan.entries.map((e) => ListTile(
                          leading: Icon(Icons.fitness_center, color: primaryColor),
                          title: Text(e.key, style: TextStyle(fontWeight: FontWeight.w500)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(e.value.toString(), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          ),
                        )).toList(),
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
} 
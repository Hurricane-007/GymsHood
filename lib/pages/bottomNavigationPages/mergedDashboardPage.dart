import 'package:flutter/material.dart';
import '../memberRegisterPage.dart';
import 'dashboardStatsPage.dart';
import '../../services/Models/registerModel.dart';

class MergedDashboardPage extends StatelessWidget {
  final String gymId;
  final List<RegisterEntry> activeUsers;
  final List<RegisterEntry> expiredUsers;

  const MergedDashboardPage({
    Key? key,
    required this.gymId,
    required this.activeUsers,
    required this.expiredUsers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = const Color(0xFFF6F8FB);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
          leading: BackButton(color: Colors.white,),
          centerTitle: true,
          backgroundColor: primaryColor,
          bottom: TabBar(
            indicator: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Members', icon: Icon(Icons.people)),
              Tab(text: 'Stats', icon: Icon(Icons.bar_chart)),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              color: Colors.white,
              child: TabBarView(
                children: [
                  MemberRegisterPage(
                    activeUsers: activeUsers,
                    expiredUsers: expiredUsers,
                  ),
                  DashboardStatsPage(gymId: gymId),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
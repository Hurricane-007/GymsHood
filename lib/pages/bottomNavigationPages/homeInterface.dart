import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/pages/announcementPage.dart';
import 'package:gymshood/pages/createServicesPages/Gyminfopage.dart';
import 'package:gymshood/pages/fullScreenVideoandImage/FullScreenPage.dart';
import 'package:gymshood/pages/verifydocumentPage.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/gymDashboardStats.dart';
import 'package:gymshood/services/Models/registerModel.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class HomeInterface extends StatefulWidget {
  const HomeInterface({super.key});

  @override
  State<HomeInterface> createState() => _HomeInterfaceState();
}

class _HomeInterfaceState extends State<HomeInterface> {
  String name = '';
  List<RegisterEntry> activeUsers = [];
  List<RegisterEntry> expiredUsers = [];
  Gym? gym;
  bool isLoading = true;

  Future<void> initializeData() async {
    try {
      final Authuser? user = await AuthService.server().getUser();
      final gyms = await Gymserviceprovider.server().getGymsByowner(user!.userid!);
      if (mounted) {
        setState(() {
          name = user.name ?? '';
          gym = gyms[0];
          isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> loadActiveUsers(String gymId) async {
    try {
      final response = await Gymserviceprovider.server().getactiveUserResponse(gymId);
      if (mounted) {
        setState(() {
          activeUsers = response.activeUsers;
          expiredUsers = response.expiredUsers;
        });
      }
    } catch (e) {
      developer.log('Error loading active users: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: mq.width * 0.38),
              child: Text("Home", style: TextStyle(color: Colors.white)),
            ),
            Spacer(),
            Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementPage(),
                    ),
                  ),
                  child: Icon(
                    Icons.campaign,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : gym == null
              ? Center(
                  child: Container(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Hello $name!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Welcome to Gymshood',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Gyminfopage(),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_business),
                                SizedBox(width: 8),
                                Text(
                                  "Register Your Gym",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (gym != null && !gym!.isverified) ...[
                        Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(50),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange.withAlpha(70),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pending_actions, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'Pending Verification',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              width: mq.width * 0.95,
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                shadowColor: Colors.grey,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        Colors.blue,
                                        Theme.of(context).colorScheme.tertiary
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                gym!.name,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Address: ${gym!.location.address}',
                                                style: TextStyle(color: Colors.white),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Status: ${gym!.status.toString().split('.').last}',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              const Spacer(),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              VerifyDocuments(
                                                                  gym: gym!)));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor:
                                                      Theme.of(context).primaryColor,
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 8),
                                                ),
                                                child: Text(
                                                  'Verify Documents',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        GestureDetector(
                                          onTap: () =>
                                              gym!.media?.mediaUrls?.isNotEmpty == true
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              FullScreenImagePage(
                                                                imageUrl: gym!.media
                                                                        ?.logoUrl ??
                                                                    '',
                                                                gym: gym!,
                                                              )))
                                                  : null,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                mq.height * 0.1),
                                            child: (gym!.media?.logoUrl != null &&
                                                    gym!.media!.logoUrl
                                                        .trim()
                                                        .isNotEmpty)
                                                ? Image.network(
                                                    gym!.media!.logoUrl,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (context, error, stackTrace) {
                                                      return Container(
                                                        width: 100,
                                                        height: 100,
                                                        color: Colors.grey[300],
                                                        child: Icon(Icons.error,
                                                            color: Colors.grey[600]),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    width: 100,
                                                    height: 100,
                                                    color: Colors.grey[300],
                                                    child: Icon(
                                                        Icons.image_not_supported,
                                                        color: Colors.grey[600]),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (gym?.isverified == true) ...[
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Member Register',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: mq.width * 0.85,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.people, color: Colors.green[700], size: 20),
                                            SizedBox(width: 4),
                                            Text(
                                              'Active Members: ${activeUsers.length}',
                                              style: TextStyle(
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[50],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_off, color: Colors.orange[700], size: 20),
                                            SizedBox(width: 4),
                                            Text(
                                              'Expired: ${expiredUsers.length}',
                                              style: TextStyle(
                                                color: Colors.orange[700],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Active Members',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  if (activeUsers.isEmpty)
                                    Center(
                                      child: Text(
                                        'No active members',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: activeUsers.length,
                                      itemBuilder: (context, index) {
                                        final user = activeUsers[index];
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                                backgroundImage: user.photo != null ? NetworkImage(user.photo!) : null,
                                                child: user.photo == null
                                                    ? Text(
                                                        user.userName[0].toUpperCase(),
                                                        style: TextStyle(
                                                          color: Theme.of(context).primaryColor,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      user.userName,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      user.contactNo ?? 'No contact number',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (user.checkInTime != null)
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[50],
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    'Checked In',
                                                    style: TextStyle(
                                                      color: Colors.green[700],
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  SizedBox(height: 24),
                                  Text(
                                    'Expired Memberships',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  if (expiredUsers.isEmpty)
                                    Center(
                                      child: Text(
                                        'No expired memberships',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: expiredUsers.length,
                                      itemBuilder: (context, index) {
                                        final user = expiredUsers[index];
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.orange[100]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor: Colors.orange[100],
                                                backgroundImage: user.photo != null ? NetworkImage(user.photo!) : null,
                                                child: user.photo == null
                                                    ? Text(
                                                        user.userName[0].toUpperCase(),
                                                        style: TextStyle(
                                                          color: Colors.orange[700],
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      user.userName,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      user.contactNo ?? 'No contact number',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Gym Analytics',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: mq.width * 0.85,
                            height: mq.height * 0.25,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.lightBlueAccent),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.fitness_center,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            gym!.name,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: gym!.isverified
                                                ? Colors.green
                                                : Colors.orange,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            gym!.isverified ? 'Verified' : 'Pending',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    FutureBuilder<GymDashboardStats>(
                                      future: Gymserviceprovider.server()
                                          .getgymDashBoardStatus(gym!.gymid),
                                      builder: (context, statsSnapshot) {
                                        if (statsSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context).primaryColor,
                                              strokeWidth: 2,
                                            ),
                                          );
                                        }

                                        if (statsSnapshot.hasError) {
                                          return Text(
                                            'Error loading stats',
                                            style: TextStyle(color: Colors.red),
                                          );
                                        }

                                        final stats = statsSnapshot.data;
                                        if (stats == null) {
                                          return Text(
                                            'No stats available',
                                            style: TextStyle(color: Colors.grey),
                                          );
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total Nearby Users: ${stats.totalNearbyUsers}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Potential Customers: ${stats.potentialCustomers.length}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
    );
  }
}

import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/pages/announcementPage.dart';
import 'package:gymshood/pages/bottomNavigationPages/mergedDashboardPage.dart';
import 'package:gymshood/pages/createServicesPages/Gyminfopage.dart';
import 'package:gymshood/pages/fullScreenVideoandImage/FullScreenPage.dart';
import 'package:gymshood/pages/generateQrPage.dart';
import 'package:gymshood/pages/verifydocumentPage.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/gymDashboardStats.dart';
import 'package:gymshood/services/Models/registerModel.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';
import 'package:gymshood/services/Models/announcementModel.dart';
import 'package:intl/intl.dart';

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
  List<GymAnnouncement> announcements = [];

  Future<void> initializeData() async {
    try {
      final Authuser? user = await AuthService.server().getUser();
      final gyms =
          await Gymserviceprovider.server().getGymsByowner(user!.userid!);
      if (mounted) {
        setState(() {
          name = user.name ?? '';
          gym = gyms[0];
          isLoading = false;
          loadActiveUsers(gym!.gymid);
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
      final response =
          await Gymserviceprovider.server().getactiveUserResponse(gymId);
      if (mounted) {
        setState(() {
          activeUsers = response.activeUsers;
          expiredUsers = response.expiredUsers;
        });
      }
      developer.log("number of active users ${activeUsers.length}");
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                style: TextStyle(
                                                    color: Colors.white),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Status: ${gym!.status.toString().split('.').last}',
                                                style: TextStyle(
                                                    color: Colors.white),
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
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                                ),
                                                child: Text(
                                                  'Verify Documents',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        GestureDetector(
                                          onTap: () => gym!.media?.mediaUrls
                                                      ?.isNotEmpty ==
                                                  true
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
                                            child: (gym!.media?.logoUrl !=
                                                        null &&
                                                    gym!.media!.logoUrl
                                                        .trim()
                                                        .isNotEmpty)
                                                ? Image.network(
                                                    gym!.media!.logoUrl,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        width: 100,
                                                        height: 100,
                                                        color: Colors.grey[300],
                                                        child: Icon(Icons.error,
                                                            color: Colors
                                                                .grey[600]),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    width: 100,
                                                    height: 100,
                                                    color: Colors.grey[300],
                                                    child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color:
                                                            Colors.grey[600]),
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
                        // SizedBox(height: 10),
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MergedDashboardPage(
                                  gymId: gym!.gymid,
                                   activeUsers: activeUsers,
                                    expiredUsers: expiredUsers)
                              ),
                            );
                          },
                          child: Container(
                            width: mq.width * 0.85,
                            child: Card(
                              elevation: 5,
                              color: Theme.of(context).colorScheme.tertiary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.people,
                                                  color: Colors.green[700],
                                                  size: 20),
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.person_off,
                                                  color: Colors.orange[700],
                                                  size: 20),
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
                                    SizedBox(height: 16),
                                    Center(
                                      child: Text(
                                        'Tap to view detailed member register',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
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
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: mq.width * 0.9,
                            ),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Theme.of(context).colorScheme.tertiary),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.fitness_center,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            gym!.name,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                    .withAlpha(500)),
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            gym!.isverified
                                                ? 'Verified'
                                                : 'Pending',
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
                                              color: Theme.of(context)
                                                  .primaryColor,
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
                                            style:
                                                TextStyle(color: Colors.grey),
                                          );
                                        }

                                        return Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize
                                                .min, // Prevents Column from expanding infinitely
                                            children: [
                                              Text(
                                                'Total Nearby Users: ${stats.totalNearbyUsers}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Potential Customers: ${stats.potentialCustomers.length}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                              SizedBox(height: 12),
                                              // QR Code Reminder Message
                                              Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[50],
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.blue[200]!),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.qr_code,
                                                      color: Colors.blue[700],
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'QR Code Setup Reminder',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.blue[700],
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'If you haven\'t created QR codes yet, please generate them and place them strategically in your gym for member access.',
                                                            style: TextStyle(
                                                              color: Colors.blue[600],
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => QrPage(),
                                                          ),
                                                        );
                                                      },
                                                      icon: Icon(Icons.qr_code, color: Colors.white),
                                                      label: Text(
                                                        'Generate QR Codes',
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Theme.of(context).primaryColor,
                                                        padding: EdgeInsets.symmetric(vertical: 8),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                      ),
                      if (gym?.isverified == true) ...[
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                'Recent Announcements by Admin',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        FutureBuilder<List<GymAnnouncement>>(
                          future: Gymserviceprovider.server().getGymAnnouncements(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading announcements',
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            announcements = snapshot.data ?? [];
                            if (announcements.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.announcement_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'No announcements yet',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: announcements.length > 3 ? 3 : announcements.length,
                              itemBuilder: (context, index) {
                                final announcement = announcements[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // boxShadow: [BoxShadow(color: Colors.black) , BoxShadow(color: Colors.deepPurpleAccent)],
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white,
                                          Colors.grey[50]!,
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withAlpha(50),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.campaign,
                                                  color: Theme.of(context).primaryColor,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    announcement.title ?? 'Announcement',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            announcement.message,
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                DateFormat('MMM d, y • h:mm a').format(announcement.createdAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        if (announcements.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnnouncementPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'View Your Announcements',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

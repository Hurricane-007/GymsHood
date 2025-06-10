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
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class HomeInterface extends StatefulWidget {
  const HomeInterface({super.key});

  @override
  State<HomeInterface> createState() => _HomeInterfaceState();
}

class _HomeInterfaceState extends State<HomeInterface> {
  Future<List<Gym>> getGymsOfOwner() async {
    final Authuser? user = await AuthService.server().getUser();
    if (user != null) {
      return await Gymserviceprovider.server().getGymsByowner(user.userid!);
    }
    return [];
  }

  String name = '';
  int unseenAnnouncements = 0;

  Future<String> getname() async {
    final Authuser? user = await AuthService.server().getUser();
    return user!.name!;
  }

  Future<void> _loadUnseenAnnouncements() async {
    // TODO: Replace with actual API call to get unseen announcements count
    // For now using a dummy value
    setState(() {
      unseenAnnouncements = 3; // Replace this with actual API call
    });
  }

  @override
  void initState() {
    super.initState();
    _loadName();
    _loadUnseenAnnouncements();
  }

  Future<void> _loadName() async {
    final userName = await getname();
    setState(() {
      name = userName;
    });
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
                if (unseenAnnouncements > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        unseenAnnouncements.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Gym>>(
        future: getGymsOfOwner(),
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
                'Error loading gyms: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final allGyms = snapshot.data ?? [];

          if (allGyms.isEmpty) {
            return Center(
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
            );
          }

          final Gym? gym = allGyms.isEmpty ? null : allGyms.first;
          // final name = Authservice.server

          return SingleChildScrollView(
            child: Column(
              children: [
                if (gym != null && !gym.isverified) ...[
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
                                          gym.name,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Address: ${gym.location.address}',
                                          style: TextStyle(color: Colors.white),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Status: ${gym.status.toString().split('.').last}',
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
                                                            gym: gym)));
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
                                        gym.media?.mediaUrls?.isNotEmpty == true
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullScreenImagePage(
                                                          imageUrl: gym.media
                                                                  ?.logoUrl ??
                                                              '',
                                                          gym: gym,
                                                        )))
                                            : null,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          mq.height * 0.1),
                                      child: (gym.media?.logoUrl != null &&
                                              gym.media!.logoUrl
                                                  .trim()
                                                  .isNotEmpty)
                                          ? Image.network(
                                              gym.media!.logoUrl,
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
                                      color: gym.isverified
                                          ? Colors.green
                                          : Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      gym.isverified ? 'Verified' : 'Pending',
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
                                    .getgymDashBoardStatus(gym.gymid),
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
          );
        },
      ),
    );
  }
}

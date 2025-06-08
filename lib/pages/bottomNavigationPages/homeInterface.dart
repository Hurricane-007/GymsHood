import 'package:flutter/material.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/pages/createServicesPages/Gyminfopage.dart';
import 'package:gymshood/pages/fullScreenVideoandImage/FullScreenPage.dart';
import 'package:gymshood/pages/verifydocumentPage.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/gymDashboardStats.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';

class HomeInterface extends StatelessWidget {
  const HomeInterface({super.key});

  Future<List<Gym>> getGymsOfOwner() async {
    final Authuser? user = await AuthService.server().getUser();
    if (user != null) {
      return await Gymserviceprovider.server().getGymsByowner(user.userid!);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Home", style: TextStyle(color: Colors.white)),
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
          final unverifiedGyms = allGyms.where((gym) => !gym.isverified).toList();

          if (allGyms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 50,
                  ),
                  Text(
                    "Please register your gym first",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Gyminfopage(),
                      ),
                    ),
                    child: Text(
                      "Register gym",
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unverifiedGyms.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Pending Verification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: unverifiedGyms.length,
                    itemBuilder: (context, index) {
                      final gym = unverifiedGyms[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        ),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        gym.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Address: ${gym.location.address}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Status: ${gym.status.toString().split('.').last}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyDocuments(gym: gym)));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Theme.of(context).primaryColor,
                                        ),
                                        child: Text(
                                          'Verify Documents',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => gym.media?.mediaUrls?.isNotEmpty == true ? 
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => 
                                      FullScreenImagePage(imageUrl: gym.media?.logoUrl ?? '')
                                    )) : null,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(mq.height*0.1),
                                    child: gym.media?.mediaUrls?.isNotEmpty == true ? Image.network(
                                      gym.media?.logoUrl ?? '',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.error, color: Colors.grey[600]),
                                        );
                                      },
                                    ) : Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: allGyms.length,
                  itemBuilder: (context, index) {
                    final gym = allGyms[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      elevation: 4,
                      child: Container(
                           decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.lightBlueAccent
                          ),
                          
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary),
                                SizedBox(width: 8),
                                Text(
                                  gym.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: gym.isverified ? Colors.green : Colors.orange,
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
                              future: Gymserviceprovider.server().getgymDashBoardStatus(gym.gymid),
                              builder: (context, statsSnapshot) {
                                if (statsSnapshot.connectionState == ConnectionState.waiting) {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
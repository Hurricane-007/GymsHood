import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/Utilities/Dialogs/showLogout_dialog.dart';
import 'package:gymshood/Utilities/helpers/enum.dart';
import 'package:gymshood/pages/Gyminfopage.dart';
import 'package:gymshood/pages/TabBarPages.dart/AboutTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/equipmentTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/photostabbar.dart';
import 'package:gymshood/pages/TabBarPages.dart/reviewsTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/videoTabbar.dart';
import 'package:gymshood/pages/addGymMediaPage.dart';
import 'package:gymshood/pages/createplansPage.dart';
import 'package:gymshood/pages/plans.dart';
import 'package:gymshood/sevices/Models/AuthUser.dart';
import 'package:gymshood/sevices/Auth/auth_service.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Models/gym.dart';
import 'package:gymshood/sevices/gymInfo/gymserviceprovider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Authuser? authuser;
  String? name;
  late Size mq;
   num rating = 0;
   String about = '';
   List<String> equipment=[];
  // final Gym gym; 
  Future<void> _getuser() async {
    authuser = await AuthService.server().getUser();
    setState(() {
      name = authuser?.name ?? 'GYM NAME';
    });
  }

Future<void> getRating() async {
  final Authuser? user = await AuthService.server().getUser();
  final List<Gym> gym = await Gymserviceprovider.server().getAllGyms(search: user!.userid);

  if (gym.isNotEmpty) {
    final String gymId = gym[0].gymid;
    final Gym gymi = await Gymserviceprovider.server().getGymDetails(id: gymId);

    setState(() {
      about = gymi.about;
      rating = gymi.avgrating;
      equipment=gymi.equipmentList;
    });

    // developer.log("About text: $about");
  }
}

  @override
  void initState() {
    super.initState();
    getRating();
    _tabController = TabController(length: 5, vsync: this);
    _getuser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          PopupMenuButton<MenuAction>(
            color: Theme.of(context).colorScheme.primary,
            iconColor: Colors.white,
            onSelected: (value) async {
                switch(value){
                  case MenuAction.addGyminfo:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Gyminfopage(),));
                  case MenuAction.addGymMedia:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UploadMultipleImagesPage(),));
                  case MenuAction.createPlan:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePlansPage(),));
                  case MenuAction.logout:
                  context.read<AuthBloc>().add(AuthEventLogOut());
                }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: MenuAction.addGyminfo,
                child:
                 Text('Add Gym Info', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: MenuAction.addGymMedia,
                child:
                 Text('Add Gym Media', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: MenuAction.createPlan,
                child:
                 Text('Create Gym Plans', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: MenuAction.logout,
                child:
                 Text('Logout', style: TextStyle(color: Colors.white)),
              ),
              
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: mq.height * 0.02),
              child: Column(
                children: [
                  ClipOval(
                    child: Container(
                      width: mq.height * 0.15,
                      height: mq.height * 0.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Icon(CupertinoIcons.person, size: mq.height * 0.1),
                    ),
                  ),
                  SizedBox(height: mq.height * 0.01),
                  Text(
                    name ?? 'GYM NAME',
                    style: TextStyle(
                      fontSize: mq.height * 0.025,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text("Gym slogan", style: TextStyle(color: Colors.black54)),
                  SizedBox(height: mq.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 4),
                      Text("$rating"),
                      Spacer(),
                      Text("16 Followers"),
                    ],
                  ),
                  SizedBox(height: mq.height * 0.01),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: "PHOTO"),
                  Tab(text: "VIDEO"),
                  Tab(text: "EQUIPMENT"),
                  Tab(text: "REVIEWS"),
                  Tab(text: "ABOUT"),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children:  [
            PhotosTabBar(),
            VideoTabBar(),
            EquipmentTabBar(list: equipment,),
            ReviewsTabBar(),
            AboutTabBar(aboutText: about,),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return oldDelegate._tabBar != _tabBar;
  }
}

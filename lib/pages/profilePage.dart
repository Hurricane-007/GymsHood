import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/Utilities/Dialogs/showLogout_dialog.dart';
import 'package:gymshood/Utilities/helpers/enum.dart';
import 'package:gymshood/pages/FullScreenPage.dart';
import 'package:gymshood/pages/Gyminfopage.dart';
import 'package:gymshood/pages/TabBarPages.dart/AboutTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/equipmentTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/photostabbar.dart';
import 'package:gymshood/pages/TabBarPages.dart/reviewsTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/videoTabbar.dart';
import 'package:gymshood/pages/addGymMediaPage.dart';
import 'package:gymshood/pages/createplansPage.dart';
import 'package:gymshood/pages/plans.dart';
import 'package:gymshood/pages/shiftSchedulerPage.dart';
import 'package:gymshood/pages/updateGymdetailspage.dart';
import 'package:gymshood/services/Models/AuthUser.dart';
import 'package:gymshood/services/Auth/auth_service.dart';
import 'package:gymshood/services/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/services/Auth/bloc/auth_event.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/fileserver.dart';
import 'package:gymshood/services/gymInfo/gymserviceprovider.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Authuser? authuser;
  String? name;
  late Size mq;
  num rating = 0;
  String about = '';
  List<String> equipment = [];
  String? _image;
  List<Gym> gyms = [];
  Gym? selectedGym;
  String dropdownValue = '';
  // final Gym gym;
  Future<void> _getuser() async {
    authuser = await AuthService.server().getUser();
    setState(() {
      name = authuser?.name ?? 'GYM NAME';
    });
  }

  Future<void> getRating() async {
    final Authuser? user = await AuthService.server().getUser();
    gyms = await Gymserviceprovider.server().getGymsByowner(user!.userid!);

    if (gyms.isNotEmpty) {
      selectedGym = gyms[0];
      dropdownValue = selectedGym!.name;

      final List<String> images =
          await Fileserver().fetchMediaUrls('Logo', selectedGym!.gymid);

      _updateGymDetails(selectedGym!, images);
    }

    setState(() {});
  }

  void _updateGymDetails(Gym gymi, List<String> images) {
    setState(() {
      about = gymi.about;
      rating = gymi.avgrating;
      equipment = gymi.equipmentList;
      _image = images.isNotEmpty ? images.last : null;
    });
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
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Theme.of(context).colorScheme.primary,
            value: dropdownValue,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: gyms.map((gym) {
              return DropdownMenuItem<String>(
                value: gym.name,
                child:
                    Text(gym.name, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (String? newValue) async {
              final Gym? selected = gyms.firstWhere((g) => g.name == newValue);

              if (selected != null) {
                selectedGym = selected;
                dropdownValue = selected.name;

                final images = await Fileserver()
                    .fetchMediaUrls('Logo', selectedGym!.gymid);

                _updateGymDetails(selectedGym!, images);
              }
            },
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<MenuAction>(
            color: Theme.of(context).colorScheme.primary,
            iconColor: Colors.white,
            onSelected: (value) async {
              switch (value) {
                case MenuAction.addGyminfo:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Gyminfopage(),
                      ));
                case MenuAction.updateGymInfo:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateGymDetailsPage(),
                      ));
                case MenuAction.addGymMedia:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadMultipleImagesPage(
                          gym: selectedGym!,
                        ),
                      ));
                case MenuAction.createPlan:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePlansPage(),
                      ));
                case MenuAction.logout:
                  context.read<AuthBloc>().add(AuthEventLogOut());
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: MenuAction.addGyminfo,
                child:
                    Text('Register Gym', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: MenuAction.updateGymInfo,
                child: Text(
                  "Update Gym Info",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              PopupMenuItem(
                value: MenuAction.addGymMedia,
                child: Text('Add Gym Media',
                    style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: MenuAction.createPlan,
                child: Text('Create Gym Plans',
                    style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: MenuAction.logout,
                child: Text('Logout', style: TextStyle(color: Colors.white)),
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
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: SizedBox(
                                  width: mq.height * 0.15,
                                  height: mq.height * 0.15,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onLongPress: () async {
                                          final uri = Uri.parse(_image!);
                                          final path = uri.path.toLowerCase();
                                          final filename =
                                              uri.pathSegments.isNotEmpty
                                                  ? uri.pathSegments.last
                                                      .toLowerCase()
                                                  : '';
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Text(
                                                'Delete Plan',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete this plan?',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child:
                                                        const Text('Cancel')),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    child:
                                                        const Text('Delete')),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            // final planId = plans[index].id;
                                            final success = await Fileserver()
                                                .deleteFileFromServer(filename);
                                            // Implement this in your service
                                            setState(() {
                                              getRating();
                                            });
                                            if (success) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'profile photo deleted successfully')),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Failed to delete profile photo')),
                                              );
                                            }
                                          }
                                        },
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenImagePage(
                                                      imageUrl: _image!),
                                            )),
                                        child: Image.network(
                                          _image!,
                                          height: mq.height * 0.2,
                                          fit: BoxFit.cover,
                                        )),
                                  )))
                          : ClipOval(
                              child: Container(
                                width: mq.height * 0.15,
                                height: mq.height * 0.15,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Icon(CupertinoIcons.person,
                                    size: mq.height * 0.1),
                              ),
                            ),
                      Positioned(
                        top: 70,
                        left: 75,
                        child: Material(
                          shape: CircleBorder(),
                          elevation: 2,
                          color: Colors.white,
                          child: IconButton(
                            // constraints:BoxConstraints.tight(Size(20,10)) ,
                            onPressed: () => _showBottomSheet(),
                            icon: Icon(Icons.edit),
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    ],
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
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 4),
                      Text("$rating"),
                      Spacer(),
                      Text(""),
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
        body: selectedGym == null
            ? const Center(child: CircularProgressIndicator())
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  // ... existing headerSliverBuilder content
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    PhotosTabBar(gym: selectedGym!),
                    VideoTabBar(gym: selectedGym!),
                    EquipmentTabBar(list: equipment),
                    ReviewsTabBar(),
                    AboutTabBar(aboutText: about),
                  ],
                ),
              ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20))),
        backgroundColor: Theme.of(context).primaryColor,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pick Your Profile Picture',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
              SizedBox(
                height: mq.height * 0.1,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: mq.height * 0.1,
                      child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();

                            // Pick an image.
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (image != null) {
                              await Fileserver().uploadToServer(
                                  File(image.path), 'Logo', selectedGym!.gymid);
                              final imageUrl = await Fileserver()
                                  .fetchMediaUrls('Logo', selectedGym!.gymid);
                              // Gymserviceprovider.server().addGymMedia(mediaType: 'photo', mediaUrl: "", logourl: image.path);
                              setState(() {
                                _image = imageUrl.last;
                                getRating();
                              });
                              //update the profile with set state
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: SizedBox(
                              height: mq.height * 0.08,
                              child: Image.asset(
                                  "assets/images/galleryImage.png"))),
                    ),

                    //set image from camera
                    SizedBox(
                      height: mq.height * 0.1,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();

                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera);
                            if (image != null) {
                              await Fileserver().uploadToServer(
                                  File(image.path), 'Logo', selectedGym!.gymid);
                              final imageUrl = await Fileserver()
                                  .fetchMediaUrls('Logo', selectedGym!.gymid);
                              // Gymserviceprovider.server().addGymMedia(mediaType: 'photo', mediaUrl: "", logourl: image.path);
                              setState(() {
                                _image = imageUrl.last;
                                getRating();
                              });
                            }
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                              height: mq.height * 0.08,
                              child: Image.asset("assets/images/camera.png"))),
                    )
                  ],
                ),
              )
            ],
          );
        });
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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

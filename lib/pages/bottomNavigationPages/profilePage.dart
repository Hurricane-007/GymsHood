import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:gymshood/Utilities/Dialogs/showLogout_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/showdeletedialog.dart';
import 'package:gymshood/pages/fullScreenVideoandImage/FullScreenPage.dart';
import 'package:gymshood/pages/createServicesPages/Gyminfopage.dart';
import 'package:gymshood/pages/TabBarPages.dart/AboutTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/equipmentTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/photostabbar.dart';
import 'package:gymshood/pages/TabBarPages.dart/reviewsTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/videoTabbar.dart';
import 'package:gymshood/pages/createServicesPages/addGymMediaPage.dart';
import 'package:gymshood/pages/createServicesPages/createplansPage.dart';
// import 'package:gymshood/pages/bottomNavigationPages/plans.dart';
import 'package:gymshood/pages/updateGymdetailspage.dart';
import 'package:gymshood/services/Helpers/enum.dart';
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
  late Size mq;

  Authuser? authuser;
  String? name;
  num rating = 0;
  String about = '';
  List<String> equipment = [];
  String? _image;
  List<Gym> gyms = [];
  Gym? selectedGym;
  String dropdownValue = '';
  // final Gym gym;
  late Future<void> _profileFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _profileFuture = _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    try {
      // Fetch auth user info
      authuser = await AuthService.server().getUser();

      // Avoid null crash
      if (authuser?.userid == null) {
        developer.log('User ID is null', name: 'ProfilePage');
        return;
      }
      gyms =
          await Gymserviceprovider.server().getGymsByowner(authuser!.userid!);
      if (gyms.isNotEmpty) {
        selectedGym = gyms[0];
        developer.log('profile page gym id ${selectedGym!.gymid}');
        dropdownValue = selectedGym!.name;

        name = authuser?.name ?? 'NAME';
        about = selectedGym!.about;
        rating = selectedGym!.avgrating;
        equipment = selectedGym!.equipmentList;
        _image = selectedGym!.media?.logoUrl;
      }
    } catch (e, stacktrace) {
      developer.log('Error in _initializeProfile',
          name: 'ProfilePage', error: e, stackTrace: stacktrace);
    }

    // Trigger rebuild after all async work is done
    if (mounted) setState(() {});
  }

  void _updateGymDetails(Gym gymi) {
    setState(() {
      about = gymi.about;
      rating = gymi.avgrating;
      equipment = gymi.equipmentList;
      _image = gymi.media?.logoUrl;
    });
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
            value: dropdownValue.isNotEmpty ? dropdownValue : null,
            hint: const Text(
              'Select Gym',
              style: TextStyle(color: Colors.white),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: gyms.map((gym) {
              return DropdownMenuItem<String>(
                value: gym.name,
                child: Text(
                  gym.name,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) async {
              if (newValue == null) return;

              final Gym? selected = gyms.firstWhere(
                (g) => g.name == newValue,
              );

              if (selected != null) {
                setState(() {
                  selectedGym = selected;
                  dropdownValue = selected.name;
                });

                if (mounted) {
                  _updateGymDetails(selected);
                }
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
      body: FutureBuilder(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (selectedGym == null) {
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
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Gyminfopage(),
                          )),
                      child: Text(
                        "Register gym",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      )),
                ],
              ));
            }
            return NestedScrollView(
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
                                                final filename =
                                                    uri.pathSegments.isNotEmpty
                                                        ? uri.pathSegments.last
                                                            .toLowerCase()
                                                        : '';
                                                final confirm =
                                                    await showDeleteDialog(
                                                        context);
                                                if (confirm == true) {
                                                  final success =
                                                      await Fileserver()
                                                          .deleteFileFromServer(
                                                              filename);
                                                  if (success) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'profile photo deleted successfully')),
                                                    );
                                                    setState(() {
                                                      _image = null;
                                                    });
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
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
                        Text(selectedGym!.gymslogan,
                            style: TextStyle(color: Colors.black54)),
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
                  ? Center(
                      child: ElevatedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Gyminfopage(),
                              )),
                          child: Text("Create Gym")))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        PhotosTabBar(gym: selectedGym!),
                        VideoTabBar(gym: selectedGym!),
                        EquipmentTabBar(list: equipment),
                        ReviewsTabBar(),
                        AboutTabBar(aboutText: about),
                      ],
                    ),
            );
          }),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pick Your Profile Picture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // From Gallery
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            final url = await Fileserver().uploadToServer(
                                File(image.path), 'Logo', selectedGym!.gymid);
                            final res = await Gymserviceprovider.server().addGymMedia(
                              mediaType: 'photo',
                              mediaUrl: [],
                              logourl: url,
                              gymId: selectedGym!.gymid,
                            );

                            if (res == "Successfully added Media") {
                              setState(() {
                                _image = url;
                              });
                            }
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                        child: Image.asset(
                          "assets/images/galleryImage.png",
                          height: mq.height * 0.05,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("Gallery",
                          style: TextStyle(color: Colors.white))
                    ],
                  ),
                  // From Camera
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.camera,
                          );
                          if (image != null) {
                            final url = await Fileserver().uploadToServer(
                                File(image.path), 'Logo', selectedGym!.gymid);
                            final res = await Gymserviceprovider.server().addGymMedia(
                              mediaType: 'photo',
                              mediaUrl: [],
                              logourl: url,
                              gymId: selectedGym!.gymid,
                            );
                            if (res == "Successfully added Media") {
                              setState(() {
                                _image = url;
                              });
                            }
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                        child: Image.asset(
                          "assets/images/camera.png",
                          height: mq.height * 0.05,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("Camera",
                          style: TextStyle(color: Colors.white))
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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

// import 'dart:ffi';
// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/showLogout_dialog.dart';
import 'package:gymshood/Utilities/helpers/menu_action.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/pages/TabBarPages.dart/AboutTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/equipmentTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/photostabbar.dart';
import 'package:gymshood/pages/TabBarPages.dart/reviewsTabBar.dart';
import 'package:gymshood/pages/TabBarPages.dart/videoTabbar.dart';
import 'package:gymshood/sevices/Models/AuthUser.dart';
import 'package:gymshood/sevices/Auth/auth_service.dart';
// import 'package:gymshood/sevices/Auth/server_provider.dart';
import 'dart:developer' as developer;

import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>  with SingleTickerProviderStateMixin {
  late TabController _tabController;
 late final Authuser? authuser;
 String? name;
   Future<void> _getuser()async{
        authuser = await AuthService.server().getUser();
        // developer.log('profile');
        // developer.log(authuser!.name!);
        if(authuser!=null){
          setState(() {
            name = authuser!.name!;
          });
          
        }else{
          setState(() {
            name = 'GYM NAME';
          });
        }
   }
  // late String? _image;
  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    _getuser();
    _tabController.index=0;
    super.initState();
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Widget _buildTab(String label){
    return Tab(
      child: Text(label,style: TextStyle(letterSpacing: 1 , ),),
    );
  }
  @override
  Widget build(BuildContext context) {
    
    mq=MediaQuery.of(context).size;
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: 
        Text("Profile" , style:
         TextStyle(color: Colors.white),),
         centerTitle: true,
         actions: [
          PopupMenuButton<MenuAction>(
            color: Theme.of(context).colorScheme.primary,
            iconColor: Colors.white,
            onSelected: (value) async{
            switch(value){
              case MenuAction.logout:
              final shouldlogout = await showLogoutDialog(context);
              if(shouldlogout){
                context.read<AuthBloc>().add(const AuthEventLogOut());
              }
            }
          }, itemBuilder: (context) { 
            return const [
              PopupMenuItem(value: MenuAction.logout,
                child: Text('Logout' , style: TextStyle(color: Colors.white,)))
            ];
           },)
         ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        spacing: mq.height*0.01,
        children: [
          SizedBox(height: mq.height*0.01,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height* .1),
                          child: 
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey)
                              ),
                              child: Icon(CupertinoIcons.person , size: mq.height*0.1,)
                              ),
                          ),
                        ],
                      ),
                    
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(name??'GYM NAME'
                          , 
                          style: 
                          TextStyle(
                            color: Colors.black , fontWeight: FontWeight.bold , fontSize: mq.height*0.025),),
                      ],
                    ), Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Gym slogan" , style: TextStyle(),),
                      ],
                    ),
                      // padding:  EdgeInsets.only(left: mq.width*0.1),
                       Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.star , color: Colors.amber,),
                          Text("4.5"),
                          Spacer(),
                          Text("16 Followers"),
                        ],
                      ),
                  Container(
                    color: Theme.of(context).colorScheme.primary,
                    child: TabBar(
                      controller: _tabController,
                      tabs: [
                        _buildTab("PHOTO"),
                        _buildTab("VIDEO"),
                        _buildTab("EQUIPMENT"),
                        _buildTab("REVIEWS"),
                        _buildTab("ABOUT")

                      ],
                      isScrollable: true,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.white,
                      ),
                  ),
            Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PhotosTabBar(),
                VideoTabBar(),
                EquipmentTabBar(),
                ReviewsTabBar(),
                AboutTabBar()
                
              ],
            ),
          ),
                ],
              ),
      );
  }
}
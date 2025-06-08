import 'package:flutter/material.dart';
import 'package:gymshood/pages/bottomNavigationPages/homeInterface.dart';
import 'package:gymshood/pages/bottomNavigationPages/plans.dart';
import 'package:gymshood/pages/bottomNavigationPages/profilePage.dart';

import 'package:gymshood/pages/bottomNavigationPages/revenuePage.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex=0;
  static const List<Widget> _widgetOptions = <Widget>[
      HomeInterface(),
      RevenuePage(),
      PlansPage(),
      ProfilePage()
  ];
  void _onItemTapped(int index){
    if(mounted){
      setState(() {
      _selectedIndex=index;
    });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
                    items:
             <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                
                icon: Icon(
                  _selectedIndex==0? 
                  Icons.home_filled: Icons.home_outlined,
                  color: Colors.white,),label: "Home", ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedIndex==1? Colors.white : null,
                    border: Border.all(color: Colors.white)
                  ),
                  child: Icon(Icons.currency_rupee_outlined,
                  color: 
                  _selectedIndex==1?
                   Theme.of(context).primaryColor:Colors.white,)),
                    label: "Revenue"),

                    BottomNavigationBarItem(icon: Icon(
                      _selectedIndex==2?
                      Icons.fact_check: 
                      Icons.fact_check_outlined ,
                       color: Colors.white ,) , label: "Plans"),

                       BottomNavigationBarItem(icon: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: _selectedIndex==3? Colors.white:null,
                          border: Border.all(color: Colors.white)
                        ),
                         child: Icon(Icons.fitness_center_rounded ,
                          color:_selectedIndex==3? Theme.of(context).primaryColor: Colors.white,),
                       ), label: "profile")
                      

             ],
             currentIndex: _selectedIndex,
             selectedItemColor: Colors.white,
             showSelectedLabels: false,
             showUnselectedLabels: false,
             onTap: _onItemTapped,
             ),
        
    );
  }
}


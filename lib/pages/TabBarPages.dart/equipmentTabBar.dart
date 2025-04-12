import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EquipmentTabBar extends StatefulWidget {
  const EquipmentTabBar({super.key});

  @override
  State<EquipmentTabBar> createState() => _EquipmentTabBarState();
}

class _EquipmentTabBarState extends State<EquipmentTabBar> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: GridView.count(
          padding: EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: [
            //need to integrate backend here
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey,
              ),
              
            ),
           Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey,
              ),
              
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey,
              ),
              
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey,
              ),
              
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey,
              ),
              
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey,
              ),
              
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey,
              ),
              
            ),
          ],
          ),
    );
  }
}
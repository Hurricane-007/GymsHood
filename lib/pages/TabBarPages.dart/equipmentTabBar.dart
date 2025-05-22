import 'package:flutter/material.dart';

class EquipmentTabBar extends StatefulWidget {
  final List<String> list; // Accept list from parent

  const EquipmentTabBar({super.key, required this.list});

  @override
  State<EquipmentTabBar> createState() => _EquipmentTabBarState();
}

class _EquipmentTabBarState extends State<EquipmentTabBar> {
  final List<Color> colors = [
    // Colors.redAccent,
    // Colors.blueAccent,
    // Colors.green,
    // Colors.purpleAccent,
    // Colors.orange,
    // Colors.teal,
    // Colors.deepPurple,
    // Colors.pinkAccent
      const Color(0xFF071952),
       const Color(0xFF0b666a),
        Color(0xFF97FEED),
         Color(0xFF35A29F),
         Colors.grey,
         Colors.blueGrey,
          Colors.blueAccent,
    Colors.green,
    Colors.purpleAccent,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        itemCount: widget.list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two items per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: colors[index % colors.length], // Cycle through colors
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                widget.list[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

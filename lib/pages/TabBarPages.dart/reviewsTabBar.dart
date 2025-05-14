import 'package:flutter/material.dart';
import 'package:gymshood/main.dart';

class ReviewsTabBar extends StatefulWidget {
  const ReviewsTabBar({super.key});

  @override
  State<ReviewsTabBar> createState() => _ReviewsTabBarState();
}

class _ReviewsTabBarState extends State<ReviewsTabBar> {
 
  @override
  Widget build(BuildContext context) {
     mq=MediaQuery.of(context).size;
    return ListView.builder(
        itemBuilder: (context, index) => Container(
           margin: EdgeInsets.all( 16 ),
                    height: mq.height*0.15,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
        ),  );
  }
}
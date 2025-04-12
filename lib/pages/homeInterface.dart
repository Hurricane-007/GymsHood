import 'package:flutter/material.dart';
import 'package:gymshood/main.dart';

class HomeInterface extends StatefulWidget {
  const HomeInterface({super.key});

  @override
  State<HomeInterface> createState() => _HomeInterfaceState();
}

class _HomeInterfaceState extends State<HomeInterface> {
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: 
        Text("Home" , style:
         TextStyle(color: Colors.white),),
         centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(left:mq.width*0.1 , top: 10 , right: mq.width*0.1),
                    height: mq.height*0.15,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
        ),) ,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/pages/firstScreen.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
// import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
// import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
    @override
  void initState() {
    _navigateToNextScreen();
    super.initState();
  }
   _navigateToNextScreen() async{
    Future.delayed(const Duration(seconds: 2), (){
      if(!mounted) return;
      context.read<AuthBloc>().add(AutheventFirstScreen());
  });
   }

  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/gyms.png")
        ],
      )
    );
  }
}
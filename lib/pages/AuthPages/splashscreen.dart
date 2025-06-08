import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/pages/AuthPages/firstScreen.dart';
import 'package:gymshood/services/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/services/Auth/bloc/auth_event.dart';
import 'package:gymshood/services/Auth/bloc/auth_state.dart';
// import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
// import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _triggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Run only once
    if (!_triggered) {
      _triggered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Image.asset("assets/images/gyms.png"),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/Themes/theme.dart';
import 'package:gymshood/pages/SignUpPage.dart';
import 'package:gymshood/pages/bottomNavigationBar.dart';
import 'package:gymshood/pages/firstScreen.dart';
import 'package:gymshood/pages/forgotPassword.dart';
import 'package:gymshood/pages/loginPage.dart';
import 'package:gymshood/pages/splashscreen.dart';
import 'package:gymshood/pages/verifyEmailview.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';
import 'package:gymshood/sevices/Auth/server_provider.dart';

import 'dart:developer' as developer;
late Size mq;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(ServerProvider()),
      child: const MyApp(), // The root app with MaterialApp
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      context.read<AuthBloc>().add(const AuthEventInitialize());
      _isInitialized = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GymsHood",
      theme: lightmode,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
 
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
    
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return _responseWiget(state, context);
      },
    );
  }
}

Widget _responseWiget(AuthState state, BuildContext context) {
  //  developer.log(AuthService.firebase().currentUser.email.toString());
  if (state is AuthStateSplashScreen) {
    return const SplashScreen();
  } else if (state is AuthStateLoggedOut) {
    return const LoginPage();
  } else if (state is AuthStateNeedsVerification) {
    developer.log('idhar main mane page pe humn');
    return const VerifyEmailView();
  }  else if (state is AuthStateVerifyOtp) {
    developer.log('idhar main mane page pe humn part 2');
    return const VerifyEmailView();
  } else if (state is AuthStateRegistering) {
    return const SignUpPage();
  } else if (state is AuthStateResetPassword) {
    return const ForgotPasswordView();
  } else if (state is AuthStateLoggedIn) {
    return const BottomNavigation();
  } 
   else if (state is AuthStateFIrst) {
    return const FirstScreen();
  } 
  else {
    return Scaffold(
      body: Text("state is not changed ",
          style: TextStyle(color: Colors.black12)),
    );
  }
}

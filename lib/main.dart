

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/Themes/theme.dart';
import 'package:gymshood/pages/splashscreen.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';
import 'package:gymshood/sevices/Auth/server_provider.dart';

late Size mq;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: "GymsHood",
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(ServerProvider()),
      child: const HomePage(),
    ),

  ));
   
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc,AuthState>(builder: (context, state) {
      return MaterialApp(
        theme: lightmode,
        home: SplashScreen(),
      );
    },
    );
  }
}

  // Widget _responseWiget(AuthState state, BuildContext context){
  //   //  developer.log(AuthService.firebase().currentUser.email.toString());
  //      if(state is AuthStateSplashScreen){
  //       return const SplashScreen();
  //     }
  //      else if(state is AuthStateFirstScreen){
  //       return  FirstScreen();
  //      }
  //       else{
  //         return Scaffold(
  //            body: Center(child: CircularProgressIndicator()),
  //         );
  //       }
  // }


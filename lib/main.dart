

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/Themes/theme.dart';
import 'package:gymshood/pages/SignUpPage.dart';
import 'package:gymshood/pages/bottomNavigationBar.dart';
import 'package:gymshood/pages/loginPage.dart';
import 'package:gymshood/pages/resetPasswordview.dart';
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
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc,AuthState>(builder: (context, state) {
      return MaterialApp(
        theme: lightmode,
        home: _responseWiget(state,context),
      );
    },
    );
  }
}

  Widget _responseWiget(AuthState state, BuildContext context){
    //  developer.log(AuthService.firebase().currentUser.email.toString());
       if(state is AuthStateSplashScreen){
        return const SplashScreen();
      }else if(state is AuthStateLoggedOut){
        return const LoginPage();
      }else if(state is AuthStateNeedsVerification){
        // developer.log("state is verifyemail");
        return const VerifyEmailView();
      }else if(state is AuthStateRegistering){
        return const SignUpPage();
      }else if (state is AuthStateVerifyOtp){
        // developer.log("state is verifyemail");
        return const VerifyEmailView();
      }
      else if(state is AuthStateResetPassword){
        // developer.log("state is verifyemail");
       return const ResetPasswordPage();
      }else if(state is AuthStateLoggedIn){
        return const BottomNavigation();
      }
       
        else{
          return Scaffold(
             body: Text("state is not changed ", style: TextStyle(color: Colors.black12)),
          );
        }
  }


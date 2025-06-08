import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/services/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/services/Auth/bloc/auth_event.dart';
import 'package:gymshood/services/Auth/bloc/auth_state.dart';


class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
@override
Widget build(BuildContext context) {
  mq = MediaQuery.of(context).size;

  return BlocListener<AuthBloc, AuthState> (
    listener: (context, state) {
      if (state is AuthStateLoggedOut && state.error != null) {
        developer.log(state.error!);
        showErrorDialog(context, state.error!);
      }
    },
    child: Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: mq.height * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Hello,",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Welcome to gymshood, a platform"),
                ],
              ),
              Text("revolutionizing fitness"),
              SizedBox(height: mq.height * 0.3),
              SizedBox(
                height: 55,
                width: mq.width * 0.6,
                child: TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(Autheventjustgotosignup());
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  child: Text(
                    "Sign Up",
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: mq.height * 0.035),
              SizedBox(
                height: 55,
                width: mq.width * 0.6,
                child: TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(Autheventjustgotologin());
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    side: BorderSide(color: Colors.black),
                  ),
                  child: Text(
                    "Login",
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                "Continue with",
                style: GoogleFonts.inter(fontSize: 20),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: mq.width * 0.12,
                height: mq.height * 0.12,
                child: GestureDetector(
                  onTap: () {
                    context.read<AuthBloc>().add(AuthEventGoogleLogIn());
                  },
                  child: Image.asset("assets/images/google.png"),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
  );
}
}
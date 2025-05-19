import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/pages/resetPassword.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';
// import 'package:uni_links/uni_links.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController email;
  bool isLoading = false;

  @override
  void initState() {
    email = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if(state is AuthStateForgotPassword){
          if(state.error!=null){
            showErrorDialog(context, state.error!);
          }
        }
        if(state is AuthStateForgotPassword){
          showInfoDialog(context, "Email has been sent");
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: mq.width * 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: mq.height * 0.2),

              // Title
              Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              // Subtitle
              Text(
                "Write your email to reset password.",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "We will send you an email to reset it.",
                style: TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: mq.height * 0.15),

              // Email Field
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  hintText: "Email",
                  hintStyle: GoogleFonts.mulish(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),

              SizedBox(height: mq.height * 0.1),

              // Send Email Button
              SizedBox(
                height: 55,
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    final userEmail = email.text.trim();
                    if (userEmail.isNotEmpty) {
                      // setState(() {
                      //   isLoading = true;
                      // });

                      context.read<AuthBloc>().add(AuthEventForgotPassword(
                          email: email.text, context: context));
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text("Reset link sent to $userEmail"),
                      //   ),
                      // );

                      // setState(() {
                      // isLoading = false;
                      // }
                      // );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          content: Text(
                            "Please enter your email.",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: Text(
                    "Send Email",
                    style: GoogleFonts.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: mq.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

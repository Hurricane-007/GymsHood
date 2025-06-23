// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
// import 'package:gymshood/pages/resetPassword.dart';
import 'package:gymshood/services/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/services/Auth/bloc/auth_event.dart';
import 'package:gymshood/services/Auth/bloc/auth_state.dart';
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
        if (state is AuthStateForgotPassword) {
          setState(() => isLoading = false);
          if (state.error != null) {
            showErrorDialog(context, state.error!);
          } else {
            showInfoDialog(context, "Email has been sent");
          }
        } else if (state is AuthStateErrors) {
          setState(() => isLoading = false);
          showErrorDialog(context, state.error);
        } else if (state is AuthStateLoggedOut) {
          setState(() => isLoading = false);
          if (state.error != null) {
            showErrorDialog(context, state.error!);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: mq.width * 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: mq.height * 0.05),
              
              // Title
              Text(
                "Forgot Password",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 12),

              // Subtitle
              Text(
                "Don't worry! It happens. Please enter the email address associated with your account.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: mq.height * 0.08),

              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                    prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              SizedBox(height: mq.height * 0.08),

              // Send Email Button
              SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final userEmail = email.text.trim();
                          if (userEmail.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Theme.of(context).primaryColor,
                                content: Text(
                                  "Please enter your email",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                            return;
                          }
                          setState(() => isLoading = true);
                          context.read<AuthBloc>().add(
                                AuthEventForgotPassword(
                                  email: email.text,
                                  context: context,
                                ),
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          "Send Reset Link",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: mq.height * 0.05),

              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Back to Login",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

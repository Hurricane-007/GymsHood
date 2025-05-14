import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/pages/loginPage.dart';
import 'package:gymshood/pages/verifyEmailview.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';
import 'dart:developer' as developer;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final TextEditingController gymName;
  late final TextEditingController email;
  late final TextEditingController password;
  late final TextEditingController confirmPassword;

  @override
  void initState() {
    gymName = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    gymName.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          developer.log(state.error!);
          await showErrorDialog(context, state.error!);
        } else if (state is AuthStateErrors) {
          developer.log(state.error!);
          await showErrorDialog(context, state.error!);
        } else if (state is AuthStateNeedsVerification) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyEmailView(),
                  settings: RouteSettings(arguments: email.text)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            height: mq.height,
            child: Column(
              children: [
                SizedBox(
                  height: mq.height * 0.3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
                SizedBox(
                  height: mq.height * 0.1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 26,
                      width: mq.width * 0.6,
                      child: TextField(
                        controller: gymName,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            hintText: "Gym Name",
                            hintStyle: GoogleFonts.mulish(
                                fontSize: 18, color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: mq.height * 0.025,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 26,
                      width: mq.width * 0.6,
                      child: TextField(
                        keyboardType: TextInputType.numberWithOptions(),
                        controller: email,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            hintText: "Email",
                            hintStyle: GoogleFonts.mulish(
                                fontSize: 18, color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: mq.height * 0.025,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 26,
                      width: mq.width * 0.6,
                      child: TextField(
                        keyboardType: TextInputType.numberWithOptions(),
                        controller: password,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              child: Icon(
                                obscurePassword
                                    ? Icons.remove_red_eye_outlined
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                            hintText: "Password",
                            hintStyle: GoogleFonts.mulish(
                                fontSize: 18, color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: mq.height * 0.025,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 26,
                      width: mq.width * 0.6,
                      child: TextField(
                        keyboardType: TextInputType.numberWithOptions(),
                        obscureText: obscureConfirmPassword,
                        controller: confirmPassword,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                              child: Icon(
                                obscureConfirmPassword
                                    ? Icons.remove_red_eye_outlined
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                            hintText: "Confirm Password",
                            hintStyle: GoogleFonts.mulish(
                                fontSize: 18, color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: mq.height * 0.025,
                ),
                Padding(
                  padding: EdgeInsets.only(left: mq.width * 0.35),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Text(
                      "Already registered?",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.025,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 55,
                      width: mq.width * 0.6,
                      child: TextButton(
                        onPressed: () async {
                          context.read<AuthBloc>().add(AuthEventRegister(
                              email: email.text,
                              password: password.text,
                              name: gymName.text));
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            side: BorderSide(
                              color: Colors.black,
                            )),
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

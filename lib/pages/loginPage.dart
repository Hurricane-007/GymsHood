import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/pages/bottomNavigationBar.dart';
// import 'package:gymshood/pages/SignUpPage.dart';
// import 'package:gymshood/pages/bottomNavigationBar.dart';
import 'package:gymshood/pages/forgotPassword.dart';
import 'package:gymshood/services/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/services/Auth/bloc/auth_event.dart';
import 'package:gymshood/services/Auth/bloc/auth_state.dart';
// import 'package:gymshood/pages/homeInterface.dart';
import 'dart:developer' as developer;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool obscurePassword = true;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthStateLoggedOut) {
            if (state.error != null) {
              // developer.log(state.error!);
              showErrorDialog(context, state.error!);
            }
          } else if (state is AuthStateErrors) {
            showErrorDialog(context, state.error);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: mq.height * 0.2),
                Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: mq.height * 0.15),

                // Email Field
                buildTextField(
                  controller: _email,
                  hint: "Email",
                  inputType: TextInputType.emailAddress,
                ),

                SizedBox(height: mq.height * 0.03),

                // Password Field
                buildTextField(
                  controller: _password,
                  hint: "Password",
                  obscure: obscurePassword,
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => obscurePassword = !obscurePassword),
                    child: Icon(
                      obscurePassword
                          ? Icons.remove_red_eye_outlined
                          : Icons.visibility_off,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                ),

                SizedBox(height: mq.height * 0.025),

                // Forgot Password and Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordView()),
                      ),
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<AuthBloc>().add(Autheventjustgotosignup());
                      },
                      child: Text(
                        "Don't have an account?",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: mq.height * 0.15),

                // Login Button
                SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: TextButton(
                    
                    onPressed: () {
                      final email = _email.text.trim();
                      final pwd = _password.text.trim();
                      // developer.log("Login pressed: $email / $pwd");

                      context
                          .read<AuthBloc>()
                          .add(AuthEventLogIn(email: email, password: pwd));
                
                      // Navigator.push(context, MaterialPageRoute(builder: (context) {
                      //   return BottomNavigation();
                      // },));
                      // developer.log('dispatched');
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      overlayColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: Text(
                      "Login",
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
        ));
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.mulish(fontSize: 18, color: Colors.grey),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

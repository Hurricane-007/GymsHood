import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/services/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/services/Auth/bloc/auth_event.dart';
import 'package:gymshood/services/Auth/bloc/auth_state.dart';
import 'dart:developer' as developer;

import 'package:gymshood/services/Helpers/saveCredentials.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final TextEditingController gymName;
  late final TextEditingController role;
  late final TextEditingController email;
  late final TextEditingController password;
  late final TextEditingController confirmPassword;

  // final List<String> roles = [ 'GymOwner', 'Admin'];
  String? selectedRole;

  void _handleSaveEmail() async {
    developer.log('Saving credentials');
    await saveCredentials(
      email.text.trim(),
      gymName.text.trim(),
      password.text.trim(),
      role.text.trim(),
    );
  }

  @override
  void initState() {
    gymName = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    role = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    gymName.dispose();
    email.dispose();
    role.dispose();
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
        if(state is AuthStateRegistering){
          developer.log(state.error!);
          await showErrorDialog(context, state.error!);
        }
        else if(state is AuthStateErrors){
          developer.log(state.error!);
          await showErrorDialog(context, state.error!);
        }
        else if(state is AuthStateNeedsVerification) {
          await showInfoDialog(context, "OTP has been sent to your email. Please check your inbox and verify your account.");
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
                "Sign Up",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: mq.height * 0.05),

              // Gym Name
              buildTextField(
                controller: gymName,
                hint: "Name",
              ),

              SizedBox(height: mq.height * 0.025),

              // Role Dropdown Styled Like TextField
              // DropdownButtonFormField<String>(
              //   value: selectedRole,
              //   onChanged: (value) {
              //     setState(() {
              //       selectedRole = value;
              //       role.text = value!;
              //     });
              //   },
              //   items: roles.map((role) {
              //     return DropdownMenuItem<String>(
              //       value: role,
              //       child: Text(role),
              //     );
              //   }).toList(),
              //   decoration: InputDecoration(
              //     hintText: "Select Role",
              //     hintStyle:
              //         GoogleFonts.mulish(fontSize: 18, color: Colors.grey),
              //     isDense: true,
              //     contentPadding:
              //         const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              //     enabledBorder: UnderlineInputBorder(
              //       borderSide:
              //           BorderSide(color: Theme.of(context).primaryColor),
              //     ),
              //     focusedBorder: UnderlineInputBorder(
              //       borderSide: BorderSide(
              //           color: Theme.of(context).primaryColor, width: 2),
              //     ),
              //   ),
              //   style: GoogleFonts.mulish(fontSize: 18, color: Colors.black),
              //   validator: (value) =>
              //       value == null ? 'Please select a role' : null,
              // ),

              // SizedBox(height: mq.height * 0.025),

              // Email
              buildTextField(
                controller: email,
                hint: "Email",
                inputType: TextInputType.emailAddress,
              ),

              SizedBox(height: mq.height * 0.025),

              // Password
              buildTextField(
                controller: password,
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

              // Confirm Password
              buildTextField(
                controller: confirmPassword,
                hint: "Confirm Password",
                obscure: obscureConfirmPassword,
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                      () => obscureConfirmPassword = !obscureConfirmPassword),
                  child: Icon(
                    obscureConfirmPassword
                        ? Icons.remove_red_eye_outlined
                        : Icons.visibility_off,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
              ),

              SizedBox(height: mq.height * 0.025),

              // Already Registered
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () =>
                      context.read<AuthBloc>().add(Autheventjustgotologin()),
                  child: Text(
                    "Already registered?",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),

              SizedBox(height: mq.height * 0.03),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton(
                  onPressed: () async {
                    if (password.text != confirmPassword.text) {
                      showErrorDialog(context,
                          "Password and Confirm Password should be same");
                    } else {
                      _handleSaveEmail();
                      context.read<AuthBloc>().add(
                            AuthEventRegister(
                              email: email.text.trim(),
                              password: password.text.trim(),
                              name: gymName.text.trim(),
                              role: "GymOwner",
                            ),
                          );
                    }
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
                    "Sign Up",
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

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType inputType = TextInputType.text,
    Widget? icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscure,
      maxLines: 1,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.mulish(fontSize: 18, color: Colors.grey),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

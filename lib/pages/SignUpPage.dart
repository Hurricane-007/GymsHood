import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/main.dart';
// import 'package:gymshood/pages/loginPage.dart';
// import 'package:gymshood/pages/verifyEmailview.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';
import 'dart:developer' as developer;

import 'package:gymshood/Utilities/helpers/saveemail.dart';
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

  void _handleSaveEmail()async{
    developer.log('hi');
    await saveEmail(email.text.trim());
  }
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
      listener: (
      ntext, state) async{
        if(state is AuthStateRegistering){
          developer.log(state.error!);
         await showErrorDialog(context, state.error!);
        }
        else if(state is AuthStateErrors){
          developer.log(state.error!);
         await showErrorDialog(context, state.error!);
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
              hint: "Gym Name",
              icon: null,
              obscure: false,
            ),

            SizedBox(height: mq.height * 0.025),

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
                onTap: () => setState(() => obscurePassword = !obscurePassword),
                child: Icon(
                  obscurePassword ? Icons.remove_red_eye_outlined : Icons.visibility_off,
                  color: Colors.grey,size: 30,
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
                onTap: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                child: Icon(
                  obscureConfirmPassword ? Icons.remove_red_eye_outlined : Icons.visibility_off,
                  color: Colors.grey,size: 30,
                ),
              ),
            ),

            SizedBox(height: mq.height * 0.025),

            // Already Registered
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => context.read<AuthBloc>().add(Autheventjustgotologin()),
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
                onPressed: () async{
                  if(password.text != confirmPassword.text){
                    showErrorDialog(context, "Password and Confirm Password should be same");
                  }else{
                    _handleSaveEmail();
                  
                  context.read<AuthBloc>().add(
                        AuthEventRegister(
                          email: email.text.trim(),
                          password: password.text.trim(),
                          name: gymName.text.trim(),
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
      ),)
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
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/Dialogs/info_dialog.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/services/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/services/Auth/bloc/auth_event.dart';
import 'package:gymshood/services/Auth/bloc/auth_state.dart';

class Resetpassword extends StatefulWidget {
  const Resetpassword({super.key , required this.token});
  final String token;

  @override
  State<Resetpassword> createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<Resetpassword> {
  late TextEditingController _password;
  late TextEditingController _confirmpassword;
  //  bool isLoading = false;



  @override
  void initState() {
    _password = TextEditingController();
    _confirmpassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmpassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if(state is AuthStateLoggedOut){
          if(state.error!=null){
            showInfoDialog(context, state.error!);
          }
          if(state is AuthStateResetPassword){
            if(state.error!=null){
              showErrorDialog(context, state.error!);
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Reset Password',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: mq.width * 0.2),
          child: Column(children: [
            SizedBox(
              height: mq.height * 0.2,
            ),
            Text(
              'RESET YOUR PASSWORD HERE!',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: mq.height * 0.1),
            TextField(
              controller: _password,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary)),
                  hintText: 'Password'),
            ),
            SizedBox(
              height: mq.height * 0.02,
            ),
            TextField(
              controller: _confirmpassword,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary)),
                  hintText: 'confirm Password'),
            ),
            SizedBox(
              height: mq.height * 0.1,
            ),
            SizedBox(
                height: 55,
                width: double.infinity,
                child: TextButton(
                    onPressed: () {
                      if(_password.text != _confirmpassword.text){
                        showErrorDialog(context, "Password and confirm password should be same");
                      }else{
                        context.read<AuthBloc>().add(AuthEventResetPassword(password: _password.text, confirmPassword: _confirmpassword.text, token: widget.token));
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ))),
          ]),
        ),
      ),
    );
  }
}

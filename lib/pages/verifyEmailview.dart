import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/Utilities/generic/argument.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/sevices/Auth/auth_service.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
// import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';
// import 'package:gymshood/sevices/Auth/server_provider.dart';
// import 'package:gymshood/sevices/Auth/server_provider.dart';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  bool _canResend = true;
  int _countDown = 0;
  Timer? _timer;
  String? email;
  late final TextEditingController _otp;
  void getemail()async{
     setState(() async{
      final prefs = await SharedPreferences.getInstance();
      email = prefs.getString('unverified_email');
     });
  }

void _startResendCountDown(){
  setState(() {
    _canResend=false;
    _countDown=30;
  });

  _timer?.cancel();

  _timer = Timer.periodic(Duration(seconds: 1), (timer){
    if(_countDown == 1){
      timer.cancel();
      setState(() {
        _canResend=true;
        _countDown=0;
      });
    }else{
      setState(() {
        _countDown--;
      });
    }
  });
}

  @override
  void initState() {
    _otp = TextEditingController();
    _canResend=false;
    _startResendCountDown();
    getemail();
    super.initState();
  }
    @override
  void dispose() { 
    _otp.dispose();
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    
       
      
      //  developer.log(email!);
       if(context.getArgument<String>()!=null){
        email= context.getArgument<String>();
       }
       
    return BlocListener<AuthBloc  , AuthState>(
      listener: (context, state) {
         if (state is AuthStateNeedsVerification){
          if(state.email!=null){
            developer.log('aaaaaaaa');
            email = state.email;}
          
        }else if(state is AuthStateErrors){
          developer.log('showing errors');
          showErrorDialog(context, state.error);
        }
        // developer.log(email!);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            height: mq.height,
            child: Column(
              children: [
                SizedBox(
                  height: mq.height * 0.1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Verify",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
                Text(
                  "We have sent you a mail.",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                Text("please verify the otp "),
                SizedBox(
                  height: mq.height * 0.2,
                ),
                SizedBox(
                  height: 26,
                  width: mq.width * 0.7,
                  child: 
                      TextField(
                        controller: _otp,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            hintText: 'otp',
                            hintStyle: GoogleFonts.mulish(fontSize: 16,
                                 color: Colors.grey)),
                      ),
                    
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: mq.width*0.6),
                    child:_canResend
  ? GestureDetector(
      onTap:() async{
         
         await AuthService.server().sendverificationemail(email: email!);
         setState(() {
           _canResend=false;
           _countDown=30;
         });
      } ,
      child: Text(
        'Resend OTP',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    )
  : Text(
      'Resend in $_countDown seconds',
      style: TextStyle(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    ),
                    ),
                
                SizedBox(
                  height: mq.height * 0.1,
                ),
                Padding(
                    padding: EdgeInsets.only(top: mq.height*0.05),
                    child: SizedBox(
                      height: 55,
                      width: mq.width * 0.6,
                      child: TextButton(
                        onPressed: () {
                            developer.log('button pressed');
                            
                            developer.log(email!);
                            
                            context.read<AuthBloc>().add(AuthEventVerifyOtp(otp: _otp.text, email: email!));
                          // }
                        },
                        style: TextButton.styleFrom(
                          overlayColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            side: BorderSide(
                              color: Colors.black,
                            )),
                        child: Text(
                          'verify'
                          ,
                          style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

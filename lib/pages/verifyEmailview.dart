import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
// import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';
// import 'package:gymshood/sevices/Auth/server_provider.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  int _secondsremaining = 30;
  Timer? _timer;
  bool _canResend = false;
  
  late final TextEditingController otp;

  void _startCountDown(){
    setState(() {
      _canResend = false;
      _secondsremaining = 30;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer){
      if(_secondsremaining == 0){
        setState(() {
          _canResend=true;
        });
        timer.cancel();
      }else{
        setState(() {
          _secondsremaining--;
        });
      }
    });
  }

  @override
  void initState() {
    otp = TextEditingController();
    _startCountDown();
    super.initState();
  }
    @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return BlocListener<AuthBloc  , AuthState>(
      listener: (context, state) {
        if(state is AuthStateVerifyOtp){
          if(state.error!=null){
          showErrorDialog(context, state.error!);
          }
        }
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
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            hintText: _canResend?"email":"otp",
                            hintStyle: GoogleFonts.mulish(fontSize: 16,
                                 color: Colors.grey)),
                      ),
                    
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: mq.width*0.6),
                    child: Text(_canResend? "Didn't receive OTP?" : "Resend in $_secondsremaining s" , style: TextStyle(color: Theme.of(context).colorScheme.primary),),
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
                        onPressed: () async{
                          //logic is ok we need function for backend
                          if(_canResend == true){
                            _startCountDown();
                          }else{
                            // context.read<AuthBloc>().add(AuthEventVerifyOtp(otp: otp.text, email: email));
                          }
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
                          _canResend?"Resend otp":"verify"
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

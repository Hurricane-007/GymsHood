import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymshood/main.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController email;
  late final TextEditingController password;
  bool obscurePassword=true;
  @override
  void initState() {
    email=TextEditingController();
    password=TextEditingController();

    super.initState();
  }
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: mq.height,
          child: Column(
            
            children: [
                SizedBox(
                  height: mq.height*0.3,
                ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text("Forgot Password" , 
                                     style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,
                     color: Theme.of(context).primaryColor ),),
                   ],
                 ),
                Text("Write your email to reset password." ,
                 style: TextStyle(color: Theme.of(context).primaryColor),),
                 Text("We will send you email to reset password "),
                 SizedBox(
                  height: mq.height*0.2,
                 ),
                
                    SizedBox(
                        height: 26,
                        width: mq.width*0.7,
                        child:    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor)
                        ),
                        hintText: "Email",
                        hintStyle: GoogleFonts.mulish(
                          fontSize: 18,
                          color: Colors.grey
                        )
                      ),
                     ),
                      ),
                      SizedBox(
                        height: mq.height*0.1,
                      ),

                  Positioned(
                      top: mq.height* 0.7,
                      left: mq.width*0.23,
                      child: SizedBox(
                        height: 55,
                        width: mq.width*0.6,
                        child: TextButton(onPressed: (){
                          
                        },
              
                         style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                          side: BorderSide(
                            color: Colors.black,
                            )
                        ),child: Text("Send Email" ,
                         style: 
                         GoogleFonts.openSans(
                          textStyle: TextStyle(
                            fontSize: 20 ,
                             fontWeight: FontWeight.bold ,
                              color: Colors.white)), ),),
                      )
                       ),
            ],
          ),
        ),
      ),
    );
  }
}
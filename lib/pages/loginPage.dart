import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/pages/SignUpPage.dart';
import 'package:gymshood/pages/bottomNavigationBar.dart';
import 'package:gymshood/pages/forgotPassword.dart';
// import 'package:gymshood/pages/homeInterface.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
          child: Stack(
            
            children: [
              Positioned(
                top: mq.height*0.18,
                left: mq.width*0.4,
                child: Text("Login" , 
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,
                 color: Theme.of(context).primaryColor ),)
              ),
                Positioned(
                      top: mq.height*0.5,
                      left: mq.width*0.15,
                      child: SizedBox(
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
                      )       
                  ),
                     Positioned(
                      top: mq.height*0.5+52,
                      left: mq.width*0.15,
                      child: SizedBox(
                        height: 26,
                        width: mq.width*0.7,
                        child:    TextField(
                          obscureText: obscurePassword ,
                          
                      controller: password,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              obscurePassword=!obscurePassword;
                            });
                          },
                          child:  Icon( obscurePassword ?
                             Icons.remove_red_eye_outlined : 
                             Icons.visibility_off, color: Colors.grey,),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor)
                        ),
                        hintText: "Password",
                        hintStyle: GoogleFonts.mulish(
                          fontSize: 18,
                          color: Colors.grey
                        )
                      ),
                     ),
                      )       
                  ),
                  Positioned(
                    top: mq.height*0.63,
                    left: mq.width*0.15,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordView(),));
                      },
                      child: Text("Forgot password?" ,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                                    ),
                    )),
                  Positioned(
                    top: mq.height*.63,
                    left: mq.width*0.5,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                         MaterialPageRoute(builder: (context) => SignUpPage(),));
                      },
                      child: Text("Don't have an account?", 
                      style: TextStyle(color: Theme.of(context).primaryColor),),
                    )  ),
                  Positioned(
                      top: mq.height* 0.7,
                      left: mq.width*0.23,
                      child: SizedBox(
                        height: 55,
                        width: mq.width*0.6,
                        child: TextButton(onPressed: (){
                          Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNavigation()),
                        (Route<dynamic> route) => false,);
                        },
              
                         style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                          side: BorderSide(
                            color: Colors.black,
                            )
                        ),child: Text("Login" ,
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

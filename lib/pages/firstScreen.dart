import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymshood/Utilities/Dialogs/error_dialog.dart';
import 'package:gymshood/main.dart';
import 'package:gymshood/pages/SignUpPage.dart';
import 'package:gymshood/pages/loginPage.dart';
import 'package:gymshood/sevices/Auth/auth_exceptions.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_bloc.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_event.dart';
import 'package:gymshood/sevices/Auth/bloc/auth_state.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  _handleGoogleSignInButton(){
    _signInWithGoogle();
  }


final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
],
);
 

Future<void> _signInWithGoogle() async {
  try {
    await _googleSignIn.signIn();
  } catch (_) {
    throw GenericAuthException();
  }
}



  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if(state is AuthStateLoggedOut){
          if(state.error != null){
            showErrorDialog(context, state.error!);
          }
        }
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
    
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                SizedBox(height: mq.height*0.1,),
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text("Hello," , style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
               ],
             ),  
                   
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Welcome to gymshood,a platform"),
                    ],
                  ),
    
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text("revolutionizing fitness"),
                   ],
                 ),
                 SizedBox(
                  height: mq.height*0.25,
                 ),
    
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       SizedBox(
                        height: 55,
                        width: mq.width*0.6,
                        child: TextButton(onPressed: (){
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage(),));
                        },
                         style: TextButton.styleFrom(
                          
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            
                            ),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                            
                            )
                        ),child: Text("Sign Up" ,
                         style: 
                         GoogleFonts.openSans(
                          textStyle: TextStyle(
                            fontSize: 20 ,
                             fontWeight: FontWeight.bold ,
                              color: Theme.of(context).primaryColor)), ),),
                                     ),
                     ],
                   )
                   ,
                    SizedBox(height: mq.height*0.035,),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     SizedBox(
                        height: 55,
                        width: mq.width*0.6,
                        child: TextButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
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
                      ),
                   ],
                 ),
                 SizedBox(height: 40,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Continue with" , style: GoogleFonts.inter( fontSize: 15),),
                    ],
                  ),
    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                           width: mq.width * .08,
                           height: mq.height*.1,
                          child: GestureDetector(
                            onTap: (){
                              context.read<AuthBloc>().add(AuthEventGoogleLogIn());
                            },
                            child: Image.asset("assets/images/google.png"),
                          )
                          ),
                      ],
                    )
            ],
          ),
        ),
    );
  }
}

import 'package:flutter/material.dart';

@immutable 
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent{
  const AuthEventInitialize();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const  AuthEventRegister({required this.email, required this.password,required this.name});
}

class AutheventFirstScreen extends AuthEvent{
  const AutheventFirstScreen();
}

class Autheventjustgotosignup extends AuthEvent{
  const Autheventjustgotosignup();
}
class Autheventjustgotologin extends AuthEvent{
  const Autheventjustgotologin();
}

class AuthEventVerifyOtp extends AuthEvent{
  final String otp;
  final String email;
  const AuthEventVerifyOtp({required this.otp, required this.email});
}

class AuthEventGoogleLogIn extends AuthEvent{

  const AuthEventGoogleLogIn();

}

class AuthEventLogIn extends AuthEvent{
  final String email;
  final String password;
  const AuthEventLogIn( {required this.email,  required this.password});
}

class AuthEventForgotPassword extends AuthEvent{
  final String? email;
  final BuildContext context;
  const AuthEventForgotPassword({required this.context, required this.email});
}

class AuthEventLogOut extends AuthEvent{
   const AuthEventLogOut();
}
class AuthEventjustgotoHome extends AuthEvent{
   const AuthEventjustgotoHome();
}

class AuthEventUpdatePassword extends AuthEvent{
  final String password;
  final String confirmPassword;
  const AuthEventUpdatePassword({required this.password, required this.confirmPassword});

}
class AuthEventResetPassword extends AuthEvent{
  final String password;
  final String confirmPassword;
 final String token;

  const AuthEventResetPassword({required this.password, required this.confirmPassword, required this.token});


}
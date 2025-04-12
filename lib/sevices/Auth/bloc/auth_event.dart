
import 'package:flutter/material.dart';

@immutable 
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent{
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent{
  final String email;
  final String password;
  const AuthEventLogIn(this.email,  this.password);
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const  AuthEventRegister({required this.email, required this.password});
}

class AuthEventForgotPassword extends AuthEvent{
  final String? email;
  const AuthEventForgotPassword({this.email});
}

class AuthEventLogOut extends AuthEvent{
   const AuthEventLogOut();
}

class AuthEventShouldRegister extends AuthEvent{
  const AuthEventShouldRegister();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventFirstScreen extends AuthEvent{
  const AuthEventFirstScreen();
}
class AuthEventSplashScreen extends AuthEvent{
  const AuthEventSplashScreen();
}
class AuthEventGoogleLogIn extends AuthEvent{
  final Exception? exception;
  const AuthEventGoogleLogIn({required this.exception});

}
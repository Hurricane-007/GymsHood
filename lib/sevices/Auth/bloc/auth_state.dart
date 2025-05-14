

import 'package:flutter/material.dart';
// import 'package:gymshood/sevices/Auth/AuthUser.dart';

@immutable 
abstract class AuthState {
  const AuthState();
}

class AuthStateRegistering extends AuthState{
  final String? error;
 const AuthStateRegistering({required this.error});
}

class AuthStateForgotPassword extends AuthState{
  final String? error;
  final bool hasSendEmail;

  const AuthStateForgotPassword({
  required this.error, 
  required this.hasSendEmail});
}

class AuthStateVerifyOtp extends AuthState{
  final String? error;
 const  AuthStateVerifyOtp({required this.error});

}

class AuthStateLoggedIn extends AuthState{
  const AuthStateLoggedIn();
}
class AuthStateResetPassword extends AuthState{
  final String? error;

 const AuthStateResetPassword({required this.error});

}
 class AuthStateNeedsVerification extends AuthState{
    const AuthStateNeedsVerification();
 }

 class AuthStateErrors extends AuthState{
  final String error;


 const AuthStateErrors({required this.error});
 }

class AuthStateLoggedOut extends AuthState{
  final String? error;
  const AuthStateLoggedOut({required this.error});
  }

class AuthStateSplashScreen extends AuthState{
  const AuthStateSplashScreen();
}
class AuthStateGoogleLoggedIn extends AuthState{
  final String message;
  const AuthStateGoogleLoggedIn(this.message);
}

  
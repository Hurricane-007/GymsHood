

import 'package:flutter/material.dart';
import 'package:gymshood/sevices/Auth/auth_user.dart';

@immutable 
abstract class AuthState {
  const AuthState();
}

class AuthStateRegistering extends AuthState{
  final Exception? exception;
 const AuthStateRegistering({required this.exception});
}

class AuthStateForgotPassword extends AuthState{
  final Exception? exception;
  final bool hasSendEmail;

  const AuthStateForgotPassword({
  required this.exception, 
  required this.hasSendEmail});
}

class AuthStateLoggedIn extends AuthState{
  final AuthUser user;
  const AuthStateLoggedIn( {required this.user});
}

 class AuthStateNeedsVerification extends AuthState{
     const AuthStateNeedsVerification();
 }

class AuthStateLoggedOut extends AuthState{
  final Exception? exception;
  const AuthStateLoggedOut({required this.exception});
  }

class AuthStateFirstScreen extends AuthState{
  const AuthStateFirstScreen();
}
class AuthStateSplashScreen extends AuthState{
  const AuthStateSplashScreen();
}
class AuthStateGoogleLoggedIn extends AuthState{
  final Exception? exception;
  const AuthStateGoogleLoggedIn(this.exception);
}

  
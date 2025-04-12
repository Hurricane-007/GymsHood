
import 'package:flutter/material.dart';
import 'package:gymshood/sevices/Auth/auth_user.dart';

@immutable
abstract class AuthProvider {
Future<void> initialize();
AuthUser? get currentUser;
Future<AuthUser?> logIn({
    required String email,
    required String password,
});
Future<AuthUser> createUser({
    required String email,
    required String password,
});
Future<void> logOut();
Future<void> sendEmailVerification();
Future<void> sendPasswordReset({required String toEmail});

}
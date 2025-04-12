
import 'package:flutter/material.dart';

@immutable 
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  final String? id;
   
  const AuthUser({required this.email, required this.id,required this.isEmailVerified});
}




import 'package:flutter/material.dart';

@immutable
class Authuser {
   final String name;
  final String role;
  final String email;
  final String phnumber;
  final String pHash;
  final String regDate;
  final int walletBalance;

 const Authuser(
  {required this.name,
   required this.role,
    required this.email,
     required this.phnumber,
      required this.pHash, 
      required this.regDate,
       required this.walletBalance});

  factory Authuser.fromJson(Map<String , dynamic> json){

    return Authuser(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      phnumber: json['contact_number'] ?? '',
      pHash: json['password'] ?? '',
      regDate: json['createdAt'] ?? '',
      walletBalance: json['walletBalance'] ?? 0,
    );
  }
  }

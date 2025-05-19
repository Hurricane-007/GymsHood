

import 'package:flutter/material.dart';
import 'package:gymshood/Utilities/helpers/menu_action.dart';

@immutable
class Gym {
final String name;
final String location;
final String openTime;
final String closeTime;
final String contactTime;
final String phone;
final String about;
final List<String> equipmentList;
final  GymStatus status;
final num avgrating;
final num capacity;
final bool isverified;
final bool isDeleted;
final String media;

  const 
  Gym({required this.name,
   required this.location, 
   required this.capacity, 
   required this.openTime, 
   required this.closeTime,
    required this.contactTime,
     required this.phone,
      required this.about,
       required this.equipmentList,
        required this.status, 
        required this.avgrating,
         required this.isverified,
          required this.isDeleted,
           required this.media});


      factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      name: json['name'] as String,
      location: json['location'] as String,
      capacity: json['capacity'] as num,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      contactTime: json['contactTime'] as String,
      phone: json['phone'] as String,
      about: json['about'] as String,
      equipmentList: List<String>.from(json['equipmentList'] ?? []),
      status: json['status'] as GymStatus,
      avgrating: (json['avgrating'] as num).toDouble(),
      isverified: json['isverified'] as bool,
      isDeleted: json['isDeleted'] as bool,
      media: json['media'] as String,
    );
  }
}
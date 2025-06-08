import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:gymshood/pages/verifydocumentPage.dart';
import 'package:gymshood/services/Helpers/enum.dart' show GymStatus;
import 'package:gymshood/services/Models/gymMediaModel.dart';
import 'package:gymshood/services/Models/location.dart';
import 'package:gymshood/services/Models/verifydocModels.dart'; // Assuming GymStatus is defined there

@immutable
class Gym {
  final String gymid;
  final String name;
  final Location location;
  final String openTime;
  final String closeTime;
  final String contactEmail;
  final String phone;
  final String about;
  final String gymslogan ;
  final List<String> equipmentList;
  final GymStatus status;
  final num avgrating;
  final num capacity;
  final bool isverified;
  final bool isDeleted;
  final GymMedia? media;
  final List<VerificationDocument>? docs;
  final List<Map<String, dynamic>> shifts;
  const Gym({
    required this.shifts,
    required this.docs,
    required this.gymid,
    required this.name,
    required this.location,
    required this.openTime,
    required this.gymslogan,
    required this.closeTime,
    required this.contactEmail,
    required this.phone,
    required this.about,
    required this.equipmentList,
    required this.status,
    required this.avgrating,
    required this.capacity,
    required this.isverified,
    required this.isDeleted,
    required this.media,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    // developer.log('Gym JSON: $json');
    //     final gymId = json['_id']?.toString();
    // developer.log('Extracted gymid: $gymId');
    return Gym(
      gymid: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      gymslogan: json['gymSlogan'] ?? '',
      docs: json['verificationDocuments'] != null
    ? List<Map<String, dynamic>>.from(json['verificationDocuments'])
        .map((doc) => VerificationDocument.fromJson(doc))
        .toList()
    : [], 
      location:
          json['location'] != null && json['location'] is Map<String, dynamic>
              ? Location.fromJson(json['location'])
              : Location(address: '', coordinates: [0.0, 0.0]),
      openTime: json['openTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      phone: json['phone'] ?? '',
      about: json['about'] ?? '',
      equipmentList: List<String>.from(json['equipmentList'] ?? []),
      status: _parseGymStatus(json['status']), // ✅ Handle enum
      avgrating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      capacity: (json['capacity'] as num?) ?? 0,
      isverified: json['isVerified'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      media: json['media'] != null && json['media'] is Map<String, dynamic>
    ? GymMedia.fromJson(json['media'])
    : null,
      shifts: json['shifts'] is List
          ? List<Map<String, dynamic>>.from(
              (json['shifts'] as List).map(
                (shift) => Map<String, dynamic>.from(shift),
              ),
            )
          : [],
    );
  }
}

// Helper function to parse GymStatus enum
GymStatus _parseGymStatus(String? value) {
  switch (value) {
    case 'pending':
      return GymStatus.pending;
    case 'inactive':
      return GymStatus.inactive;
    case 'maintenance':
      return GymStatus.maintenance;
    case 'active':
      return GymStatus.active;
    default:
      return GymStatus.pending; // default/fallback
  }
}
// [{location: {address: jagtiii, coordinates: [0, 0]}, _id: 682b6695d64293ae028027ed, name: aryansingh, capacity: 10, openTime: 09:34, closeTime: 10:34, contactEmail: aryan31122004@gmail.com, phone: 6005927659, about: I am here , equipmentList: [dumbbell, bench], status: pending, avgRating: 0, isVerified: false, isDeleted: false, owner: {_id: 682b5b2cd64293ae028027de, name: IITIAN GYM}, shifts: [{name: Mid day, startTime: 12:33, endTime: 16:33, capacity: 100, _id: 682b6695d64293ae028027ee, id: 682b6695d64293ae028027ee}], verificationDocuments: [], createdAt: 2025-05-19T17:12:53.276Z, updatedAt: 2025-05-20T08:18:15.645Z, __v: 0, media: {_id: 682c3ac717d0321758a7d906, gymId: 682b6695d64293ae028027ed, mediaType: photo, mediaUrl: https://yourserver.com/uploads/1000000043.jpg, createdAt: 2025-05-20T08:18:15.520Z, __v: 0}, formattedAddress: jagtiii (0, 0), id: 682b6695d64293ae028027ed}, {location: {address: jagtiii, coordinates: [0, 0]}, _id: 682b6786d64293ae028027f2, name: aryansingh, capacity: 10, openTime: 09:34, closeTime: 10:34, contactEmail: aryan31122004@gmail.com, phone: 6005927659, about: I am here , equipmentList: [dumbbell, bench], status: pending, avgRating: 0, isVerified: false, isDeleted: false, owner: {_id: 682b5b2cd64293ae028027de, name: IITIAN GYM}, shifts: [{name: Mid day, startTime: 12:33, endTime: 16:33, capacity: 100, _id: 682b6786d64293ae028027f3, id: 682b6786d64293ae028027f3}], verificationDocuments: [], createdAt: 2025-05-19T17:16:54.413Z, updatedAt: 2025-05-19T17:16:54.413Z, __v: 0, formattedAddress: jagtiii (0, 0), id: 682b6786d64293ae028027f2}, {location: {address: near jagti, coordinates: [0, 0]}, _id: 682c4c32908c087f78352ed3, name: IITIAN GYM, capacity: 100, openTime: 09:00, closeTime: 15:00, contactEmail: aryan31122004@gmail.com, phone: 6005927659, about: this is my app, equipmentList: [dumbbell, barbell], status: pending, avgRating: 0, isVerified: false, isDeleted: false, owner: {_id: 682b5b2cd64293ae028027de, name: IITIAN GYM}, shifts: [{name: Day shift, startTime: 10:01, endTime: 18:01, capacity: 50, _id: 682c4c32908c087f78352ed4, id: 682c4c32908c087f78352ed4}], verificationDocuments: [], createdAt: 2025-05-20T09:32:34.212Z, updatedAt: 2025-05-20T09:32:34.212Z, __v: 0, formattedAddress: near jagti (0, 0), id: 682c4c32908c087f78352ed3}]

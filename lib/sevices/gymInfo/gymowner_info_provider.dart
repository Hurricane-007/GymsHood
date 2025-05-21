

import 'package:gymshood/sevices/Models/gym.dart';

abstract class GymOwnerInfoProvider {
  Future<String> registerGym({
    required String role , 
    required String name,
    required String location,
     List<num>? coordinates,
    required num capacity,
    required String openTime,
    required String closeTime,
    required String contactEmail,
    required String phone,
    required String about,
    required List<String> equipmentList,
    required List<Map<String, Object>> shifts,
    required String userid,
     });

     Future<String> addGymMedia({
        required String mediaType,//needed dropdown menu of photo , video
        required String mediaUrl,
        required String logourl,
     });

     Future<Gym> getGymDetails({
        required String id
     });

     Future<bool> updateGym({
    required String name,
    required String location,
    required num capacity,
    required String openTime,
    required String closeTime,
    required String contactEmail,
    required String phone,
    required String about,
    required String shifts,
     });


    // name,
    // validity,
    // price,
    // discountPercent,
    // features,
    // planType,
    // isTrainerIncluded,
    // workoutDuration
  Future<String> createPlan({
    required String name ,
    required num validity,
    required num price,
    required num discountPercent,
    required String features,
    required String planType,
    required bool isTrainerIncluded,
    required String workoutDuration,
  });

  Future<List<Gym>> getAllGyms({
  String? status,
  String? search,
  String? near, // Format: "lat,lng,radius"
}) ;

}
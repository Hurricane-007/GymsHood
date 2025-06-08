import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/planModel.dart';
import 'package:gymshood/services/Models/gymDashboardStats.dart';

abstract class GymOwnerInfoProvider {
  Future<Map<String,dynamic>> registerGym({
    required String role , 
    required String name,
    required String location,
    required String gymSlogan,
    required  List<num> coordinates,
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

    Future<List<Gym>> getGymsByowner(String id);
     Future<String> addGymMedia({
        required String mediaType,//needed dropdown menu of photo , video
        required List<String> mediaUrl,
        required String logourl,
        required String gymId
     });

     Future<Gym> getGymDetails({
        required String id
     });
     Future<bool> deletePlan({required String planId});

     Future<bool> updateGym({
      required String gymId,
    required String name,
    required Map<String,dynamic> location,
    required num capacity,
    required String openTime,
    required String closeTime,
    required String contactEmail,
    required String phone,
    required String about,
    required List<Map<String,dynamic>> shifts,
     });

  Future<String> createPlan({
    required String name ,
    required num validity,
    required num price,
    required num discountPercent,
    required String features,
    required String planType,
    required bool isTrainerIncluded,
    required num workoutDuration,
    required String gymId
  });

  Future<List<Gym>> getAllGyms({
  String? status,
  String? search,
  String? near, 
}) ;

Future<List<Plan>> getPlans(String gymId);
Future<GymDashboardStats> getgymDashBoardStatus(String gymId);
Future<bool> updatePlan({
  required String planId,
  required String    name,
   required num price,
  required num discountPercent,
    required String features,
    required num workoutDuration,
    required bool isTrainerIncluded,

});

}
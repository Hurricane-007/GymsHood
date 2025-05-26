// import 'package:gymshood/sevices/Auth/auth_service.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/planModel.dart';
import 'package:gymshood/services/gymInfo/gym_server_provider.dart';
import 'package:gymshood/services/gymInfo/gymowner_info_provider.dart';

class Gymserviceprovider implements GymOwnerInfoProvider{
  final GymOwnerInfoProvider provider;
  const Gymserviceprovider({required this.provider});
  factory Gymserviceprovider.server() => Gymserviceprovider(provider: GymServerProvider());

  @override
  Future<String> addGymMedia({required String mediaType, required String mediaUrl, required String logourl}) {
   return provider.addGymMedia(mediaType: mediaType, mediaUrl: mediaUrl, logourl: logourl);
  }

  @override
  Future<Gym> getGymDetails({required String id}) {
    return provider.getGymDetails(id: id);
  }

  @override
  Future<Map<String,dynamic>> registerGym({required String role, required String name, required String location, required List<num> coordinates, required num capacity, required String openTime, required String closeTime, required String contactEmail, required String phone, required String about, required List<String> equipmentList, required List<Map<String, Object>> shifts, required String userid}) {
    return provider.registerGym(role: role, name: name, location: location, capacity: capacity, openTime: openTime, closeTime: closeTime, contactEmail: contactEmail, phone: phone, about: about, equipmentList: equipmentList, shifts: shifts, userid: userid , coordinates: coordinates);
  }

  @override
  Future<bool> updateGym({required String gymId,required String name, required Map<String,dynamic> location, required num capacity, required String openTime, required String closeTime, required String contactEmail, required String phone, required String about, required List<Map<String,dynamic>> shifts}) {
   return provider.updateGym(gymId: gymId, name: name, location: location, capacity: capacity, openTime: openTime, closeTime: closeTime, contactEmail: contactEmail, phone: phone, about: about, shifts: shifts);
  }
  
  @override
  Future<String> createPlan({required String name, required num validity, required num price, required num discountPercent, required String features, required String planType, required bool isTrainerIncluded, required String workoutDuration , required String gymId}) {
    return provider.createPlan(name: name, validity: validity, price: price, discountPercent: discountPercent, features: features, planType: planType, isTrainerIncluded: isTrainerIncluded, workoutDuration: workoutDuration,gymId: gymId);
  }
  
  @override
  Future<List<Gym>> getAllGyms({String? status, String? search, String? near}) {
   return provider.getAllGyms(status: status , search: search , near: near);
  }

  @override
  Future<List<Plan>> getPlans(String gymId) {
   return provider.getPlans(gymId);
  }
  
  @override
  Future<bool> deletePlan({required String planId}) {
    return provider.deletePlan(planId: planId);
  }
  
  @override
  Future<List<Gym>> getGymsByowner(String id) {
    return provider.getGymsByowner(id);
  }
  
  @override
  Future<bool> updatePlan({required String planId, required String name, required num price, required num discountPercent, required String features, required String workoutDuration, required bool isTrainerIncluded}) {
   return provider.updatePlan(planId: planId, name: name, price: price, discountPercent: discountPercent, features: features, workoutDuration: workoutDuration, isTrainerIncluded: isTrainerIncluded);
  }
}
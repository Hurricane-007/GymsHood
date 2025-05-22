// import 'package:gymshood/sevices/Auth/auth_service.dart';
import 'package:gymshood/sevices/Models/gym.dart';
import 'package:gymshood/sevices/Models/planModel.dart';
import 'package:gymshood/sevices/gymInfo/gym_server_provider.dart';
import 'package:gymshood/sevices/gymInfo/gymowner_info_provider.dart';

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
  Future<String> registerGym({required String role, required String name, required String location, List<num>? coordinates, required num capacity, required String openTime, required String closeTime, required String contactEmail, required String phone, required String about, required List<String> equipmentList, required List<Map<String, Object>> shifts, required String userid}) {
    return provider.registerGym(role: role, name: name, location: location, capacity: capacity, openTime: openTime, closeTime: closeTime, contactEmail: contactEmail, phone: phone, about: about, equipmentList: equipmentList, shifts: shifts, userid: userid);
  }

  @override
  Future<bool> updateGym({required String name, required String location, required num capacity, required String openTime, required String closeTime, required String contactEmail, required String phone, required String about, required String shifts}) {
   return provider.updateGym(name: name, location: location, capacity: capacity, openTime: openTime, closeTime: closeTime, contactEmail: contactEmail, phone: phone, about: about, shifts: shifts);
  }
  
  @override
  Future<String> createPlan({required String name, required num validity, required num price, required num discountPercent, required String features, required String planType, required bool isTrainerIncluded, required String workoutDuration}) {
    return provider.createPlan(name: name, validity: validity, price: price, discountPercent: discountPercent, features: features, planType: planType, isTrainerIncluded: isTrainerIncluded, workoutDuration: workoutDuration);
  }
  
  @override
  Future<List<Gym>> getAllGyms({String? status, String? search, String? near}) {
   return provider.getAllGyms();
  }

  @override
  Future<List<Plan>> getPlans() {
   return provider.getPlans();
  }
}
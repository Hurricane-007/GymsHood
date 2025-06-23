// import 'package:gymshood/sevices/Auth/auth_service.dart';
import 'package:gymshood/services/Models/ActiveUsersModel.dart';
import 'package:gymshood/services/Models/announcementModel.dart';
import 'package:gymshood/services/Models/gym.dart';
import 'package:gymshood/services/Models/planModel.dart';
import 'package:gymshood/services/Models/gymDashboardStats.dart';
import 'package:gymshood/services/Models/ratingsModel.dart';
import 'package:gymshood/services/Models/revenueDataModel.dart';
import 'package:gymshood/services/gymInfo/gym_server_provider.dart';
import 'package:gymshood/services/gymInfo/gymowner_info_provider.dart';

class Gymserviceprovider implements GymOwnerInfoProvider{
  final GymOwnerInfoProvider provider;
  const Gymserviceprovider({required this.provider});
  factory Gymserviceprovider.server() => Gymserviceprovider(provider: GymServerProvider());

  @override
  Future<String> addGymMedia({required String mediaType, required List<String> mediaUrl, required String logourl , required String gymId}) {
   return provider.addGymMedia(mediaType: mediaType, mediaUrl: mediaUrl, logourl: logourl, gymId: gymId);
  }

  @override
  Future<Gym> getGymDetails({required String id}) {
    return provider.getGymDetails(id: id);
  }

  @override
  Future<Map<String,dynamic>> registerGym({required String role, required String name, required String location, required List<num> coordinates, required num capacity, required String openTime, required String closeTime, required String contactEmail, required String phone, required String about, required List<String> equipmentList, required List<Map<String, Object>> shifts, required String userid,required String gymSlogan}) {
    return provider.registerGym(role: role, name: name, location: location,gymSlogan: gymSlogan, capacity: capacity, openTime: openTime, closeTime: closeTime, contactEmail: contactEmail, phone: phone, about: about, equipmentList: equipmentList, shifts: shifts, userid: userid , coordinates: coordinates);
  }

  @override
  Future<bool> updateGym({required String gymId,required String name, required num capacity, required String openTime, required String closeTime, required List<String> equipments,required String contactEmail, required String phone, required String about, required List<Map<String,dynamic>> shifts}) {
   return provider.updateGym(gymId: gymId, name: name, capacity: capacity, openTime: openTime, closeTime: closeTime, contactEmail: contactEmail, phone: phone,equipments: equipments, about: about, shifts: shifts);
  }
  
  @override
  Future<String> createPlan({required String name, required num validity, required num price, required num discountPercent, required String features, required String planType, required bool isTrainerIncluded, required num workoutDuration , required String gymId}) {
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
  Future<bool> updatePlan({required String planId, required String name, required num price, required num discountPercent, required String features, required num workoutDuration, required bool isTrainerIncluded}) {
   return provider.updatePlan(planId: planId, name: name, price: price, discountPercent: discountPercent, features: features, workoutDuration: workoutDuration, isTrainerIncluded: isTrainerIncluded);
  }
  
  @override
  Future<GymDashboardStats> getgymDashBoardStatus(String gymId) {
    return provider.getgymDashBoardStatus(gymId);
  }
  
  @override
  Future<bool> verificationdocsUpload(List<String> docs) {
  return  provider.verificationdocsUpload(docs);
  }
  
  @override
  Future<bool> toggleGymstatus() {
return provider.toggleGymstatus();
  }

  @override
  Future<GymAnnouncement> createGymAnnouncement(String message) {
    return provider.createGymAnnouncement(message);
  }
  
  @override
  Future<List<GymAnnouncement>> getGymAnnouncements() {
    return provider.getGymAnnouncements();
  }

  @override
  Future<GymRating> getgymrating(String gymID) {
    return provider.getgymrating(gymID);
  }

  @override
  Future<ActiveUsersResponse> getactiveUserResponse(String gymId) {
    return provider.getactiveUserResponse(gymId);
  }
  
  @override
  Future<RevenueAnalytics?> fetchRevenueData(String gymId, {String period = 'monthly'}){
    return provider.fetchRevenueData(gymId , period: period);
  }
  
  @override
  Future<List<GymAnnouncement>> getGymAnnouncementsbygym() {
    return provider.getGymAnnouncementsbygym();
  }
  
  @override
  Future<bool> createFundaccount(String upiId, String accountNumber, String ifscCode, String accountHolder) {
    return provider.createFundaccount(upiId, accountNumber, ifscCode, accountHolder);
  }
  
  @override
  Future<bool> deleteAnnouncement(String announcementId) {
  return provider.deleteAnnouncement(announcementId);
  }
  
  @override
  Future<bool> recreateFundaccount(String upiId, String accountNumber, String ifscCode, String accountHolder) {
    return provider.recreateFundaccount(upiId, accountNumber, ifscCode, accountHolder);
  }
  
  @override
  Future<List<GymRating>> getratings(String gymId) {
    return provider.getratings(gymId);
  }
}
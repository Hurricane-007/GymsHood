import 'package:gymshood/services/Models/location.dart';

class GymDashboardStats {
  final int totalNearbyUsers;
  final List<PotentialCustomers> potentialCustomers;
  final Location gymLocation;

  GymDashboardStats({
    required this.totalNearbyUsers,
    required this.potentialCustomers,
    required this.gymLocation,
  });

  factory GymDashboardStats.fromJson(Map<String, dynamic> json) {
    return GymDashboardStats(
      totalNearbyUsers: json['totalNearbyUsers'] ?? 0,
      potentialCustomers: (json['potentialCustomers'] as List?)
          ?.map((e) => PotentialCustomers.fromJson(e))
          .toList() ?? [],
      gymLocation: Location.fromJson(json['gymLocation'] ?? {}),
    );
  }
} 

class PotentialCustomers{
  final String name;
  final String phone;
  final String address;
  final String email;

  PotentialCustomers({required this.name, required this.email,required this.phone, required this.address});

  factory PotentialCustomers.fromJson(Map<String,dynamic> json){
    return PotentialCustomers(
      email: json['email']?? "",
      name: json['name'] ?? "", 
      phone: json['phone'] ?? "",
       address: json['location']['address'] ?? "");
  }
  
}
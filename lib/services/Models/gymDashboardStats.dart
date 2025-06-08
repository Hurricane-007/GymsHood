import 'package:gymshood/services/Models/location.dart';

class GymDashboardStats {
  final int totalNearbyUsers;
  final List<Map<String, dynamic>> potentialCustomers;
  final Location gymLocation;

  GymDashboardStats({
    required this.totalNearbyUsers,
    required this.potentialCustomers,
    required this.gymLocation,
  });

  factory GymDashboardStats.fromJson(Map<String, dynamic> json) {
    return GymDashboardStats(
      totalNearbyUsers: json['totalNearbyUsers'] ?? 0,
      potentialCustomers: List<Map<String, dynamic>>.from(json['potentialCustomers'] ?? []),
      gymLocation: Location.fromJson(json['gymLocation'] ?? {}),
    );
  }
} 
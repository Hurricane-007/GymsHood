
import 'dart:developer' as developer;

class Plan {
  final String id;
  final String name;
  final String gymId;
  final int validity; // in days or months depending on planType
  final double price;
  final double discountPercent;
  final String planType; // "day" | "monthly" | "yearly"
  final bool isTrainerIncluded;
  final bool isActive;
  final DateTime lastUpdatedAt;
  final List<String>? features;
  final String? lastUpdatedBy;
  final num workoutDuration;
  Plan(

    {
    required this.id,
    required this.name,
    required this.gymId,
    required this.validity,
    required this.price,
    required this.discountPercent,
    required this.planType,
    required this.isTrainerIncluded,
    required this.isActive,
    required this.lastUpdatedAt,
    required this.workoutDuration,
    this.features,
    this.lastUpdatedBy,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    // developer.log(json.toString());
    return Plan(
      workoutDuration: json['duration']?? 0,
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      gymId: json['gymId'] ?? '',
      validity: json['validity'] ?? 0,
      price: (json['price'] as num).toDouble(),
      discountPercent: (json['discountPercent'] as num).toDouble(),
      planType: json['planType'] ?? '',
      isTrainerIncluded: json['isTrainerIncluded'] ?? false,
      isActive: json['isActive'] ?? false,
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
      features: (json['features'] is List)
          ? List<String>.from(json['features'])
          : (json['features'] is String)
              ? [json['features']]
              : null,
      lastUpdatedBy: json['lastUpdatedBy']?['_id'] ?? json['lastUpdatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration':workoutDuration,
      '_id': id,
      'name': name,
      'gymId': gymId,
      'validity': validity,
      'price': price,
      'discountPercent': discountPercent,
      'planType': planType,
      'isTrainerIncluded': isTrainerIncluded,
      'isActive': isActive,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'features': features,
      'lastUpdatedBy': lastUpdatedBy,
    };
  }
}
// [{_id: 6839b4a9e91514f6c6113068, gymId: 68397da0e91514f6c6112e67, name: new plan, validity: 4, price: 10000, discountPercent: 10, features: the new plan, planType: monthly, isTrainerIncluded: true, isActive: true, lastUpdatedAt: 2025-05-30T13:37:45.486Z, createdAt: 2025-05-30T13:37:45.486Z, updatedAt: 2025-05-30T13:37:54.229Z, __v: 0}]
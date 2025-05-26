class GymPlanRevenue {
  final String planId;
  final String gymId;
  final DateTime date;
  final double revenue;
  final String revenueType;
  final DateTime? createdAt;

  GymPlanRevenue({
    required this.planId,
    required this.gymId,
    required this.date,
    required this.revenue,
    required this.revenueType,
    this.createdAt,
  });

  factory GymPlanRevenue.fromJson(Map<String, dynamic> json) {
    return GymPlanRevenue(
      planId: json['planId'] as String,
      gymId: json['gymId'] as String,
      date: DateTime.parse(json['date']),
      revenue: (json['revenue'] as num).toDouble(),
      revenueType: json['revenueType'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'gymId': gymId,
      'date': date.toIso8601String(),
      'revenue': revenue,
      'revenueType': revenueType,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}

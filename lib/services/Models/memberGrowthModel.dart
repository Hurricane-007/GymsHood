class DashboardResponse {
  final bool success;
  final DashboardData data;

  DashboardResponse({required this.success, required this.data});

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'],
      data: DashboardData.fromJson(json['data']),
    );
  }
}

class DashboardData {
  final PlanDistribution planDistribution;
  final MemberGrowth memberGrowth;

  DashboardData({required this.planDistribution, required this.memberGrowth});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      planDistribution: PlanDistribution.fromJson(json['planDistribution']),
      memberGrowth: MemberGrowth.fromJson(json['memberGrowth']),
    );
  }
}

class PlanDistribution {
  final int totalActiveUsers;
  final Map<String, dynamic> byPlan;

  PlanDistribution({required this.totalActiveUsers, required this.byPlan});

  factory PlanDistribution.fromJson(Map<String, dynamic> json) {
    return PlanDistribution(
      totalActiveUsers: json['totalActiveUsers'],
      byPlan: Map<String, dynamic>.from(json['byPlan']),
    );
  }
}

class MemberGrowth {
  final GrowthData daily;
  final GrowthData weekly;
  final GrowthData monthly;
  final GrowthData yearly;

  MemberGrowth({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.yearly,
  });

  factory MemberGrowth.fromJson(Map<String, dynamic> json) {
    return MemberGrowth(
      daily: GrowthData.fromJson(json['daily']),
      weekly: GrowthData.fromJson(json['weekly']),
      monthly: GrowthData.fromJson(json['monthly']),
      yearly: GrowthData.fromJson(json['yearly']),
    );
  }
}

class GrowthData {
  final List<String> dates;
  final List<int> counts;
  final List<int> cumulative;

  GrowthData({
    required this.dates,
    required this.counts,
    required this.cumulative,
  });

  factory GrowthData.fromJson(Map<String, dynamic> json) {
    return GrowthData(
      dates: List<String>.from(json['dates']),
      counts: List<int>.from(json['counts']),
      cumulative: List<int>.from(json['cumulative']),
    );
  }
}

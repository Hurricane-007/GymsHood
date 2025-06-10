class RevenueAnalytics {
  final Map<String, dynamic> period;
  final String planId;
  final String planName;
  final double totalRevenue;
  final int transactionCount;

  RevenueAnalytics({
    required this.period,
    required this.planId,
    required this.planName,
    required this.totalRevenue,
    required this.transactionCount,
  });

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    return RevenueAnalytics(
      period: Map<String, dynamic>.from(json['period']),
      planId: json['planId'],
      planName: json['planName'],
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      transactionCount: json['transactionCount'],
    );
  }
}
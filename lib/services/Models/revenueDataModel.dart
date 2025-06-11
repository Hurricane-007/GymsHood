class RevenueData {
  final Map<String, dynamic> period;
  final String planId;
  final String planName;
  final double totalRevenue;
  final int transactionCount;

  RevenueData({
    required this.period,
    required this.planId,
    required this.planName,
    required this.totalRevenue,
    required this.transactionCount,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      period: json['period'] ?? {},
      planId: json['planId'] ?? '',
      planName: json['planName'] ?? '',
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      transactionCount: (json['transactionCount'] ?? 0),
    );
  }
}

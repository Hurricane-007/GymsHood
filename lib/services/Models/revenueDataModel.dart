class RevenueAnalytics {
  final List<String> dates;
  final List<double> totals;
  final Map<String, List<double>> planSeries;

  RevenueAnalytics({
    required this.dates,
    required this.totals,
    required this.planSeries,
  });

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    return RevenueAnalytics(
      dates: List<String>.from(json['dates']),
      totals: List<double>.from((json['totals'] as List).map((e) => (e as num).toDouble())),
      planSeries: (json['planSeries'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, List<double>.from((v as List).map((e) => (e as num).toDouble()))),
      ),
    );
  }
}

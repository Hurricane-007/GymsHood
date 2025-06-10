import 'package:gymshood/services/Models/registerModel.dart';

class ActiveUsersResponse {
  final List<RegisterEntry> activeUsers;
  final List<RegisterEntry> expiredUsers;
  final int activeCount;
  final int expiredCount;

  ActiveUsersResponse({
    required this.activeUsers,
    required this.expiredUsers,
    required this.activeCount,
    required this.expiredCount,
  });

  factory ActiveUsersResponse.fromJson(Map<String, dynamic> json) {
    return ActiveUsersResponse(
      activeUsers: (json['activeUsers'] as List)
          .map((u) => RegisterEntry.fromJson(u))
          .toList(),
      expiredUsers: (json['expiredUsers'] as List)
          .map((u) => RegisterEntry.fromJson(u))
          .toList(),
      activeCount: json['activeCount'] ?? 0,
      expiredCount: json['expiredCount'] ?? 0,
    );
  }
}

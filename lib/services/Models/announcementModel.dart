import 'package:meta/meta.dart';

@immutable
class GymAnnouncement {
  final String? title;
  final String id;
  final String gymId;
  final String createdBy;
  final String message;
  final DateTime createdAt;
  final List<String> targetUsers;

  const GymAnnouncement(
    {
    required this.title,
    required this.id,
    required this.gymId,
    required this.createdBy,
    required this.message,
    required this.createdAt,
    required this.targetUsers,
  });

  factory GymAnnouncement.fromJson(Map<String, dynamic> json) {
    try {
      return GymAnnouncement(
        title: json['title']?.toString() ?? "",
        id: json['_id']?.toString() ?? '',
        gymId: json['gymId'] is Map
            ? json['gymId']['_id']?.toString() ?? ''
            : json['gymId']?.toString() ?? '',
        createdBy: json['createdBy']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        targetUsers: (json['targetUsers'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
    } catch (e) {
      print('Error parsing GymAnnouncement: $e\nJSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'gymId': gymId,
      'createdBy': createdBy,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'targetUsers': targetUsers,
    };
  }
}

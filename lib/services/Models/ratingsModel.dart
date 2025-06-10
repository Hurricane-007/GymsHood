
class GymRating {
  final String? id;
  final String userId;
  final String gymId;
  final int rating; // 1 to 5
  final String? feedback;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GymRating({
    this.id,
    required this.userId,
    required this.gymId,
    required this.rating,
    this.feedback,
    this.createdAt,
    this.updatedAt,
  });

  factory GymRating.fromJson(Map<String, dynamic> json, {String? id}) {
    return GymRating(
      id: id,
      userId: json['userId'] as String,
      gymId: json['gymId'] as String,
      rating: json['rating'] as int,
      feedback: json['feedback'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'gymId': gymId,
      'rating': rating,
      'feedback': feedback,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }
}

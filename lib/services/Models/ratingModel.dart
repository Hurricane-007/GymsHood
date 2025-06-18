class GymRating {
  final String id;
  final String userId;
  final String gymId;
  final int rating;
  final String? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  GymRating({
    required this.id,
    required this.userId,
    required this.gymId,
    required this.rating,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GymRating.fromJson(Map<String, dynamic> json) {
    return GymRating(
      id: json['_id'],
      userId: json['userId'],
      gymId: json['gymId'],
      rating: json['rating'],
      feedback: json['feedback'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'gymId': gymId,
      'rating': rating,
      if (feedback != null) 'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

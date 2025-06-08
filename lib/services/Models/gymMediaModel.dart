import 'package:flutter/material.dart';

class GymMedia {
  final List<String> mediaUrls;
  final String logoUrl;

  GymMedia({
    required this.mediaUrls,
    required this.logoUrl,
  });

  factory GymMedia.fromJson(Map<String, dynamic> json) {
    return GymMedia(
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      logoUrl: json['logoUrl'] ?? '',
    );
  }
}


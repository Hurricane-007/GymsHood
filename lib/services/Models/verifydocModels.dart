import 'package:flutter/foundation.dart';

@immutable
class VerificationDocument {
  final String documentType;
  final String documentUrl;
  final DateTime uploadedAt;

  const VerificationDocument({
    required this.documentType,
    required this.documentUrl,
    required this.uploadedAt,
  });

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    return VerificationDocument(
      documentType: json['documentType'] ?? '',
      documentUrl: json['documentUrl'] ?? '',
      uploadedAt: DateTime.tryParse(json['uploadedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'documentUrl': documentUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}

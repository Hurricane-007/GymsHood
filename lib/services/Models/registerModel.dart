class RegisterEntry {
  final String userId;
  final String userName;
  final String? photo;
  final String? contactNo;
  final String? userPlanId;
  final double? perDayCost;
  final DateTime? checkInTime;
  final DateTime? checkOutTimeCalc;
  final DateTime? checkOutTimeReal;

  RegisterEntry({
    required this.userId,
    required this.userName,
    this.photo,
    this.contactNo,
    this.userPlanId,
    this.perDayCost,
    this.checkInTime,
    this.checkOutTimeCalc,
    this.checkOutTimeReal,
  });

  factory RegisterEntry.fromJson(Map<String, dynamic> json) {
    return RegisterEntry(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      photo: json['photo'],
      contactNo: json['contactNo'],
      userPlanId: json['userPlanId'],
      perDayCost: (json['perDayCost'] ?? 0).toDouble(),
      checkInTime: json['checkInTime'] != null ? DateTime.parse(json['checkInTime']) : null,
      checkOutTimeCalc: json['checkOutTimeCalc'] != null ? DateTime.parse(json['checkOutTimeCalc']) : null,
      checkOutTimeReal: json['checkOutTimeReal'] != null ? DateTime.parse(json['checkOutTimeReal']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'photo': photo,
      'contactNo': contactNo,
      'userPlanId': userPlanId,
      'perDayCost': perDayCost,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTimeCalc': checkOutTimeCalc?.toIso8601String(),
      'checkOutTimeReal': checkOutTimeReal?.toIso8601String(),
    };
  }
}

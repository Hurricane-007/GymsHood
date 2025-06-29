class WalletTransaction {
  final String? id;
  final String userId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpayRefundId;
  final String? reason;
  final DateTime transactionDate;
  final String? adminTransferTxnId;
  final String? adminNotes;
  final TransactionMetadata? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WalletTransaction({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    this.status = TransactionStatus.Pending,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpayRefundId,
    this.reason,
    DateTime? transactionDate,
    this.adminTransferTxnId,
    this.adminNotes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  }) : transactionDate = transactionDate ?? DateTime.now();

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['_id'],
      userId: json['userId'],
      amount: (json['amount'] is int) ? (json['amount'] as int).toDouble() : json['amount'].toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TransactionType.Credit,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TransactionStatus.Pending,
      ),
      razorpayOrderId: json['razorpayOrderId'],
      razorpayPaymentId: json['razorpayPaymentId'],
      razorpayRefundId: json['razorpayRefundId'],
      reason: json['reason'],
      transactionDate: DateTime.parse(json['transactionDate']),
      adminTransferTxnId: json['adminTransferTxnId'],
      adminNotes: json['adminNotes'],
      metadata: json['metadata'] != null 
          ? TransactionMetadata.fromJson(json['metadata']) 
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
      if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
      if (razorpayRefundId != null) 'razorpayRefundId': razorpayRefundId,
      if (reason != null) 'reason': reason,
      'transactionDate': transactionDate.toIso8601String(),
      if (adminTransferTxnId != null) 'adminTransferTxnId': adminTransferTxnId,
      if (adminNotes != null) 'adminNotes': adminNotes,
      if (metadata != null) 'metadata': metadata!.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  WalletTransaction copyWith({
    String? id,
    String? userId,
    double? amount,
    TransactionType? type,
    TransactionStatus? status,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpayRefundId,
    String? reason,
    DateTime? transactionDate,
    String? adminTransferTxnId,
    String? adminNotes,
    TransactionMetadata? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayRefundId: razorpayRefundId ?? this.razorpayRefundId,
      reason: reason ?? this.reason,
      transactionDate: transactionDate ?? this.transactionDate,
      adminTransferTxnId: adminTransferTxnId ?? this.adminTransferTxnId,
      adminNotes: adminNotes ?? this.adminNotes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WalletTransaction(id: $id, userId: $userId, amount: $amount, type: $type, status: $status, transactionDate: $transactionDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalletTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum TransactionType {
  Credit,
  Debit,
}

enum TransactionStatus {
  Pending,
  Completed,
  Failed,
  Refunded,
}

class TransactionMetadata {
  final String? planId;
  final String? gymId;
  final String? userPlanId;
  final double? gymShare;
  final double? platformShare;
  final String? refundReason;
  final String? relatedTransaction;

  TransactionMetadata({
    this.planId,
    this.gymId,
    this.userPlanId,
    this.gymShare,
    this.platformShare,
    this.refundReason,
    this.relatedTransaction,
  });

  factory TransactionMetadata.fromJson(Map<String, dynamic> json) {
    return TransactionMetadata(
      planId: json['planId'],
      gymId: json['gymId'],
      userPlanId: json['userPlanId'],
      gymShare: json['gymShare']?.toDouble(),
      platformShare: json['platformShare']?.toDouble(),
      refundReason: json['refundReason'],
      relatedTransaction: json['relatedTransaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (planId != null) 'planId': planId,
      if (gymId != null) 'gymId': gymId,
      if (userPlanId != null) 'userPlanId': userPlanId,
      if (gymShare != null) 'gymShare': gymShare,
      if (platformShare != null) 'platformShare': platformShare,
      if (refundReason != null) 'refundReason': refundReason,
      if (relatedTransaction != null) 'relatedTransaction': relatedTransaction,
    };
  }

  TransactionMetadata copyWith({
    String? planId,
    String? gymId,
    String? userPlanId,
    double? gymShare,
    double? platformShare,
    String? refundReason,
    String? relatedTransaction,
  }) {
    return TransactionMetadata(
      planId: planId ?? this.planId,
      gymId: gymId ?? this.gymId,
      userPlanId: userPlanId ?? this.userPlanId,
      gymShare: gymShare ?? this.gymShare,
      platformShare: platformShare ?? this.platformShare,
      refundReason: refundReason ?? this.refundReason,
      relatedTransaction: relatedTransaction ?? this.relatedTransaction,
    );
  }

  @override
  String toString() {
    return 'TransactionMetadata(planId: $planId, gymId: $gymId, gymShare: $gymShare, platformShare: $platformShare)';
  }
} 
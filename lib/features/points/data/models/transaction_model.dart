class TransactionModel {
  final String id;
  final int delta;
  final String reason;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.delta,
    required this.reason,
    this.metadata,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      delta: (json['delta'] as num).toInt(),
      reason: json['reason'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delta': delta,
      'reason': reason,
      if (metadata != null) 'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

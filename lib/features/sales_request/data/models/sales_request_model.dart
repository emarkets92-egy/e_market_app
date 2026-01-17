class SalesRequestModel {
  final String id;
  final String userId;
  final List<String> productIds;
  final String status; // pending, contacted, converted, rejected
  final String? notes;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalesRequestModel({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.status,
    this.notes,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesRequestModel.fromJson(Map<String, dynamic> json) {
    return SalesRequestModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productIds: (json['productIds'] as List<dynamic>).map((e) => e as String).toList(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      assignedTo: json['assignedTo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productIds': productIds,
      'status': status,
      if (notes != null) 'notes': notes,
      if (assignedTo != null) 'assignedTo': assignedTo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SalesRequestModel copyWith({
    String? id,
    String? userId,
    List<String>? productIds,
    String? status,
    String? notes,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalesRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productIds: productIds ?? this.productIds,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

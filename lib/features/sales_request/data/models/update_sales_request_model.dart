class UpdateSalesRequestModel {
  final String? status; // pending, contacted, converted, rejected
  final String? notes;
  final String? assignedTo;

  UpdateSalesRequestModel({
    this.status,
    this.notes,
    this.assignedTo,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (status != null) json['status'] = status;
    if (notes != null) json['notes'] = notes;
    if (assignedTo != null) json['assignedTo'] = assignedTo;
    return json;
  }
}

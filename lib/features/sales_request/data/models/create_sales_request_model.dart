class CreateSalesRequestModel {
  final List<String> productIds;
  final String? notes;

  CreateSalesRequestModel({
    required this.productIds,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'productIds': productIds,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

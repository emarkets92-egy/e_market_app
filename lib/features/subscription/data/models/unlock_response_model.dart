class UnlockResponseModel {
  final bool unlocked;
  final int cost;
  final String message;
  final int pointsBalance;

  UnlockResponseModel({
    required this.unlocked,
    required this.cost,
    required this.message,
    required this.pointsBalance,
  });

  factory UnlockResponseModel.fromJson(Map<String, dynamic> json) {
    return UnlockResponseModel(
      unlocked: json['unlocked'] as bool,
      cost: (json['cost'] as num).toInt(),
      message: json['message'] as String,
      pointsBalance: (json['pointsBalance'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unlocked': unlocked,
      'cost': cost,
      'message': message,
      'pointsBalance': pointsBalance,
    };
  }
}

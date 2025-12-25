class PointsBalanceModel {
  final int pointsBalance;

  PointsBalanceModel({required this.pointsBalance});

  factory PointsBalanceModel.fromJson(Map<String, dynamic> json) {
    return PointsBalanceModel(
      pointsBalance: (json['pointsBalance'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'pointsBalance': pointsBalance};
  }
}

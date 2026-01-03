class ResetPasswordRequestModel {
  final String token;
  final String newPassword;

  ResetPasswordRequestModel({required this.token, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {'token': token, 'newPassword': newPassword};
  }
}

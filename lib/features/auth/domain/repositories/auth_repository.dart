import '../../data/models/user_model.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/register_request_model.dart';
import '../../data/models/forgot_password_request_model.dart';
import '../../data/models/forgot_password_response_model.dart';
import '../../data/models/reset_password_request_model.dart';
import '../../data/models/reset_password_response_model.dart';
import '../../data/models/update_profile_request_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<AuthResponseModel> completeProfile(RegisterRequestModel request);
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<void> logout();
  Future<ForgotPasswordResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  );
  Future<ResetPasswordResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  );
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UpdateProfileRequestModel request);
  Future<UserModel?> getCurrentUser();
  Future<bool> isAuthenticated();
}

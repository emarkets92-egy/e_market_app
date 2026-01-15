import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';
import '../models/register_request_model.dart';
import '../models/login_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/forgot_password_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/reset_password_response_model.dart';
import '../models/update_profile_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final request = LoginRequestModel(email: email, password: password);
      final response = await remoteDataSource.login(request);
      // Save tokens locally
      await localDataSource.saveAccessToken(response.accessToken);
      await localDataSource.saveRefreshToken(response.refreshToken);
      await localDataSource.saveUser(response.user);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await remoteDataSource.register(request);

      // Save tokens locally
      await localDataSource.saveAccessToken(response.accessToken);
      await localDataSource.saveRefreshToken(response.refreshToken);
      await localDataSource.saveUser(response.user);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> completeProfile(RegisterRequestModel request) async {
    try {
      final response = await remoteDataSource.completeProfile(request);

      // Update user locally
      await localDataSource.saveUser(response.user);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await remoteDataSource.refreshToken(refreshToken);

      // Save new tokens locally
      await localDataSource.saveAccessToken(response.accessToken);
      await localDataSource.saveRefreshToken(response.refreshToken);
      await localDataSource.saveUser(response.user);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Call server logout API
      await remoteDataSource.logout();
    } catch (e) {
      // Even if API call fails, clear local tokens
    } finally {
      // Always clear local data
      await localDataSource.clearAll();
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return await localDataSource.getUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await localDataSource.getAccessToken();
    return token != null;
  }

  @override
  Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request) async {
    try {
      return await remoteDataSource.forgotPassword(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request) async {
    try {
      return await remoteDataSource.resetPassword(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final userModel = await remoteDataSource.getProfile();

      // Save user locally
      await localDataSource.saveUser(userModel);

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileRequestModel request) async {
    try {
      final userModel = await remoteDataSource.updateProfile(request);

      // Update user locally
      await localDataSource.saveUser(userModel);

      return userModel;
    } catch (e) {
      rethrow;
    }
  }
}

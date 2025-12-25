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

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    print('[LOGIN REPOSITORY] Starting login process');
    print('[LOGIN REPOSITORY] Email: $email');
    print('[LOGIN REPOSITORY] Password length: ${password.length}');

    try {
      final request = LoginRequestModel(email: email, password: password);
      print('[LOGIN REPOSITORY] Created login request model');

      final response = await remoteDataSource.login(request);
      print('[LOGIN REPOSITORY] Received response from remote data source');
      print(
        '[LOGIN REPOSITORY] User: ${response.user.email} (ID: ${response.user.id})',
      );

      // Save tokens locally
      print('[LOGIN REPOSITORY] Saving tokens to local storage...');
      await localDataSource.saveAccessToken(response.accessToken);
      print('[LOGIN REPOSITORY] Access token saved successfully');

      await localDataSource.saveRefreshToken(response.refreshToken);
      print('[LOGIN REPOSITORY] Refresh token saved successfully');

      await localDataSource.saveUser(response.user);
      print('[LOGIN REPOSITORY] User data saved successfully');

      print('[LOGIN REPOSITORY] Login process completed successfully');
      return response;
    } catch (e, stackTrace) {
      print('[LOGIN REPOSITORY] Login process failed');
      print('[LOGIN REPOSITORY] Error type: ${e.runtimeType}');
      print('[LOGIN REPOSITORY] Error message: $e');
      print('[LOGIN REPOSITORY] Stack trace: $stackTrace');
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
  Future<AuthResponseModel> completeProfile(
    RegisterRequestModel request,
  ) async {
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
  Future<ForgotPasswordResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      return await remoteDataSource.forgotPassword(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ResetPasswordResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    try {
      return await remoteDataSource.resetPassword(request);
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

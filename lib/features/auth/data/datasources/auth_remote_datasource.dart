import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/auth_response_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/forgot_password_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/reset_password_response_model.dart';
import '../models/update_profile_request_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
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
  Future<UserModel> updateProfile(UpdateProfileRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    print('[LOGIN API] Starting login request');
    print('[LOGIN API] Endpoint: ${Endpoints.login}');
    print('[LOGIN API] Request data: {email: ${request.email}, password: ***}');

    try {
      final response = await apiClient.post(
        Endpoints.login,
        data: request.toJson(),
      );

      print('[LOGIN API] Login request successful');
      print('[LOGIN API] Response status code: ${response.statusCode}');
      print(
        '[LOGIN API] Response data keys: ${response.data is Map ? (response.data as Map).keys.join(", ") : "N/A"}',
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      print('[LOGIN API] Auth response parsed successfully');
      print('[LOGIN API] User ID: ${authResponse.user.id}');
      print(
        '[LOGIN API] Access token length: ${authResponse.accessToken.length}',
      );
      print(
        '[LOGIN API] Refresh token length: ${authResponse.refreshToken.length}',
      );

      return authResponse;
    } on DioException catch (e) {
      print('[LOGIN API] Login request failed with DioException');
      print('[LOGIN API] Error type: ${e.type}');
      print('[LOGIN API] Error message: ${e.message}');
      print(
        '[LOGIN API] Response status code: ${e.response?.statusCode ?? "N/A"}',
      );
      print('[LOGIN API] Response data: ${e.response?.data ?? "N/A"}');
      print('[LOGIN API] Request path: ${e.requestOptions.path}');
      print('[LOGIN API] Request method: ${e.requestOptions.method}');
      if (e.response?.data != null) {
        print('[LOGIN API] Error response body: ${e.response!.data}');
      }
      rethrow;
    } catch (e, stackTrace) {
      print('[LOGIN API] Login request failed with unexpected error');
      print('[LOGIN API] Error type: ${e.runtimeType}');
      print('[LOGIN API] Error message: $e');
      print('[LOGIN API] Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await apiClient.post(
        Endpoints.register,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> completeProfile(
    RegisterRequestModel request,
  ) async {
    try {
      final response = await apiClient.post(
        Endpoints.completeProfile,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        Endpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(Endpoints.logout);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ForgotPasswordResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      final response = await apiClient.post(
        Endpoints.forgotPassword,
        data: request.toJson(),
      );
      return ForgotPasswordResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ResetPasswordResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    try {
      final response = await apiClient.post(
        Endpoints.resetPassword,
        data: request.toJson(),
      );
      return ResetPasswordResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileRequestModel request) async {
    try {
      final response = await apiClient.patch(
        Endpoints.updateProfile,
        data: request.toJson(),
      );
      return UserModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}

import 'dart:convert';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> saveAccessToken(String token) async {
    await SecureStorage.saveAccessToken(token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await SecureStorage.getAccessToken();
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await SecureStorage.saveRefreshToken(token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await SecureStorage.getRefreshToken();
  }

  @override
  Future<void> saveUser(UserModel user) async {
    // Convert to JSON and store
    final json = jsonEncode(user.toJson());
    await LocalStorage.saveUser(json);
  }

  @override
  Future<UserModel?> getUser() async {
    final json = LocalStorage.getUser();
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final userModel = UserModel.fromJson(map);
      return userModel;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearAll() async {
    await SecureStorage.clearAll();
    await LocalStorage.clearUser();
  }
}

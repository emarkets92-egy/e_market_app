import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  /// Handles secure storage read errors gracefully, especially on Windows
  /// when the storage file is corrupted or locked
  static Future<String?> _handleReadError(Future<String?> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      // Handle Windows-specific errors where the file is corrupted or locked
      if (Platform.isWindows) {
        // If it's a file access error, try to clear the corrupted storage
        if (e.toString().contains('PathAccessException') || 
            e.toString().contains('Cannot delete file') ||
            e.toString().contains('being used by another process') ||
            e.toString().contains('CryptUnprotectData')) {
          try {
            // Wait a bit to allow file lock to be released
            await Future.delayed(const Duration(milliseconds: 200));
            // Try to clear the corrupted storage (this may fail if file is locked)
            await _storage.deleteAll().catchError((_) {
              // Ignore errors when trying to clear locked file
            });
          } catch (_) {
            // If we can't clear, just return null
            // The storage will be recreated on next write
          }
        }
      }
      // Return null on any read error - app can continue without token
      return null;
    }
  }

  /// Handles secure storage write errors gracefully, especially on Windows
  /// when the storage file is corrupted or locked
  static Future<void> _handleWriteError(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (e) {
      // Handle Windows-specific errors where the file is corrupted or locked
      if (Platform.isWindows) {
        // If it's a file access error, try to clear the corrupted storage first
        if (e.toString().contains('PathAccessException') || 
            e.toString().contains('Cannot delete file') ||
            e.toString().contains('being used by another process') ||
            e.toString().contains('CryptUnprotectData')) {
          try {
            // Wait a bit to allow file lock to be released
            await Future.delayed(const Duration(milliseconds: 200));
            // Try to clear the corrupted storage
            await _storage.deleteAll().catchError((_) {
              // Ignore errors when trying to clear locked file
            });
            // Retry the operation once after clearing
            await Future.delayed(const Duration(milliseconds: 100));
            await operation();
          } catch (_) {
            // If retry also fails, silently ignore
            // The user may need to restart the app or manually delete the file
          }
        }
      }
      // For write operations, errors are silently handled
      // The app can continue without saving the token
    }
  }

  static Future<void> saveAccessToken(String token) async {
    await _handleWriteError(() async {
      await _storage.write(key: AppConstants.keyAccessToken, value: token);
    });
  }

  static Future<String?> getAccessToken() async {
    return await _handleReadError(() async {
      return await _storage.read(key: AppConstants.keyAccessToken);
    });
  }

  static Future<void> saveRefreshToken(String token) async {
    await _handleWriteError(() async {
      await _storage.write(key: AppConstants.keyRefreshToken, value: token);
    });
  }

  static Future<String?> getRefreshToken() async {
    return await _handleReadError(() async {
      return await _storage.read(key: AppConstants.keyRefreshToken);
    });
  }

  static Future<void> clearAll() async {
    await _handleWriteError(() async {
      await _storage.deleteAll();
    });
  }
}

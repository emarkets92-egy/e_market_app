import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class WindowsUpdateInstaller {
  WindowsUpdateInstaller({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(minutes: 5), followRedirects: true));

  final Dio _dio;

  static const List<String> defaultSilentArgs = <String>['/SILENT', '/VERYSILENT', '/NORESTART'];

  void _validateWindowsUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw Exception('Invalid download URL.');
    }
    if (!url.toLowerCase().endsWith('.exe')) {
      throw Exception('downloadUrl must be a direct .exe link (not a web page): $url');
    }
  }

  Future<File> downloadInstaller({
    required String downloadUrl,
    required String versionLabel,
    String? sha256Hex,
    void Function(double progress)? onProgress,
  }) async {
    _validateWindowsUrl(downloadUrl);

    final tempDir = await getTemporaryDirectory();
    final fileName = 'e_market_app_windows_${versionLabel}_${downloadUrl.split('/').last}';
    final file = File('${tempDir.path}/$fileName');

    await _dio.download(
      downloadUrl,
      file.path,
      onReceiveProgress: (received, total) {
        if (onProgress != null && total > 0) {
          onProgress(received / total);
        }
      },
    );

    if (sha256Hex != null && sha256Hex.trim().isNotEmpty) {
      await _verifySha256(file, sha256Hex.trim());
    }

    return file;
  }

  Future<void> installInnoSetup({required File installerExe, List<String>? installerArgs}) async {
    if (!Platform.isWindows) {
      throw Exception('Windows installer can only run on Windows.');
    }
    if (!await installerExe.exists()) {
      throw Exception('Installer not found: ${installerExe.path}');
    }

    final args = (installerArgs == null || installerArgs.isEmpty) ? defaultSilentArgs : installerArgs;

    await Process.start(installerExe.path, args, mode: ProcessStartMode.detached);
  }

  Future<void> _verifySha256(File file, String expectedHex) async {
    final digest = await sha256.bind(file.openRead()).first;
    final computed = digest.toString().toLowerCase();
    final expected = expectedHex.toLowerCase();
    if (computed != expected) {
      throw Exception('Checksum mismatch. Expected $expected, got $computed');
    }
  }
}

// Web stub: the real implementation uses dart:io and cannot compile on Web.

class WindowsUpdateInstaller {
  Future<Object> downloadInstaller({
    required String downloadUrl,
    required String versionLabel,
    String? sha256Hex,
    void Function(double progress)? onProgress,
  }) {
    throw UnsupportedError('WindowsUpdateInstaller is not supported on Web.');
  }

  Future<void> installInnoSetup({required Object installerExe, List<String>? installerArgs}) {
    throw UnsupportedError('WindowsUpdateInstaller is not supported on Web.');
  }
}


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../domain/repositories/version_repository.dart';
import 'version_state.dart';

class VersionCubit extends Cubit<VersionState> {
  final VersionRepository versionRepository;

  VersionCubit({required this.versionRepository}) : super(VersionInitial());

  Future<void> checkVersion() async {
    emit(VersionChecking());

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final result = await versionRepository.checkVersion();

      // Compare versions - if current is less than minimum, update is required
      final needsUpdate = _compareVersions(currentVersion, result.minimumVersion) < 0;

      if (needsUpdate && result.forceUpdate) {
        emit(
          VersionUpdateRequired(
            currentVersion: currentVersion,
            latestVersion: result.latestVersion,
            downloadUrl: result.downloadUrl,
            releaseNotes: result.releaseNotes,
          ),
        );
      } else {
        emit(VersionUpToDate());
      }
    } catch (e) {
      // For mandatory updates, block on error to ensure version check works
      // You can change this to VersionUpToDate() if you want to allow app to continue on error
      emit(VersionCheckError(message: e.toString()));
    }
  }

  // Compare version strings (e.g., "1.0.0" vs "1.0.1")
  // Returns: -1 if version1 < version2, 0 if equal, 1 if version1 > version2
  int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map((v) => int.tryParse(v) ?? 0).toList();
    final v2Parts = version2.split('.').map((v) => int.tryParse(v) ?? 0).toList();

    // Ensure both have at least 3 parts
    while (v1Parts.length < 3) {
      v1Parts.add(0);
    }
    while (v2Parts.length < 3) {
      v2Parts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      final v1 = i < v1Parts.length ? v1Parts[i] : 0;
      final v2 = i < v2Parts.length ? v2Parts[i] : 0;

      if (v1 < v2) return -1;
      if (v1 > v2) return 1;
    }
    return 0;
  }
}

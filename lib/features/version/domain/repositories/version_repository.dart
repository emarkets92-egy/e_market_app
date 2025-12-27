import '../entities/version_check_result.dart';

abstract class VersionRepository {
  Future<VersionCheckResult> checkVersion();
}


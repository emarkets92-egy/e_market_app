import '../../domain/repositories/version_repository.dart';
import '../../domain/entities/version_check_result.dart';
import '../datasources/version_remote_datasource.dart';

class VersionRepositoryImpl implements VersionRepository {
  final VersionRemoteDataSource remoteDataSource;

  VersionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<VersionCheckResult> checkVersion() async {
    try {
      final data = await remoteDataSource.checkVersion();
      return VersionCheckResult.fromJson(data);
    } catch (e) {
      // If check fails, rethrow to handle in cubit
      rethrow;
    }
  }
}


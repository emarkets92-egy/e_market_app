import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

abstract class VersionRemoteDataSource {
  Future<Map<String, dynamic>> checkVersion();
}

class VersionRemoteDataSourceImpl implements VersionRemoteDataSource {
  final ApiClient apiClient;

  VersionRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> checkVersion() async {
    final response = await apiClient.get(Endpoints.checkVersion);
    return response.data as Map<String, dynamic>;
  }
}

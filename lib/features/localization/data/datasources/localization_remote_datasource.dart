import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/country_model.dart';

abstract class LocalizationRemoteDataSource {
  Future<List<CountryModel>> getCountries({String? locale});
}

class LocalizationRemoteDataSourceImpl implements LocalizationRemoteDataSource {
  final ApiClient apiClient;

  LocalizationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CountryModel>> getCountries({String? locale}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (locale != null) {
        queryParams['locale'] = locale;
      }

      final response = await apiClient.get(Endpoints.countries, queryParameters: queryParams);

      if (response.data is List) {
        return (response.data as List).map((json) => CountryModel.fromJson(json)).toList();
      }
      return [];
    } on DioException {
      rethrow;
    }
  }
}

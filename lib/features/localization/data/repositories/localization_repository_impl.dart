import '../../domain/repositories/localization_repository.dart';
import '../datasources/localization_remote_datasource.dart';
import '../models/country_model.dart';

class LocalizationRepositoryImpl implements LocalizationRepository {
  final LocalizationRemoteDataSource remoteDataSource;

  LocalizationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CountryModel>> getCountries({String? locale}) async {
    try {
      final result = await remoteDataSource.getCountries(locale: locale);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}

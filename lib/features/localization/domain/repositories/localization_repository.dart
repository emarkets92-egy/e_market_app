import '../../data/models/country_model.dart';

abstract class LocalizationRepository {
  Future<List<CountryModel>> getCountries({String? locale});
}

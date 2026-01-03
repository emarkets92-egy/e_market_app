import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/localization_repository.dart';
import '../../data/models/country_model.dart';
import '../cubit/localization_state.dart';

class LocalizationCubit extends Cubit<LocalizationState> {
  final LocalizationRepository _repository;

  LocalizationCubit(this._repository) : super(const LocalizationState.initial());

  Future<void> loadCountries({String? locale}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final countries = await _repository.getCountries(locale: locale);
      emit(state.copyWith(isLoading: false, countries: countries, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  String? getCountryName(int countryId) {
    final country = state.countries.firstWhere(
      (c) => c.id == countryId,
      orElse: () => CountryModel(id: 0, code: '', name: ''),
    );
    return country.id != 0 ? country.name : null;
  }
}

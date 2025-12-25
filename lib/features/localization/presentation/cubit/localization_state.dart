import '../../data/models/country_model.dart';

class LocalizationState {
  final bool isLoading;
  final List<CountryModel> countries;
  final String? error;

  const LocalizationState({
    this.isLoading = false,
    this.countries = const [],
    this.error,
  });

  const LocalizationState.initial()
    : isLoading = false,
      countries = const [],
      error = null;

  const LocalizationState.loading()
    : isLoading = true,
      countries = const [],
      error = null;

  LocalizationState copyWith({
    bool? isLoading,
    List<CountryModel>? countries,
    String? error,
  }) {
    return LocalizationState(
      isLoading: isLoading ?? this.isLoading,
      countries: countries ?? this.countries,
      error: error ?? this.error,
    );
  }
}

class HomeState {
  final bool isLoading;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.error,
  });

  const HomeState.initial()
      : isLoading = false,
        error = null;

  const HomeState.loading()
      : isLoading = true,
        error = null;

  HomeState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}


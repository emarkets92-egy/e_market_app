import '../../data/models/user_model.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  final bool isForgotPasswordLoading;
  final bool isForgotPasswordSuccess;
  final bool isResetPasswordLoading;
  final bool isResetPasswordSuccess;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isForgotPasswordLoading = false,
    this.isForgotPasswordSuccess = false,
    this.isResetPasswordLoading = false,
    this.isResetPasswordSuccess = false,
  });

  const AuthState.initial()
    : isLoading = false,
      isAuthenticated = false,
      user = null,
      error = null,
      isForgotPasswordLoading = false,
      isForgotPasswordSuccess = false,
      isResetPasswordLoading = false,
      isResetPasswordSuccess = false;

  const AuthState.loading()
    : isLoading = true,
      isAuthenticated = false,
      user = null,
      error = null,
      isForgotPasswordLoading = false,
      isForgotPasswordSuccess = false,
      isResetPasswordLoading = false,
      isResetPasswordSuccess = false;

  const AuthState.authenticated(this.user)
    : isLoading = false,
      isAuthenticated = true,
      error = null,
      isForgotPasswordLoading = false,
      isForgotPasswordSuccess = false,
      isResetPasswordLoading = false,
      isResetPasswordSuccess = false;

  const AuthState.error(this.error)
    : isLoading = false,
      isAuthenticated = false,
      user = null,
      isForgotPasswordLoading = false,
      isForgotPasswordSuccess = false,
      isResetPasswordLoading = false,
      isResetPasswordSuccess = false;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
    bool? isForgotPasswordLoading,
    bool? isForgotPasswordSuccess,
    bool? isResetPasswordLoading,
    bool? isResetPasswordSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      isForgotPasswordLoading:
          isForgotPasswordLoading ?? this.isForgotPasswordLoading,
      isForgotPasswordSuccess:
          isForgotPasswordSuccess ?? this.isForgotPasswordSuccess,
      isResetPasswordLoading:
          isResetPasswordLoading ?? this.isResetPasswordLoading,
      isResetPasswordSuccess:
          isResetPasswordSuccess ?? this.isResetPasswordSuccess,
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../cubit/auth_state.dart';
import '../../data/models/register_request_model.dart';
import '../../data/models/forgot_password_request_model.dart';
import '../../data/models/reset_password_request_model.dart';
import '../../data/models/update_profile_request_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await _repository.login(email, password);
      emit(state.copyWith(isLoading: false, user: result.user, isAuthenticated: true, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString(), isAuthenticated: false));
    }
  }

  Future<void> register(RegisterRequestModel request) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await _repository.register(request);
      emit(state.copyWith(isLoading: false, user: result.user, isAuthenticated: true, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString(), isAuthenticated: false));
    }
  }

  Future<void> completeProfile(RegisterRequestModel request) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await _repository.completeProfile(request);
      emit(state.copyWith(isLoading: false, user: result.user, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState.initial());
  }

  Future<void> checkAuthStatus() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final isAuthenticated = await _repository.isAuthenticated();
      if (isAuthenticated) {
        try {
          // Fetch fresh profile from API
          final user = await _repository.getProfile();
          emit(state.copyWith(isLoading: false, isAuthenticated: true, user: user, error: null));
        } catch (e) {
          // If profile fetch fails, clear tokens and reset state
          // This handles both network errors and authentication errors
          // Network errors will still log out for security (token might be invalid)
          try {
            await _repository.logout();
          } catch (logoutError) {
            // Even if logout API call fails, state is reset
            // ignore
          }
          emit(const AuthState.initial());
        }
      } else {
        emit(const AuthState.initial());
      }
    } catch (e) {
      // Handle any unexpected errors in isAuthenticated check
      // ignore
      emit(const AuthState.initial());
    }
  }

  Future<void> getProfile() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final user = await _repository.getProfile();
      emit(state.copyWith(isLoading: false, user: user, isAuthenticated: true, error: null));
    } catch (e) {
      // If profile fetch fails, clear tokens and reset state
      await _repository.logout();
      emit(const AuthState.initial());
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(state.copyWith(isForgotPasswordLoading: true, error: null, isForgotPasswordSuccess: false));

    try {
      final request = ForgotPasswordRequestModel(email: email);
      await _repository.forgotPassword(request);
      emit(state.copyWith(isForgotPasswordLoading: false, isForgotPasswordSuccess: true, error: null));
    } catch (e) {
      emit(state.copyWith(isForgotPasswordLoading: false, isForgotPasswordSuccess: false, error: e.toString()));
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    emit(state.copyWith(isResetPasswordLoading: true, error: null, isResetPasswordSuccess: false));

    try {
      final request = ResetPasswordRequestModel(token: token, newPassword: newPassword);
      await _repository.resetPassword(request);
      emit(state.copyWith(isResetPasswordLoading: false, isResetPasswordSuccess: true, error: null));
    } catch (e) {
      emit(state.copyWith(isResetPasswordLoading: false, isResetPasswordSuccess: false, error: e.toString()));
    }
  }

  Future<void> updateProfile(UpdateProfileRequestModel request) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final updatedUser = await _repository.updateProfile(request);
      emit(state.copyWith(isLoading: false, user: updatedUser, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void updatePoints(int newPoints) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(points: newPoints);
      emit(state.copyWith(user: updatedUser));
    }
  }

  /// Force logout when authentication fails (e.g., 401 errors)
  /// This clears the state without making an API call
  void forceLogout() {
    emit(const AuthState.initial());
  }
}

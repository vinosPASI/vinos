import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vinosfront/features/auth/data/repositories/auth_repository_impl.dart';
import '../../../../core/utils/secure_storage_service.dart';
import 'package:vinosfront/features/auth/domain/entities/user_model.dart';

class AuthState {
  final bool isLoading;
  final UserResponse? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    UserResponse? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.login(email, password);

      // Save token securely
      final secureStorage = _ref.read(secureStorageProvider);
      await secureStorage.saveToken(user.accessToken);

      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final secureStorage = _ref.read(secureStorageProvider);
    await secureStorage.deleteToken();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

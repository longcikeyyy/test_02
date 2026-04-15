import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/auth_profile.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthState {
  const AuthState({this.token, this.isLoading = false, this.error});

  final String? token;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    String? token,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ApiClient(token: null);
  return AuthRepositoryImpl(api);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final token = ref.watch(authProvider.select((state) => state.token));
  return ApiClient(token: token);
});

final authProfileProvider = FutureProvider.autoDispose<AuthProfile?>((
  ref,
) async {
  final token = ref.watch(authProvider.select((state) => state.token));
  if (token == null || token.isEmpty) {
    return null;
  }

  final client = ApiClient(token: token);
  try {
    final raw = await client.post('/authentication/jwt/info');
    final json = raw as Map<String, dynamic>;
    final response = json.containsKey('isSuccess')
        ? ApiResponse.fromJson(json)
        : null;
    final data = response?.data ?? json['data'] ?? json;
    final profile = _extractProfile(data, token);
    return profile;
  } catch (_) {
    return _profileFromToken(token);
  }
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<bool> register({
    required String name,
    required String phoneNumber,
    String? email,
    required String password,
    required String confirmPassword,
    int gender = 0,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.register(
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        gender: gender,
      );
      state = state.copyWith(isLoading: false, clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
    }
  }

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repository.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      state = state.copyWith(
        token: session.token,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> logout() async {
    try {
      if (state.isAuthenticated) {
        await _repository.logout();
      }
    } catch (_) {
      // Keep local logout behavior even if API logout fails.
    } finally {
      state = const AuthState();
    }
  }
}

AuthProfile _extractProfile(dynamic data, String token) {
  if (data is Map<String, dynamic>) {
    final name = _firstString(data, [
      'fullName',
      'name',
      'x-fullName',
      'x_fullName',
      'displayName',
      'userName',
      'x-userName',
    ]);
    final phoneNumber = _firstString(data, [
      'phoneNumber',
      'phone',
      'x-phone',
      'x_phone',
    ]);
    final email = _extractEmail(data);

    return AuthProfile(
      name: name ?? _profileFromToken(token).name,
      phoneNumber: phoneNumber ?? _profileFromToken(token).phoneNumber,
      email: email ?? _profileFromToken(token).email,
    );
  }

  return _profileFromToken(token);
}

AuthProfile _profileFromToken(String token) {
  final parts = token.split('.');
  if (parts.length < 2) {
    return const AuthProfile(
      name: 'Không xác định',
      phoneNumber: '-',
      email: '-',
    );
  }

  try {
    final payload =
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))))
            as Map<String, dynamic>;
    return AuthProfile(
      name:
          _firstString(payload, [
            'x-fullName',
            'fullName',
            'name',
            'x-userName',
            'userName',
          ]) ??
          'Không xác định',
      phoneNumber:
          _firstString(payload, ['x-phone', 'phone', 'phoneNumber']) ?? '-',
      email: _extractEmail(payload) ?? '-',
    );
  } catch (_) {
    return const AuthProfile(
      name: 'Không xác định',
      phoneNumber: '-',
      email: '-',
    );
  }
}

String? _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String? _extractEmail(Map<String, dynamic> json) {
  final explicitEmail = _firstString(json, ['email', 'x-email', 'x_email']);
  if (explicitEmail != null) {
    return explicitEmail;
  }

  final candidate = _firstString(json, ['userName', 'x-userName']);
  if (candidate != null && candidate.contains('@')) {
    return candidate;
  }

  return null;
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/auth_profile.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthState {
  const AuthState({
    this.token,
    this.isLoading = false,
    this.error,
    this.profile,
    this.isProfileLoading = false,
  });

  final String? token;
  final bool isLoading;
  final String? error;
  final AuthProfile? profile;
  final bool isProfileLoading;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    String? token,
    bool? isLoading,
    String? error,
    AuthProfile? profile,
    bool? isProfileLoading,
    bool clearError = false,
  }) {
    return AuthState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      profile: profile ?? this.profile,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthRepositoryFactory? repositoryFactory})
    : _repositoryFactory =
          repositoryFactory ??
          ((token) => AuthRepositoryImpl(ApiClient(token: token))),
      super(const AuthState());

  final AuthRepositoryFactory _repositoryFactory;

  AuthRepository _repository({String? token}) => _repositoryFactory(token);

  Future<bool> register({
    required String name,
    required String phoneNumber,
    String? email,
    required String password,
    required String confirmPassword,
    int gender = 0,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repository(token: null).register(
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        gender: gender,
      );
      emit(state.copyWith(isLoading: false, clearError: true));
      return true;
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
      return false;
    }
  }

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final session = await _repository(token: null).login(
        phoneNumber: phoneNumber,
        password: password,
      );
      emit(state.copyWith(
        token: session.token,
        isLoading: false,
        clearError: true,
      ));

      await loadProfile();
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  Future<void> logout() async {
    try {
      if (state.isAuthenticated) {
        await _repository(token: state.token).logout();
      }
    } catch (_) {
      // Keep local logout behavior even if API logout fails.
    } finally {
      emit(const AuthState());
    }
  }

  Future<void> loadProfile() async {
    final token = state.token;
    if (token == null || token.isEmpty) {
      emit(state.copyWith(profile: null, isProfileLoading: false));
      return;
    }
    if (state.isProfileLoading) {
      return;
    }

    emit(state.copyWith(isProfileLoading: true));
    final client = ApiClient(token: token);
    try {
      final raw = await client.post('/authentication/jwt/info');
      final json = raw as Map<String, dynamic>;
      final response = json.containsKey('isSuccess')
          ? ApiResponse.fromJson(json)
          : null;
      final data = response?.data ?? json['data'] ?? json;
      final profile = _extractProfile(data, token);
      emit(state.copyWith(profile: profile, isProfileLoading: false));
    } catch (_) {
      emit(
        state.copyWith(
          profile: _profileFromToken(token),
          isProfileLoading: false,
        ),
      );
    }
  }
}

typedef AuthRepositoryFactory = AuthRepository Function(String? token);

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

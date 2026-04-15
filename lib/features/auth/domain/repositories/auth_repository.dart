import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<void> register({
    required String name,
    required String phoneNumber,
    String? email,
    required String password,
    required String confirmPassword,
    int gender,
  });

  Future<AuthSession> login({
    required String phoneNumber,
    required String password,
    bool rememberMe,
  });

  Future<void> logout();
}

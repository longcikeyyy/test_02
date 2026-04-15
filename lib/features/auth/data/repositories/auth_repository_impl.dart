import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<void> register({
    required String name,
    required String phoneNumber,
    String? email,
    required String password,
    required String confirmPassword,
    int gender = 0,
  }) async {
    final raw = await _apiClient.post(
      '/authentication/register',
      data: {
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'gender': gender,
      },
    );

    final response = ApiResponse.fromJson(raw as Map<String, dynamic>);
    if (!response.isSuccess) {
      throw AppException(response.message ?? 'Dang ky that bai.');
    }
  }

  @override
  Future<AuthSession> login({
    required String phoneNumber,
    required String password,
    bool rememberMe = true,
  }) async {
    final raw = await _apiClient.post(
      '/authentication/jwt/login',
      data: {
        'phoneNumber': phoneNumber,
        'password': password,
        'rememberMe': rememberMe,
      },
    );

    final response = ApiResponse.fromJson(raw as Map<String, dynamic>);
    if (!response.isSuccess || response.data == null) {
      throw AppException(response.message ?? 'Dang nhap that bai.');
    }

    final data = response.data as Map<String, dynamic>;
    final token = data['tokenString'] as String?;

    if (token == null || token.isEmpty) {
      throw const AppException('Khong nhan duoc token tu he thong.');
    }

    return AuthSession(token: token);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(
      '/authentication/logout',
      data: {'isMobileDevice': 'true'},
    );
  }
}

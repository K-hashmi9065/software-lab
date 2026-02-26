import '../../domain/entities/forgot_password_request.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> register(RegisterRequest request) =>
      _remoteDataSource.register(request);

  @override
  Future<Map<String, dynamic>> login(LoginRequest request) =>
      _remoteDataSource.login(request);

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) =>
      _remoteDataSource.forgotPassword(request);

  @override
  Future<Map<String, dynamic>> verifyOtp(VerifyOtpRequest request) =>
      _remoteDataSource.verifyOtp(request);

  @override
  Future<void> resetPassword(ResetPasswordRequest request) =>
      _remoteDataSource.resetPassword(request);
}

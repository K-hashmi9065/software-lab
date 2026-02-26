import '../entities/forgot_password_request.dart';
import '../entities/login_request.dart';
import '../entities/register_request.dart';

/// Abstract contract — implemented in the data layer.
abstract class AuthRepository {
  Future<void> register(RegisterRequest request);
  Future<Map<String, dynamic>> login(LoginRequest request);
  Future<void> forgotPassword(ForgotPasswordRequest request);
  Future<Map<String, dynamic>> verifyOtp(VerifyOtpRequest request);
  Future<void> resetPassword(ResetPasswordRequest request);
}

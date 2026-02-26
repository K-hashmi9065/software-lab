/// POST /user/forgot-password
class ForgotPasswordRequest {
  final String mobile;
  const ForgotPasswordRequest({required this.mobile});
}

/// POST /user/verify-otp
class VerifyOtpRequest {
  final String otp;
  const VerifyOtpRequest({required this.otp});
}

/// POST /user/reset-password
class ResetPasswordRequest {
  final String token;
  final String password;
  final String cpassword;
  const ResetPasswordRequest({
    required this.token,
    required this.password,
    required this.cpassword,
  });
}

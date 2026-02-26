/// Pure domain entity for the login request.
class LoginRequest {
  final String email;
  final String password;
  final String role;
  final String deviceToken;
  final String type;
  final String socialId;

  const LoginRequest({
    required this.email,
    required this.password,
    this.role = 'farmer',
    this.deviceToken = '',
    this.type = 'email',
    this.socialId = '',
  });
}

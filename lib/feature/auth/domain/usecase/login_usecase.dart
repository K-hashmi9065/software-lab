import '../entities/login_request.dart';
import '../repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<Map<String, dynamic>> call(LoginRequest request) =>
      _repository.login(request);
}

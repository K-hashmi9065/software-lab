import '../entities/register_request.dart';
import '../repository/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<void> call(RegisterRequest request) => _repository.register(request);
}

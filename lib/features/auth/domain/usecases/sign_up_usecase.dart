import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repo;
  SignUpUseCase(this._repo);

  Future<Either<Failure, void>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => _repo.signUp(email: email, password: password, firstName: firstName, lastName: lastName);
}

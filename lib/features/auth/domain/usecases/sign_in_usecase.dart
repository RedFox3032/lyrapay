import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repo;
  SignInUseCase(this._repo);

  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
  }) => _repo.signIn(email: email, password: password);
}

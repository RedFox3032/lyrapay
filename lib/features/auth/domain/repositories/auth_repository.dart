import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, AppUser?>> getCurrentUser();
  Future<Either<Failure, bool>> isLyraTagAvailable(String tag);
  Future<Either<Failure, void>> claimLyraTag(String userId, String tag, {
    required String firstName,
    required String lastName,
    required String email,
  });
}

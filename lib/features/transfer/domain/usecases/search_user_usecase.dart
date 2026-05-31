import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/transfer_repository.dart';

class SearchUserUseCase {
  final TransferRepository _repo;
  SearchUserUseCase(this._repo);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(String query) => _repo.searchUsers(query);
}

import 'package:taskly/features/auth/domain/entities/user_entity.dart';
import 'package:taskly/features/auth/domain/repository/auth_repository_interface.dart';
import 'package:taskly/features/auth/domain/usecases/usecases_interfaces/auth_interfaces_usecases.dart';

class PersistLogin implements IPersistLogin {
  final AuthRepository _repository;

  PersistLogin(this._repository);

  @override
  Stream<User?> call() {
    return _repository.authStateChanges;
  }
}

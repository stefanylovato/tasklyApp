import 'package:taskly/features/auth/domain/repository/auth_repository_interface.dart';
import 'package:taskly/features/auth/domain/usecases/usecases_interfaces/auth_interfaces_usecases.dart';

class Logout implements ILogout {
  final AuthRepository _repository;

  Logout(this._repository);

  @override
  Future<void> call() async {
    try {
      await _repository.logout();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}

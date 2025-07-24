import 'package:taskly/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> logout();
  Stream<User?> get authStateChanges;
}

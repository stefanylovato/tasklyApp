import 'package:taskly/features/auth/domain/entities/user_entity.dart';

abstract class ILogin {
  Future<User> call(String email, String password);
}

abstract class IRegister {
  Future<User> call(String name, String email, String password);
}

abstract class IPersistLogin {
  Stream<User?> call();
}

abstract class ILogout {
  Future<void> call();
}

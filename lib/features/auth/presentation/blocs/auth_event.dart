import 'package:taskly/features/auth/domain/entities/user_entity.dart';

abstract class AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  AuthLoginEvent(this.email, this.password);
}

class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  AuthRegisterEvent(this.name, this.email, this.password);
}

class AuthLogoutEvent extends AuthEvent {}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthStatusChangedEvent extends AuthEvent {
  final User? user;
  AuthStatusChangedEvent(this.user);
}

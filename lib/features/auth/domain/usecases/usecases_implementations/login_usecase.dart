import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:taskly/features/auth/domain/entities/user_entity.dart';
import 'package:taskly/features/auth/domain/repository/auth_repository_interface.dart';
import 'package:taskly/features/auth/domain/usecases/usecases_interfaces/auth_interfaces_usecases.dart';

class Login implements ILogin {
  final AuthRepository _repository;

  Login(this._repository);

  @override
  Future<User> call(String email, String password) async {
    if (email.isEmpty) throw ArgumentError('Email cannot be empty');
    if (password.isEmpty) throw ArgumentError('Password cannot be empty');
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw ArgumentError('Invalid email format');
    }
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    try {
      await _repository.login(email, password);
      final user = await _repository.authStateChanges.firstWhere(
        (user) => user != null,
        orElse: () => null,
      );
      if (user == null) {
        throw Exception('User not authenticated after login');
      }
      return user;
    } catch (e) {
      throw Exception(_mapFirebaseAuthExceptionToMessage(e));
    }
  }

  String _mapFirebaseAuthExceptionToMessage(dynamic e) {
    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'too-many-requests':
          return 'Too many requests. Try again later.';
        default:
          return 'Login error: ${e.message}';
      }
    }
    return 'Login error: $e';
  }
}

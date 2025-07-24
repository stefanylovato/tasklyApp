import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:taskly/features/auth/domain/entities/user_entity.dart';
import 'package:taskly/features/auth/domain/repository/auth_repository_interface.dart';
import 'package:taskly/features/auth/domain/usecases/usecases_interfaces/auth_interfaces_usecases.dart';

class Register implements IRegister {
  final AuthRepository _repository;

  Register(this._repository);

  @override
  Future<User> call(String name, String email, String password) async {
    if (name.isEmpty) throw ArgumentError('Name cannot be empty');
    if (email.isEmpty) throw ArgumentError('Email cannot be empty');
    if (password.isEmpty) throw ArgumentError('Password cannot be empty');
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw ArgumentError('Invalid email format');
    }
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    try {
      await _repository.register(name, email, password);
      final user = await _repository.authStateChanges.firstWhere(
        (user) => user != null,
        orElse: () => null,
      );
      if (user == null) {
        throw Exception('User not created after registration');
      }
      return user;
    } catch (e) {
      throw Exception(_mapFirebaseAuthExceptionToMessage(e));
    }
  }

  String _mapFirebaseAuthExceptionToMessage(dynamic e) {
    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'The email address is already in use.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'weak-password':
          return 'The password is too weak.';
        default:
          return 'Registration error: ${e.message}';
      }
    }
    return 'Registration error: $e';
  }
}

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:taskly/features/auth/domain/entities/user_entity.dart';
import 'package:taskly/features/auth/domain/repository/auth_repository_interface.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  @override
  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.code);
    } catch (e) {
      throw Exception('Falha no login: $e');
    }
  }

  @override
  Future<void> register(String name, String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await userCredential.user!.updateProfile(displayName: name);
        await userCredential.user!.reload();
      } else {
        throw Exception('Usuário não criado');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.code);
    } catch (e) {
      throw Exception('Falha no registro: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Falha no logout: $e');
    }
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges().map(
    (firebaseUser) =>
        firebaseUser != null ? User.fromFirebaseUser(firebaseUser) : null,
  );
}

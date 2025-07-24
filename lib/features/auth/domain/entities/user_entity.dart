import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User {
  final String uid;
  final String? email;
  final String? name;

  User({required this.uid, this.email, this.name});

  factory User.fromFirebaseUser(firebase_auth.User? firebaseAuthUser) {
    if (firebaseAuthUser == null) {
      throw ArgumentError('Firebase user cannot be null');
    }
    return User(
      uid: firebaseAuthUser.uid,
      email: firebaseAuthUser.email,
      name: firebaseAuthUser.displayName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          name == other.name;

  @override
  int get hashCode => uid.hashCode ^ email.hashCode ^ name.hashCode;
}

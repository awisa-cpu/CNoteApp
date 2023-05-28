import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

//we abstracted the firebase user away to create our own AuthUser with dew fields necessary
@immutable
class AuthUser {
  final String uid;
  final String email;
  final bool isEmailVerified;

  const AuthUser({
    required this.uid,
    required this.isEmailVerified,
    required this.email,
  });

  factory AuthUser.fromFirebaseUser(User user) => AuthUser(
        uid: user.uid,
        isEmailVerified: user.emailVerified,
        email: user.email!,
      );
}

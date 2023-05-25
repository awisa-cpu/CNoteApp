import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

//we abstracted the firebase user away to create our own AuthUser with dew fields necessary
@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;

  const AuthUser({required this.isEmailVerified, required this.email});

  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        email: user.email,
      );
}

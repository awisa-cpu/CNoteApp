import 'package:mynote/services/auth/auth_files/auth_user.dart';

//this abstract class  is  dictating an INTERFACE for any authentication provider
// that we are going to add to our application later in the future
//there was need to create this layer inorder to prevent the application from interecting with firebase services directly
abstract class AuthProvider {
  AuthUser? get currentUser;

  Future<void> initialize();

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();

  Future<void> sendEmailVerification();
}

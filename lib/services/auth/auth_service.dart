import 'package:mynote/services/auth/auth_provider.dart';
import 'package:mynote/models/auth_models/auth_user.dart';
import 'package:mynote/services/auth/providers/firebase_auth_provider.dart';

//the reason for an authService being an AuthProvider is that
//it relays the messages of the given auth provider, but can have more logic

class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService(this.provider);
  //to return an instance of the auth service that is already configured with a firebase auth provider
  factory AuthService.firebase() {
    return AuthService(FirebaseAuthProvider());
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) {
    return provider.createUser(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();
  
  @override
  Future<void> sendPasswordReset({required String email}) => provider.sendPasswordReset(email: email);

}

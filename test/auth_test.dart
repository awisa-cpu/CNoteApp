import 'package:mynote/services/auth/auth_files/auth_exceptions.dart';
import 'package:mynote/services/auth/auth_files/auth_provider.dart';
import 'package:mynote/services/auth/auth_files/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Mock Authentication',
    () {
      final provider = MockAuthProvider();
      //testing provider.isInitialized
      test(
        'Should not be initialized to begin with',
        () {
          expect(provider._isInitialized, false);
        },
      );

      //testing logging out
      test(
        'Cannot logout if not initialized',
        () {
          expect(
            provider.logOut(),
            throwsA(const TypeMatcher<NotInitializedException>()),
          );
        },
      );

      //testing provider initialization
      test(
        'Should be able to be initialized',
        () async {
          await provider.initialize();
          expect(provider.isInitialized, true);
        },
      );

      //testing null user to begin with
      test(
        'User should be null upon initialization',
        () {
          expect(provider.currentUser, null);
        },
      );

      //testing time required to initialize; this is an async test of testing timeout
      test(
        'Should be able to initialize in less then 2 seconds',
        () async {
          await provider.initialize();
          expect(provider.isInitialized, true);
        },
        timeout: const Timeout(Duration(seconds: 2)),
      );

      //testing various scenarios on creating a user
      test(
        'create user should delegate to login function',
        () async {
          //testing that a UserNotFoundException should be thrown when the user has the forbidden email
          final badEmailUser = provider.createUser(
            email: 'foo@bar.com',
            password: 'anypassword',
          );
          expect(badEmailUser,
              throwsA(const TypeMatcher<EmailAlreadyInUseAuthException>()));

          //testing that a wrongpassauthexception should be thrown when the user has the forbidden password
          final badPassword = provider.createUser(
              email: 'someone@gmail.com', password: 'foobar');
          expect(badPassword,
              throwsA(const TypeMatcher<WrongPasswordAuthException>()));

          //testing that a user actually exist after function executes
          final user = await provider.createUser(
            email: 'foo',
            password: 'bar',
          );
          expect(provider.currentUser, user);

          //testing that emailverified should initially be false
          expect(user.isEmailVerified, false);
        },
      );

      //testing the sendemialverification function
      test(
        'logged in user should be able to get verified',
        () {
          provider.sendEmailVerification();
          final user = provider.currentUser;
          expect(user, isNotNull);
          expect(user!.isEmailVerified, true);
        },
      );

      //testing logging out
      test(
        'test that the user should be able to  log out and login againby ensuring the user is not null',
        () async {
          await provider.logOut();
          await provider.logIn(email: 'email', password: 'password');
          final user = provider.currentUser;
          expect(user, isNotNull);
        },
      );
    },
  );
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));

    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw EmailAlreadyInUseAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false,email: 'destinyawisa@gmail.com');

    _user = user;

    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true,email: 'destinyawisa@gmail.com');
    _user = newUser;
  }
}

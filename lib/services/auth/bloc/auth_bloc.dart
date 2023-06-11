import 'package:bloc/bloc.dart';
import 'package:mynote/services/auth/auth_provider.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    //send email verification event
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    //handling register event
    on<AuthEventRegister>((event, emit) async {
      try {
        final email = event.email;
        final password = event.passowrd;

        await provider.createUser(
          email: email,
          password: password,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateUserNeedsVerification());
      } on Exception catch (e) {
        throw AuthStateRegistering(e);
      }
    });

    //initailize event handled
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateUserNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    //login event handling
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
        ),
      );
      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );

        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(const AuthStateUserNeedsVerification());
        } else {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateLoggedIn(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

//log out event hnadling
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    //should register
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(null));
    });
  }
}

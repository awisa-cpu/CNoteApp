import 'package:bloc/bloc.dart';
import 'package:mynote/services/auth/auth_provider.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    //initailize event handled
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateUserNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    //send email verification event
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    //handling register event
    on<AuthEventRegister>((event, emit) async {
      emit(const AuthStateRegistering(
          exception: null,
          isLoading: true,
          isloadingText: 'Registration in progress ...'));

      try {
        //
        final email = event.email;
        final password = event.passowrd;

        await provider.createUser(
          email: email,
          password: password,
        );
        emit(const AuthStateRegistering(
          exception: null,
          isLoading: false,
        ));
        await provider.sendEmailVerification();
        emit(const AuthStateUserNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        throw AuthStateRegistering(exception: e, isLoading: false);
      }
    });

    //login event handling
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
            exception: null,
            isLoading: true,
            loadingText: 'Please wait while i log you in'),
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
          emit(const AuthStateUserNeedsVerification(isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateLoggedIn(user: user, isLoading: false));
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
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    });

    //forgot password event
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
          exception: null, hasSentEmail: false, loading: false));
      final email = event.email;

      //just incase the user clicks the button accidentally
      if (email == null) {
        return;
      }

      emit(const AuthStateForgotPassword(
          exception: null, hasSentEmail: false, loading: true));

      bool? didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(email: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }

      emit(AuthStateForgotPassword(
          exception: exception, hasSentEmail: didSendEmail, loading: false));
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/utilities/extensions/buildcontext/local.dart';
import 'package:mynote/views/register_view.dart';
import 'package:mynote/views/verify_email_view.dart';

import '../helpers/loading/loading_screen.dart';
import '../services/auth/bloc/auth_bloc.dart';
import '../services/auth/bloc/auth_event.dart';
import '../services/auth/bloc/auth_state.dart';
import 'forgot_password_view.dart';
import 'login_view.dart';
import 'notes/notes_view.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocConsumer<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NoteView();

          //
        } else if (state is AuthStateUserNeedsVerification) {
          return const VerifyEmailView();

          //
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();

          //
        } else if (state is AuthStateRegistering) {
          return const RegisterView();

          //
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPassword();

          //
        } else {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(context.loc.processing)
                ],
              ),
            ),
          );
        }
      },
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context, text: state.loadingText ?? context.loc.wait);
        } else {
          LoadingScreen().hide();
        }
      },
    );
  }
}

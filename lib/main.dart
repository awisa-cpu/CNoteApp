import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/helpers/loading/loading_screen.dart';
import 'package:mynote/utilities/constants/routes.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';
import 'package:mynote/services/auth/providers/firebase_auth_provider.dart';
import 'package:mynote/views/forgot_password_view.dart';
import 'package:mynote/views/login_view.dart';
import 'package:mynote/views/notes/create_update_note_view.dart';
import 'package:mynote/views/notes/notes_view.dart';
import 'package:mynote/views/register_view.dart';
import 'package:mynote/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note-Take',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String homePage = '/home-page';

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
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15.0,
                  ),
                  Text('Processing ...')
                ],
              ),
            ),
          );
        }
      },
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment');
        } else {
          LoadingScreen().hide();
        }
      },
    );
  }
}

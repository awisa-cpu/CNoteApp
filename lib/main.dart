import 'package:flutter/material.dart';
import 'package:mynote/constants/routes.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/views/login_view.dart';
import 'package:mynote/views/notes/create_update_note_view.dart';
import 'package:mynote/views/notes/notes_view.dart';
import 'package:mynote/views/register_view.dart';
import 'package:mynote/views/verify_emailview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note-Take',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NoteView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
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
    return FutureBuilder(
      //this is the future which the futurebuilder actually performs in the initializeapp
      future: AuthService.firebase().initialize(),
      //the builder must return a widget which is achieved after a test of the connection state
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            final isEmailVerified = user?.isEmailVerified ?? false;
            if (user != null) {
              if (isEmailVerified) {
                return const NoteView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          default:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
                //this is a great method when waiting...for something
              ),
            );
        }
      },
    );
  }
}

//to use later
Route onGenerate(RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (context) {
      switch (settings.name) {
        case HomePage.homePage:
          return const HomePage();
        case loginRoute:
          return const LoginView();
        case registerRoute:
          return const RegisterView();
        case notesRoute:
          return const NoteView();
        case verifyEmailRoute:
          return const VerifyEmailView();
        default:
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text(
                'Page not found',
                style: TextStyle(fontSize: 23.0),
              ),
            ),
          );
      }
    },
  );
}

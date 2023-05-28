import 'package:flutter/material.dart';

import 'package:mynote/constants/routes.dart';
import 'package:mynote/services/auth/auth_exceptions.dart';
import 'package:mynote/services/auth/auth_service.dart';

import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool shouldShowPassword = false;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(children: [
        TextField(
          controller: _email,
          decoration: const InputDecoration(hintText: 'Enter email here'),
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.emailAddress,
        ),
        TextField(
          controller: _password,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            suffixIcon: IconButton(
              enableFeedback: false,
              onPressed: () {
                shouldShowPassword = !shouldShowPassword;
                setState(() {});
              },
              icon: Icon(
                shouldShowPassword ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          ),
          obscureText: shouldShowPassword ? false : true,
          autocorrect: false,
          enableSuggestions: false,
        ),
        TextButton(
          onPressed: () async {
            try {
              await _login();
              final currentUser = AuthService.firebase().currentUser;
              if (currentUser?.isEmailVerified ?? false) {
                await Future.delayed(Duration.zero).then(
                  (_) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                    );
                  },
                );
              } else {
                await Future.delayed(Duration.zero).then(
                  (_) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute,
                      (route) => false,
                    );
                  },
                );
              }
            } on UserNotFoundAuthException {
              await showErrorDialog(
                context,
                'User Not Found',
              );
            } on WrongPasswordAuthException {
              await showErrorDialog(
                context,
                'Wrong Credentials',
              );
            } on InvalidEmailAuthException {
              await showErrorDialog(
                context,
                'Invalid Email Entered',
              );
            } on GenericAuthException {
              await showErrorDialog(
                context,
                'Error:Authentication Error',
              );
            }
          },
          child: const Text('Login'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              registerRoute,
              (route) => false,
            );
          },
          child: const Text('Not Registered Yet? Register here!'),
        )
      ]),
    );
  }

  Future<void> _login() async {
    await AuthService.firebase().logIn(
      email: _email.text.trim(),
      password: _password.text.trim(),
    );
  }
}

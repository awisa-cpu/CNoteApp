import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mynote/services/auth/auth_exceptions.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        //
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, 'User not found');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Email is Invalid');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication Error');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Column(children: [
          //
          TextField(
            controller: _email,
            decoration: const InputDecoration(hintText: 'Enter email here'),
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.emailAddress,
          ),

          //
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

          //login button
          TextButton(
            onPressed: () async {
              final email = _email.text.trim();
              final password = _password.text.trim();

              context.read<AuthBloc>().add(
                    AuthEventLogIn(
                      email,
                      password,
                    ),
                  );
            },
            child: const Text('Login'),
          ),

          //register button
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventShouldRegister(),
                  );
            },
            child: const Text('Not Registered Yet? Register here!'),
          )
        ]),
      ),
    );
  }
}

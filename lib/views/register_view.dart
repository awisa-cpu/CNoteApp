import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mynote/services/auth/auth_exceptions.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';

import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool shouldShowRegisterPassword = false;

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
      //
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(
              context,
              'Weak password',
            );
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
              context,
              'Email already in user',
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              'Invalid email entered',
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              'Unable to register',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registration'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //email field
              TextField(
                controller: _email,
                enableSuggestions: false,
                autofocus: true,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Enter email here'),
              ),

              //password
              TextField(
                controller: _password,
                obscureText: shouldShowRegisterPassword ? false : true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      enableFeedback: false,
                      onPressed: () {
                        shouldShowRegisterPassword =
                            !shouldShowRegisterPassword;
                        setState(() {});
                      },
                      icon: Icon(
                        shouldShowRegisterPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    hintText: 'Enter your password'),
              ),

              //
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        final email = _email.text;
                        final password = _password.text;

                        context.read<AuthBloc>().add(
                              AuthEventRegister(email, password),
                            );
                      },
                      child: const Text('Register'),
                    ),

                    //login view back
                    TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(const AuthEventLogOut());
                        },
                        child: const Text('Already Registered? Login Here!')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

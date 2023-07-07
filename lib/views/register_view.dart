import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mynote/services/auth/auth_exceptions.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';
import 'package:mynote/utilities/extensions/buildcontext/local.dart';

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
              context.loc.register_error_weak_password,
            );
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
              context,
              context.loc.register_error_email_already_in_use,
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              context.loc.register_error_invalid_email,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.register_error_generic,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.register),
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
                decoration: InputDecoration(
                    hintText: context.loc.email_text_field_placeholder),
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
                      shouldShowRegisterPassword = !shouldShowRegisterPassword;
                      setState(() {});
                    },
                    icon: Icon(
                      shouldShowRegisterPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  hintText: context.loc.password_text_field_placeholder,
                ),
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
                      child: Text(context.loc.register),
                    ),

                    //login view back
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthEventLogOut());
                      },
                      child: Text(
                        context.loc.register_view_already_registered,
                      ),
                    ),
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

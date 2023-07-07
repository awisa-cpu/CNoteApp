import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/services/auth/auth_exceptions.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';
import 'package:mynote/utilities/extensions/buildcontext/local.dart';

import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool shouldShowLoginPassword = false;

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
            await showErrorDialog(
              context,
              context.loc.login_error_cannot_find_user,
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_wrong_credentials,
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_invalid_email,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_auth_error,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.login),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.loc.login_view_prompt),

              const SizedBox(
                height: 20.5,
              ),
              //
              TextField(
                controller: _email,
                decoration: InputDecoration(
                    hintText: context.loc.email_text_field_placeholder),
                autocorrect: false,
                autofocus: true,
                enableSuggestions: false,
                keyboardType: TextInputType.emailAddress,
              ),

              //
              TextField(
                controller: _password,
                decoration: InputDecoration(
                  hintText: context.loc.password_text_field_placeholder,
                  suffixIcon: IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      shouldShowLoginPassword = !shouldShowLoginPassword;
                      setState(() {});
                    },
                    icon: Icon(
                      shouldShowLoginPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: shouldShowLoginPassword ? false : true,
                autocorrect: false,
                enableSuggestions: false,
              ),

              //login button
              Center(
                child: Column(
                  children: [
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
                      child: Text(context.loc.login),
                    ),

                    //

                    //register button
                    TextButton(
                      onPressed: () => context.read<AuthBloc>().add(
                            const AuthEventShouldRegister(),
                          ),
                      child: Text(context.loc.not_registered),
                    ),

                    //
                    const SizedBox(
                      height: 10,
                    ),

                    //forgot password button
                    TextButton(
                      onPressed: () => context.read<AuthBloc>().add(
                            const AuthEventForgotPassword(),
                          ),
                      child: Text(context.loc.forgot_password),
                    )
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

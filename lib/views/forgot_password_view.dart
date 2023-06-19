import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';
import 'package:mynote/utilities/dialogs/error_dialog.dart';
import 'package:mynote/utilities/dialogs/password_reset_email_dialog.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          //
          if (state.hasSentEmail) {
            _emailController.clear();
            await showPasswordResetSentDialog(context);
          }

          if (state.exception != null) {
            await showErrorDialog(context,
                'we could not process your request, make sure you are registered');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                  'if you have forgotten password, please enter email below'),

              //
              const SizedBox(
                height: 15,
              ),

              TextField(
                controller: _emailController,
                autocorrect: false,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(hintText: 'Your email address'),
              ),

              //
              const SizedBox(
                height: 10,
              ),

              TextButton(
                onPressed: () => context
                    .read<AuthBloc>()
                    .add(AuthEventForgotPassword(email:_emailController.text)),
                child: const Text(
                  'Send me password reset link',
                ),
              ),

              //
              const SizedBox(
                height: 10,
              ),

              TextButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthEventLogOut()),
                child: const Text(
                  'Back to login page',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

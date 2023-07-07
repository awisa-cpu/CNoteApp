import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';
import 'package:mynote/utilities/dialogs/error_dialog.dart';
import 'package:mynote/utilities/dialogs/password_reset_email_dialog.dart';
import 'package:mynote/utilities/extensions/buildcontext/local.dart';

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
            Future.delayed(Duration.zero).then((_) async {
              await showErrorDialog(
                  context, context.loc.forgot_password_view_generic_error);
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.forgot_password),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(context.loc.forgot_password_view_prompt),

              //
              const SizedBox(
                height: 15,
              ),

              TextField(
                controller: _emailController,
                autocorrect: false,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    hintText: context.loc.email_text_field_placeholder),
              ),

              //
              const SizedBox(
                height: 10,
              ),

              TextButton(
                onPressed: () => context
                    .read<AuthBloc>()
                    .add(AuthEventForgotPassword(email: _emailController.text)),
                child: Text(
                  context.loc.forgot_password_view_send_me_link,
                ),
              ),

              //
              const SizedBox(
                height: 10,
              ),

              TextButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthEventLogOut()),
                child: Text(
                  context.loc.forgot_password_view_back_to_login,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:mynote/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password reset',
    content: 'We have sent a password reset link, check your email',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

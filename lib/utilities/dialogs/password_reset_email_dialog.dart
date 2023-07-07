import 'package:flutter/widgets.dart';
import 'package:mynote/utilities/dialogs/generic_dialog.dart';
import 'package:mynote/utilities/extensions/buildcontext/local.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: context.loc.password_reset,
    content: context.loc.password_reset_dialog_prompt,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}

import 'package:flutter/material.dart';
import 'package:mynote/utilities/dialogs/generic_dialog.dart';
import 'package:mynote/utilities/extensions/buildcontext/local.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: context.loc.generic_error_prompt,
    content: text,
    optionsBuilder: () {
      return {context.loc.ok: null};
    },
  );
}

import 'package:flutter/material.dart';
import 'package:mynote/utilities/dialogs/generic_dialog.dart';
import 'package:mynote/utilities/extensions/buildcontext/local.dart';

Future<void> showCanNotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.sharing,
    content: context.loc.cannot_share_empty_note_prompt,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}

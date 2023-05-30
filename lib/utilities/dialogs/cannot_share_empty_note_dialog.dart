import 'package:flutter/material.dart';
import 'package:mynote/utilities/dialogs/generic_dialog.dart';

Future<void> showCanNotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty note!',
    optionsBuilder: () => {
      'Ok': null,
    },
  );
}

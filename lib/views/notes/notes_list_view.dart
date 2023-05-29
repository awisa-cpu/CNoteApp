import 'package:flutter/material.dart';
import 'package:mynote/services/cloud/cloud_note.dart';

import '../../utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteCallback;
  final NoteCallback onTapNote;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteCallback,
    required this.onTapNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return ListTile(
          onTap: () => onTapNote.call(note),
          title: Text(
            note.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          trailing: IconButton(
              enableFeedback: false,
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteCallback(note);
                }
              },
              icon: const Icon(Icons.delete)),
        );
      },
    );
  }
}

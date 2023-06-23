import 'package:flutter/material.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/services/cloud/cloud_storage_exceptions.dart';
import 'package:mynote/services/cloud/firebase_cloud_storage.dart';
import 'package:mynote/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:mynote/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/cloud/cloud_note.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _notesService = FirebaseCloudStorage.instance();
  }

  Future<CloudNote> _createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArguments<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote as CloudNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.uid;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      await _notesService.deleteNote(documentid: note.documentid);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        documentid: note.documentid,
        text: text,
      );
    }
  }

//this listener will be hooked to the controller and keeps updating the note as the user types
  void _textControllerListener() async {
    final note = _note;
    final text = _textController.text;
    if (note == null) {
      return;
    }
    await _notesService.updateNote(
      documentid: note.documentid,
      text: text,
    );
  }

//this is where the listener is hooked to the controller
  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Note'),
          actions: [
            IconButton(
              onPressed: () async {
                final text = _textController.text;
                if (_note == null || text.isEmpty) {
                  await showCanNotShareEmptyNoteDialog(context);
                } else {
                  try {
                    Share.share(text);
                  } catch (_) {
                    throw CouldNotShareNoteException();
                  }
                }
              },
              icon: const Icon(Icons.share),
            )
          ],
        ),
        body: FutureBuilder(
          future: _createOrGetExistingNote(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _setupTextControllerListener();
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                      const InputDecoration(hintText: 'Start Typing Here'),
                );
              default:
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Loading ...')
                    ],
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

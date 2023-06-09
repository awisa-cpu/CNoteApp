import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/utilities/constants/routes.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/models/cloud/cloud_note.dart';
import 'package:mynote/services/cloud/firebase_cloud_storage.dart';
import 'package:mynote/utilities/dialogs/show_logout_dialog.dart';
import 'package:mynote/utilities/extensions/buildcontext/local.dart';
import 'package:mynote/utilities/extensions/stream/iterable_length.dart';
import 'package:mynote/views/notes/notes_list_view.dart';
import '../../utilities/enums/menu_action.dart';


class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.uid;
  String get email => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    super.initState();
    _notesService = FirebaseCloudStorage.instance();
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              email,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            StreamBuilder(
              stream: _notesService.allNotes(ownerUserId: userId).getLength,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final noteLength = snapshot.data ?? 0;
                  final text = context.loc.notes_title(noteLength);

                  return Text(text);
                } else {
                  return const Text('');
                }
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            enableFeedback: false,
            splashRadius: 10,
            onPressed: () =>
                Navigator.of(context).pushNamed(createUpdateNoteRoute),
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            enableFeedback: false,
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(context.loc.logout_button),
                ),
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    Future.delayed(Duration.zero).then((value) {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    });
                  }
                  break;
              }
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;

                return NotesListView(
                  notes: allNotes,
                  onDeleteCallback: (note) async {
                    _notesService.deleteNote(documentid: note.documentid);
                  },
                  onTapNote: (note) {
                    Navigator.of(context).pushNamed(
                      createUpdateNoteRoute,
                      arguments: note,
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

            //any other stream connection state
            default:
              return const Center(child: LinearProgressIndicator());
          }
        },
      ),
    );
  }
}

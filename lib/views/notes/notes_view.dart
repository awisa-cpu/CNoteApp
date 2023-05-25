import 'package:flutter/material.dart';
import 'package:mynote/constants/routes.dart';
import 'package:mynote/services/auth/auth_files/auth_service.dart';
import 'package:mynote/services/crud/notes_service.dart';
import 'package:mynote/utilities/dialogs/show_logout_dialog.dart';
import 'package:mynote/views/notes/notes_list_view.dart';
import '../../utilities/enums/menu_action.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
  }

  //
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userEmail,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Your Notes ',
                style: TextStyle(fontSize: 15),
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
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text('Log Out'),
                  ),
                ];
              },
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      await AuthService.firebase().logOut();
                      await Future.delayed(Duration.zero).then(
                        (_) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute,
                            (route) => false,
                          );
                        },
                      );
                    }
                    break;
                }
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              //when future is done
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;

                          return NotesListView(
                            notes: allNotes,
                            onDeleteCallback: (note) async {
                              _notesService.deleteNote(id: note.id);
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
                );
              //Any other connection state
              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        ),
      ),
    );
  }
}

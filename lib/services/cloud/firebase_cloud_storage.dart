import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynote/models/cloud/cloud_note.dart';
import 'package:mynote/services/cloud/cloud_storage_constants.dart';
import 'package:mynote/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  //creating a singleton
  FirebaseCloudStorage._();
  static final FirebaseCloudStorage _sharedInstance = FirebaseCloudStorage._();
  factory FirebaseCloudStorage.instance() => _sharedInstance;

  //fetch all notes
  final notes = FirebaseFirestore.instance.collection('notes');

  //create new note
  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fectchedNotes = await document.get();
    return CloudNote(
      documentid: fectchedNotes.id,
      owneruserId: ownerUserId,
      text: '',
    );
  }

  //all notes for a specific user as it evolves
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    //by using the snapshots we are able to listen to changes on this value as it evolves and changes in real-time
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map(
          (query) => query.docs.map((doc) => CloudNote.fromSnapshot(doc)),
        );
    return allNotes;
  }

//update note
  Future<void> updateNote({
    required String documentid,
    required String text,
  }) async {
    try {
      await notes.doc(documentid).update({
        textFieldName: text,
      });
    } catch (_) {
      throw CouldNotUpdateNoteException();
    }
  }

//delete a note
  Future<void> deleteNote({required String documentid}) async {
    try {
      await notes.doc(documentid).delete();
    } catch (_) {
      throw CouldNotDeleteNoteException();
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynote/services/cloud/cloud_note.dart';
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
  void createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  //get notes by user id
  Future<List<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          ) //since a query is returned it must be executed using the get() to return a future of QuerySnapshot
          .get()
          .then((value) => value.docs.map((doc) {
                return CloudNote(
                  documentid: doc.id,
                  owneruserId: doc.data()[ownerUserIdFieldName] as String,
                  text: doc.data()[textFieldName] as String,
                );
              }).toList());
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  //all notes for a specific user as it evolves
  Stream<List<CloudNote>> allNotes({required String ownerUserId}) {
    //by using the snapshots we are able to listen to changes on this value as it evolves
    return notes.snapshots().map(
          (query) => query.docs
              .map((doc) => CloudNote.fromSnapshot(doc))
              .where((note) => note.owneruserId == ownerUserId)
              .toList(),
        );
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

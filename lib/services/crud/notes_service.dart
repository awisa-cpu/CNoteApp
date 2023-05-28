import 'dart:async';
import 'package:mynote/extensions/list/filter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

import 'crud_constants.dart';
import 'crud_exceptions.dart';
import 'models/database_note.dart';
import 'models/database_user.dart';

//the four CRUD operations are to be implemented

class NotesService {
  Database? _db;

  DatabaseUser? _user;

//it is good for an application not to talk directly with the database instead there should be a
//layered approach where information are cached from the database and displayed to the user in a collection like list
  List<DatabaseNote> _notes = [];

  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }

  static final NotesService _instance = NotesService._sharedInstance();
  factory NotesService() => _instance;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes;
    _notesStreamController.add(_notes);
  }

//function to get database or throw an exception
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  //function to ensure db is open
  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  //open database
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //create user table
      await db.execute(createUserTable);

      //create note table
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }

    (e) {};
  }

  //clode database
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  //CREATE USER
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      columns: [idColumn, emailColumn],
      where: 'email = ?',
      whereArgs: [
        email.toLowerCase(),
      ],
    );

    if (result.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  //DELETE USER
  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email =?',
      whereArgs: [
        email.toLowerCase(),
      ],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  //FETCH A USER
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final usersReturned = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [
        email.toLowerCase(),
      ],
    );

    if (usersReturned.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(usersReturned.first);
    }
  }

  //FETCH OR CREATE A USER
  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUserException {
      final newUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = newUser;
      }
      return newUser;
    } catch (error) {
      rethrow;
    }
  }

  //CREATE NOTE
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

//make sure owner exist in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }

    String text = '';
    final noteId = await db.insert(
      noteTable,
      {
        userIdColumn: dbUser.id,
        textColumn: text,
        isSyncedWithCloudColumn: 1,
      },
    );

    final newNote = DatabaseNote(
      id: noteId,
      userId: dbUser.id,
      text: text,
      isSyncedWithCloud: true,
    );
    _notes.add(newNote);
    _notesStreamController.add(_notes);
    return newNote;
  }

//FECTH NOTE
  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final returnedNote = await db.query(
      noteTable,
      limit: 1,
      where: 'id =?',
      whereArgs: [id],
    );

    if (returnedNote.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final note = DatabaseNote.fromRow(returnedNote.first);
      _notes.add(note);
      _notesStreamController.add(_notes);

      return note;
    }
  }

  //DELET NOTE
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      noteTable,
      where: 'id =?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      CouldNotDeleteNoteException();
    } else {
      final notesCount = _notes.length;
      _notes.removeWhere((note) => note.id == id);
      notesCount != _notes.length ? _notesStreamController.add(_notes) : null;
    }
  }

//DELETE ALL NOTES
  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final allDeletedNoteCount = await db.delete(noteTable);
    _notes.clear();
    _notesStreamController.add(_notes);

    return allDeletedNoteCount;
  }

//FECTH ALL NOTES
  Future<List<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final allReturnedNotes = await db.query(noteTable);
    final notes = allReturnedNotes
        .map(
          (note) => DatabaseNote.fromRow(note),
        )
        .toList();
    if (allReturnedNotes.isEmpty) throw NotesCouldNotBeFoundException();
    _notes.clear();
    _notes.addAll(notes);
    _notesStreamController.add(_notes);
    return notes;
  }

//UPDATE NOTE
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String updateText,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updateCount = await db.update(
        noteTable,
        {
          textColumn: updateText,
          isSyncedWithCloudColumn: 0,
        },
        where: 'id =?',
        whereArgs: [note.id]);

    if (updateCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      final updatedNote = await getNote(id: note.id);
      //this is to ensure that the previous object has been removed
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);

      return updatedNote;
    }
  }
}

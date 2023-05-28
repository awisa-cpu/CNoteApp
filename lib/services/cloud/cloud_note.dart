import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mynote/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentid;
  final String owneruserId;
  final String text;

  const CloudNote({
    required this.documentid,
    required this.owneruserId,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, Object?>> snapshot)
      : documentid = snapshot.id,
        owneruserId = snapshot.data()[ownerUserIdFieldName] as String,
        text = snapshot.data()[textFieldName] as String;
}


import 'package:cloud_firestore/cloud_firestore.dart';

class CrudService {
  // get collection of notes
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // CREATE: add a new note
  Future<void> addNote(String note, String userId) {
    return notes.add({
      'note': note,
      'uid': userId,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: getting notes from database
  Stream<QuerySnapshot> getNotesStream(String userId) {
    final notesStream = notes
        .where('uid', isEqualTo: userId)
        .orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  // UPDATE: update notes given a doc id
  Future<void> updateNote(String docID, String newNote, String userId){
    return notes.doc(docID).update({
      'note': newNote,
      'uid': userId,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE: delete notes given a doc id
  Future<void> deleteNote(String docID){
    return notes.doc(docID).delete();
  }

  //
}

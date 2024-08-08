import 'package:cloud_firestore/cloud_firestore.dart';

class AreaService {
  // get collection of area
  final CollectionReference areas =
  FirebaseFirestore.instance.collection('area');

  // CREATE: add a new area
  Future<void> addArea(String area, String userId) {
    return areas.add({
      'area_name': area,
      'uid': userId,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: getting area from database
  Stream<QuerySnapshot> getAreasStream(Object userId) {
    // print(userId);
    final areaStream = areas
        // .where('uid', isEqualTo: userId)
        .orderBy('area_name', descending: false)
        .snapshots();
    return areaStream;
  }


  // UPDATE: update area given a doc id
  Future<void> updateArea(String docID, String newArea, String userId){
    return areas.doc(docID).update({
      'area_name': newArea,
      'uid': userId,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE: delete area given a doc id
  Future<void> deleteArea(String docID, String userId){
    return areas.doc(docID).delete();
  }

//
}

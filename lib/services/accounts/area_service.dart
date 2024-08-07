import 'package:cloud_firestore/cloud_firestore.dart';

class AreaService {
  // get collection of area
  final CollectionReference areas =
  FirebaseFirestore.instance.collection('area');

  // CREATE: add a new area
  Future<void> addArea(String area) {
    return areas.add({
      'area_name': area,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: getting area from database
  Stream<QuerySnapshot> getAreasStream() {
    final areaStream =
    areas.orderBy('area_name', descending: true).snapshots();
    return areaStream;
  }

  // UPDATE: update area given a doc id
  Future<void> updateArea(String docID, String newArea){

    print(docID);
    print(newArea);

    return areas.doc(docID).update({
      'area_name': newArea,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE: delete area given a doc id
  Future<void> deleteArea(String docID){
    return areas.doc(docID).delete();
  }

//
}

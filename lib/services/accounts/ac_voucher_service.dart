import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class AcVoucherService {
  // get collection of vouchers
  final CollectionReference _vouchers =
      FirebaseFirestore.instance.collection('vouchers');

  // CREATE: add a new account
  Future<void> addVoucher(
      String type,
      DateTime date,
      String remarks,
      String drAcId,
      String crAcId,
      double debit,
      double debitsar,
      double credit,
      double creditsar,
      String userId) {
    return _vouchers.add({
      'type': type,
      'date': date,
      'remarks': remarks,
      'drAcId': drAcId,
      'crAcId': crAcId,
      'debit': debit,
      'debitsar': debitsar,
      'credit': credit,
      'creditsar': creditsar,
      'uid': userId,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: getting vouchers from database
  Stream<QuerySnapshot> getVouchersStream(String userId) {
    final accountsStream = _vouchers
        .where('uid', isEqualTo: userId)
        .orderBy("date", descending: false)
        .snapshots();
    return accountsStream;
  }

// READ: getting vouchers from database type base
  Stream<QuerySnapshot> getVouchersTypeStream(String userId, String type) {
    final accountsStream = _vouchers
        .where('uid', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .orderBy("date", descending: true)
        .snapshots();
    return accountsStream;
  }

  // UPDATE: update accounts given a doc id
  Future<void> updateVoucher(
      String? docID,
      String newType,
      DateTime newDate,
      String newRemarks,
      String newDrAcId,
      String newCrAcId,
      double newDebit,
      double newDebitSar,
      double newCredit,
      double newCreditSar,
      String userId) {
    // print(docID);

    return _vouchers.doc(docID).update({
      'type': newType,
      'date': newDate,
      'remarks': newRemarks,
      'drAcId': newDrAcId,
      'crAcId': newCrAcId,
      'debit': newDebit,
      'debitsar': newDebitSar,
      'credit': newCredit,
      'creditsar': newCreditSar,
      'uid': userId,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE: delete voucher given a doc id
  Future<void> deleteVoucher(String docID) {
    return _vouchers.doc(docID).delete();
  }

  // READ: getting Cash Book Report Query
  // Stream<QuerySnapshot> getCashBookStream(String userId, List<String> types) {
  //   final query = _vouchers
  //       .where('uid', isEqualTo: userId)
  //       .where('type', whereIn: types)
  //       .orderBy('date', descending: true);
  //
  //   return query.snapshots();
  // }
  Stream<QuerySnapshot> getCashBookStream(
      String userId,
      List<String> types,
      DateTime? startDate, // Optional: can be null if not filtering by start date
      DateTime? endDate    // Optional: can be null if not filtering by end date
      ) {
    // Start with the base query
    var query = _vouchers
        .where('uid', isEqualTo: userId)
        .where('type', whereIn: types)
        .orderBy('date', descending: true);

    // print(startDate);
    // print(endDate);

    // Apply date range filter if startDate and endDate are provided
    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: endDate);
    }

    return query.snapshots();
  }



  // READ: getting Account Ledger Report Query
  Stream<List<QueryDocumentSnapshot>> getAcLedgerStream(String userId, String accId) {

    final query1 = _vouchers
        .where('uid', isEqualTo: userId)
        .where('drAcId', isEqualTo: accId)
        .orderBy('date', descending: true);

    final query2 = _vouchers
        .where('uid', isEqualTo: userId)
        .where('crAcId', isEqualTo: accId)
        .orderBy('date', descending: true);

    final stream1 = query1.snapshots().map((snapshot) => snapshot.docs);
    final stream2 = query2.snapshots().map((snapshot) => snapshot.docs);

    return Rx.combineLatest2(stream1, stream2, (docs1, docs2) {
      final combinedDocs = <QueryDocumentSnapshot>[]
        ..addAll(docs1)
        ..addAll(docs2);

      combinedDocs.sort((a, b) => b['date'].compareTo(a['date']));

      return combinedDocs;
    });
  }

}

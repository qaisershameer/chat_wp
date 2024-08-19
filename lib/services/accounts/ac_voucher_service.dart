import 'package:cloud_firestore/cloud_firestore.dart';

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
        .orderBy("timestamp", descending: false)
        .snapshots();
    return accountsStream;
  }

// READ: getting vouchers from database type base
  Stream<QuerySnapshot> getVouchersTypeStream(String userId, String type) {
    final accountsStream = _vouchers
        .where('uid', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .orderBy("timestamp", descending: false)
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
}

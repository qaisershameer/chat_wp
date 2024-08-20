import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierService {
  // get collection of accounts
  final CollectionReference _accounts =
      FirebaseFirestore.instance.collection('accounts');

  // CREATE: add a new account
  Future<void> addAccount(
      String accountName,
      String phone,
      String email,
      String type,
      String currency,
      String areaId,
      String userId) {

    return _accounts.add({

      'accountName': accountName,
      'email': email,
      'phone': phone,
      'type': type,
      'currency': currency,
      'areaId': areaId,
      'uid': userId,
      'timestamp': Timestamp.now(),

    });
  }

  // READ: getting accounts from database
  Stream<QuerySnapshot> getAccountsStream(String userId, String type) {
    final accountsStream = _accounts
        .where('uid', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .orderBy("accountName", descending: false)
        .snapshots();
    return accountsStream;
  }

  // UPDATE: update accounts given a doc id
  Future<void> updateAccount(
      String docID,
      String newAccount,
      String newEmail,
      String newType,
      String newCurrency,
      String newAreaId,
      String userId
      ) {

    return _accounts.doc(docID).update({

        'accountName': newAccount,
        'email': newEmail,
        'type': newType,
        'currency': newCurrency,
        'areaId': newAreaId,
        'uid': userId,
        'timestamp': Timestamp.now(),

      });
  }

  // DELETE: delete account given a doc id
  Future<void> deleteAccount(String docID) {
    return _accounts.doc(docID).delete();
  }
}

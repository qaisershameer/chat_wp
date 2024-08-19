import 'package:cloud_firestore/cloud_firestore.dart';

class AccountService {
  // get collection of accounts
  final CollectionReference _accounts =
      FirebaseFirestore.instance.collection('accounts');

  // CREATE: add a new account
  Future<void> addAccount(String accountName, String phone, String email,
      String type, String currency, String areaId, String userId) {
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
  Stream<QuerySnapshot> getAccountsStream(String userId) {
    final accountsStream = _accounts
        .where('uid', isEqualTo: userId)
        .orderBy("accountName", descending: false)
        .snapshots();
    return accountsStream;
  }

// READ: getting accounts from database
  Stream<QuerySnapshot> getAccountsTypeStream(String userId, String type) {
    final accountsStream = _accounts
        .where('uid', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .orderBy("accountName", descending: false)
        .snapshots();
    return accountsStream;
  }

  // UPDATE: update accounts given a doc id
  Future<void> updateAccount(
      String? docID,
      String newAccount,
      String newPhone,
      String newEmail,
      String newType,
      String newCurrency,
      String newAreaId,
      String userId) {
    return _accounts.doc(docID).update({
      'accountName': newAccount,
      'phone': newPhone,
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

  // Future<String?> getAccountName(String accId) async {
  //   try {
  //     // Fetch the document from Firestore
  //     DocumentSnapshot documentSnapshot = await _accounts.doc(accId).get();
  //
  //     if (documentSnapshot.exists) {
  //       // Access the document data
  //       Map<String, dynamic>? data =
  //           documentSnapshot.data() as Map<String, dynamic>?;
  //
  //       if (data != null && data.containsKey('accountName')) {
  //         // Access the specific field from the document
  //         String accountName = data['accountName'] as String;
  //         return accountName;
  //       } else {
  //         // Handle the case where 'accountName' is not found
  //         // print('Field "accountName" not found in the document');
  //         return null;
  //       }
  //     } else {
  //       // Handle the case where the document does not exist
  //       // print('Document with ID $accId does not exist');
  //       return null;
  //     }
  //   } catch (e) {
  //     // Handle any errors that occur during fetching
  //     // print('Error fetching document: $e');
  //     return null;
  //   }
  // }

  Future<String?> getAccountName(String accId) async {
    try {
      // DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('accounts').doc(accId).get();
      DocumentSnapshot documentSnapshot = await _accounts.doc(accId).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        return data?['accountName'] as String?;
      } else {
        // print('Document does not exist');
        return null;
      }
    } catch (e) {
      // print('Error fetching document: $e');
      return null;
    }
  }
}

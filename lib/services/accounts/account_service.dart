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

  // Method to fetch account names for a list of account IDs FOR CP-CR
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

  // Method to fetch account names for a list of account IDs FOR JV
  Future<Map<String, String?>> getAccountNames(List<String> acIds) async {
    try {
      // Fetch documents for the given account IDs
      var snapshots = await Future.wait(acIds.map((id) =>
          _accounts.doc(id).get()
      ));

      // Create a map to hold account names
      Map<String, String?> accountNames = {};

      // Populate the map with account IDs and names
      for (var snapshot in snapshots) {
        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          String? accountName = data['accountName'] as String?;
          accountNames[snapshot.id] = accountName;
        } else {
          accountNames[snapshot.id] = 'NA'; // Handle cases where document does not exist
        }
      }

      return accountNames;
    } catch (error) {
      // print('Failed to load account names: $error'); // Debug print
      throw Exception('Failed to load account names: $error');
    }
  }


}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

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
        .orderBy("date", descending: true)
        .orderBy('timestamp', descending: true)
        .snapshots();
    return accountsStream;
  }

// READ: getting vouchers from database type base
  Stream<QuerySnapshot> getVouchersTypeStream(String userId, String type) {
    final accountsStream = _vouchers
        .where('uid', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .orderBy("date", descending: true)
        .orderBy('timestamp', descending: true)
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

  Stream<QuerySnapshot> getCashBookStream(String userId, List<String> types,
      DateTime? startDate, DateTime? endDate) {
    // Start with the base query
    var query = _vouchers
        .where('uid', isEqualTo: userId)
        .where('type', whereIn: types)
        .orderBy('date', descending: true)
        .orderBy('timestamp', descending: true);

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
  Stream<List<QueryDocumentSnapshot>> getAcLedgerStream(
      String userId, String accId, DateTime? startDate, DateTime? endDate) {

    var query1 = _vouchers
        .where('uid', isEqualTo: userId)
        .where('drAcId', isEqualTo: accId);

        // Add date filters conditionally
        if (startDate != null) {
          query1 = query1.where('date', isGreaterThanOrEqualTo: startDate);
        }
        if (endDate != null) {
          query1 = query1.where('date', isLessThanOrEqualTo: endDate);
        }

        // Add ordering
        query1 = query1
            .orderBy('date', descending: true)
            .orderBy('timestamp', descending: true);

    // print(query1);

    var query2 = _vouchers
        .where('uid', isEqualTo: userId)
        .where('crAcId', isEqualTo: accId);

        // Add date filters conditionally
        if (startDate != null) {
          query2 = query2.where('date', isGreaterThanOrEqualTo: startDate);
        }
        if (endDate != null) {
          query2 = query2.where('date', isLessThanOrEqualTo: endDate);
        }

        // Add ordering
        query2 = query2
            .orderBy('date', descending: true)
            .orderBy('timestamp', descending: true);

    final stream1 = query1.snapshots().map((snapshot) => snapshot.docs);
    final stream2 = query2.snapshots().map((snapshot) => snapshot.docs);

    return Rx.combineLatest2(stream1, stream2, (docs1, docs2) {
      final combinedDocs = <QueryDocumentSnapshot>[...docs1, ...docs2];

      // Sort by date OR timestamp only 1 line Uncommit for Sorting...
      // combinedDocs.sort((a, b) => b['date'].compareTo(a['date']));
      // combinedDocs.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      // Sort by date and then timestamp
      combinedDocs.sort((a, b) {
        int dateComparison = b['date'].compareTo(a['date']);
        if (dateComparison != 0) {
          return dateComparison;
        }
        return b['timestamp'].compareTo(a['timestamp']);
      });

      return combinedDocs;
    });
  }

  // READ: getting Trial Balance Report Query
  // Stream<List<QueryDocumentSnapshot>> getTrialBalanceStream(String userId, String type, String accId) {
  //   final query1 = _vouchers
  //       .where('uid', isEqualTo: userId)
  //       .snapshots();
  //
  //   final stream1 = query1.map((querySnapshot) {
  //     final result = <String, Map<String, double>>{};
  //
  //     for (var doc in querySnapshot.docs) {
  //       final data = doc.data() as Map<String, dynamic>;
  //
  //       final drAcid = data['drAcId'] as String;
  //       final debitSar = (data['debitsar'] as num?)?.toDouble() ?? 0.0;
  //       final creditSar = (data['creditsar'] as num?)?.toDouble() ?? 0.0;
  //       final debit = (data['debit'] as num?)?.toDouble() ?? 0.0;
  //       final credit = (data['credit'] as num?)?.toDouble() ?? 0.0;
  //
  //       final key = '${userId}_$drAcid';
  //
  //       if (!result.containsKey(key)) {
  //         result[key] = {
  //           'SUM_debitSar': 0.0,
  //           'SUM_creditSar': 0.0,
  //           'SUM_debit': 0.0,
  //           'SUM_credit': 0.0,
  //         };
  //       }
  //
  //       result[key]!['SUM_debitSar'] = result[key]!['SUM_debitSar']! + debitSar;
  //       result[key]!['SUM_creditSar'] = result[key]!['SUM_creditSar']! + creditSar;
  //       result[key]!['SUM_debit'] = result[key]!['SUM_debit']! + debit;
  //       result[key]!['SUM_credit'] = result[key]!['SUM_credit']! + credit;
  //     }
  //     return result;
  //   });
  // }

  Stream<List<QueryDocumentSnapshot>> getTrialBalanceStream(
      String userId, String accId) {
    final query1 = _vouchers
        .where('uid', isEqualTo: userId)
        .where('drAcId', isEqualTo: accId)
        .orderBy('date', descending: true)
        .orderBy('timestamp', descending: true);

    final query2 = _vouchers
        .where('uid', isEqualTo: userId)
        .where('crAcId', isEqualTo: accId)
        .orderBy('date', descending: true)
        .orderBy('timestamp', descending: true);

    final stream1 = query1.snapshots().map((snapshot) => snapshot.docs);
    final stream2 = query2.snapshots().map((snapshot) => snapshot.docs);

    return Rx.combineLatest2(stream1, stream2, (docs1, docs2) {
      final combinedDocs = <QueryDocumentSnapshot>[...docs1, ...docs2];

      combinedDocs.sort((a, b) => b['date'].compareTo(a['date']));

      return combinedDocs;
    });
  }

  // READ: getting Account Ledger Report Query
  Stream<List<QueryDocumentSnapshot>> getAcTrialBalanceStream(
      String userId, String accId, DateTime? startDate, DateTime? endDate) {

    // print('A/C ID: $accId');

    var query1 = _vouchers
        .where('uid', isEqualTo: userId)
        .where('drAcId', isEqualTo: accId);

    // Add date filters conditionally
    if (startDate != null) {
      query1 = query1.where('date', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query1 = query1.where('date', isLessThanOrEqualTo: endDate);
    }

    // Add ordering
    query1 = query1
        .orderBy('drAcId', descending: true);
        // .orderBy('timestamp', descending: true);

    // print(query1);

    var query2 = _vouchers
        .where('uid', isEqualTo: userId)
        .where('crAcId', isEqualTo: accId);

    // Add date filters conditionally
    if (startDate != null) {
      query2 = query2.where('date', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query2 = query2.where('date', isLessThanOrEqualTo: endDate);
    }

    // Add ordering
    query2 = query2
        .orderBy('crAcId', descending: true);

    final stream1 = query1.snapshots().map((snapshot) => snapshot.docs);
    final stream2 = query2.snapshots().map((snapshot) => snapshot.docs);

    return Rx.combineLatest2(stream1, stream2, (docs1, docs2) {
      final combinedDocs = <QueryDocumentSnapshot>[...docs1, ...docs2];

      combinedDocs.sort((a, b) => b['drAcId'].compareTo(a['crAcId']));

      return combinedDocs;
    });
  }

}

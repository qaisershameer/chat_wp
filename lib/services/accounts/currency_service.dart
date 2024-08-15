import 'package:cloud_firestore/cloud_firestore.dart';

 class CurrencyService{
   // get collection of currency
   final CollectionReference _currency =
   FirebaseFirestore.instance.collection('currency');

   // CREATE: add a new currency
   Future<void> addCurrency(String currencyName,String userId) {
     return _currency.add({
       'currencyName': currencyName,
       'uid': userId,
       'timestamp': Timestamp.now(),
     });
   }

   // READ: getting currency from database
   Stream<QuerySnapshot> getCurrencyStream(String userId) {
     final currencyStream = _currency
         .where('uid', isEqualTo: userId)
         .orderBy("currencyName", descending: false)
         .snapshots();
     return currencyStream;
   }

   // UPDATE: update currency given a doc id
   Future<void> updateCurrency(String docID, String newCurrency, String userId) {
     return _currency.doc(docID).update({
       'currencyName': newCurrency,
       'uid': userId,
       'timestamp': Timestamp.now(),

     });
   }

   // DELETE: delete currency given a doc id
   Future<void> deleteCurrency(String docID) {
     return _currency.doc(docID).delete();
   }
 }

import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerService {
  // get collection of customer
  final CollectionReference customers =
      FirebaseFirestore.instance.collection('customer');

  // CREATE: add a new customer
  Future<void> addCustomer(String customer, String userId) {
    return customers.add({
      'customer_name': customer,
      'uid': userId,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: getting customers from database
  Stream<QuerySnapshot> getCustomersStream(Object userId) {
    // print(userId);
    final customerStream = customers
        .where('uid', isEqualTo: userId)
        .orderBy("customer_name", descending: false)
        .snapshots();
    return customerStream;
  }

  // UPDATE: update customer given a doc id
  Future<void> updateCustomer(String docID, String newCustomer, String userId) {
    return customers.doc(docID).update({
      'customer_name': newCustomer,
      'uid': userId,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE: delete customer given a doc id
  Future<void> deleteCustomer(String docID) {
    return customers.doc(docID).delete();
  }
}

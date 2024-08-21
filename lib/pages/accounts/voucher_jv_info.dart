import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_wp/pages/accounts/voucher_jv_add.add.dart';
import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/services/accounts/ac_voucher_service.dart';

class VoucherJvInfo extends StatefulWidget {
  const VoucherJvInfo({super.key});

  @override
  State<VoucherJvInfo> createState() => VoucherJvInfoState();
}

class VoucherJvInfoState extends State<VoucherJvInfo> {
  final AccountService _accounts = AccountService();
  final AcVoucherService _vouchers = AcVoucherService();

  Future<Map<String, String?>>? _accountNamesFuture;

  @override
  void initState() {
    super.initState();
    _accountNamesFuture = _fetchAccountNames();
  }

  Future<Map<String, String?>> _fetchAccountNames() async {
    try {
      var accountSnapshots = await _vouchers.getVouchersTypeStream(kUserId, kJV).first;

      List<String> accountIDs = accountSnapshots.docs
          .map((doc) => doc['drAcId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();

      return await _accounts.getAccountNames(accountIDs);
    } catch (e) {
      // print('Error fetching account names: $e');
      return {};
    }
  }

  void _deleteVoucherBox(BuildContext context, String docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete JV'),
        content: const Text('Are you sure you want to delete this JV Voucher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _vouchers.deleteVoucher(docID);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('JV Voucher deleted!'),
                ),
              );
            },
            child: const Text('Delete JV'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime vDate = DateTime.now();
    double pkrAmount = 0;
    double sarAmount = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Voucher'),
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, bottom: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VoucherJvAdd(
                        docId: '',
                        type: '',
                        vDate: vDate,
                        remarks: 'Amount Transferred.',
                        drAcId: '',
                        crAcId: '',
                        debit: pkrAmount,
                        debitSar: sarAmount,
                        credit: pkrAmount,
                        creditSar: sarAmount,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _vouchers.getVouchersTypeStream(kUserId, kJV),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> accountList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: accountList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = accountList[index];
                String docID = document.id;

                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                String crAcId = data['crAcId'] ?? '';
                String drAcId = data['drAcId'] ?? '';
                DateTime dateText = (data['date'] as Timestamp).toDate(); // Convert Timestamp to DateTime
                String remarksText = data['remarks'] ?? '';
                double debitText = (data['debit'] ?? 0.0) as double; // Ensure this is double
                double debitSarText = (data['debitsar'] ?? 0.0) as double; // Ensure this is double
                double creditText = (data['credit'] ?? 0.0) as double; // Ensure this is double
                double creditSarText = (data['creditsar'] ?? 0.0) as double; // Ensure this is double

                // Format DateTime for display
                String formattedDate = DateFormat('dd MMM yyyy').format(dateText);

                // Use FutureBuilder to fetch the account names asynchronously
                return FutureBuilder<Map<String, String?>>(
                  future: _accounts.getAccountNames([drAcId, crAcId]), // Call updated method returning Map<String, String?>
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (futureSnapshot.hasError) {
                      return Center(child: Text('Error: ${futureSnapshot.error}'));
                    } else if (futureSnapshot.hasData) {
                      Map<String, String?> accountNames = futureSnapshot.data!;
                      String? drAccountName = accountNames[drAcId];
                      String? crAccountName = accountNames[crAcId];

                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                        padding: const EdgeInsets.all(3),
                        child: ListTile(
                          title: Text('Dr: ${drAccountName ?? 'NA'}\nCr: ${crAccountName ?? 'NA'}'),
                          subtitle: Text('PKR ==> Dr: $debitText * Cr: $creditText\nSAR ==> Dr: $debitSarText * Cr: $creditSarText\n$remarksText\n$formattedDate'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VoucherJvAdd(
                                        docId: docID,
                                        type: kJV,
                                        vDate: dateText,
                                        remarks: remarksText,
                                        drAcId: drAcId,
                                        crAcId: crAcId,
                                        debit: debitText,
                                        debitSar: debitSarText,
                                        credit: creditText,
                                        creditSar: creditSarText,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.settings),
                              ),
                              IconButton(
                                onPressed: () => _deleteVoucherBox(context, docID),
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: Text('No account names available'));
                    }
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: Text('No account data to display!'));
          }
        },
      ),
    );
  }

}

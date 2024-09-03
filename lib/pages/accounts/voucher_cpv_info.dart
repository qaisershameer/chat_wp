import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_wp/pages/accounts/voucher_cpv_add.dart';
import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/services/accounts/ac_voucher_service.dart';

class VoucherCpvInfo extends StatefulWidget {
  const VoucherCpvInfo({super.key});

  @override
  State<VoucherCpvInfo> createState() => VoucherCpvInfoState();
}

class VoucherCpvInfoState extends State<VoucherCpvInfo> {
  final AccountService _accounts = AccountService();
  final AcVoucherService _voucher = AcVoucherService();

  void _deleteVoucherBox(BuildContext context, String docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete CPV'),
        content: const Text('Are you sure you want to delete this CP Voucher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _voucher.deleteVoucher(docID);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CP Voucher deleted!'),
                ),
              );
            },
            child: const Text('Delete CP'),
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
        title: const Text('Cash Payment'),
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
                      builder: (context) => VoucherCpvAdd(
                        docId: '',
                        type: '',
                        vDate: vDate,
                        remarks: 'Cash Paid.',
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
        stream: _voucher.getVouchersTypeStream(kUserId, kCPV),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> customerList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: customerList.length,
              // scrollDirection: ScrollDirection.,
              itemBuilder: (context, index) {
                DocumentSnapshot document = customerList[index];
                String docID = document.id;

                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                String acId = data['drAcId'] ?? '';
                DateTime dateText = (data['date'] as Timestamp).toDate(); // Convert Timestamp to DateTime
                String remarksText = data['remarks'] ?? '';
                double debitText = (data['debit'] ?? 0.0) as double; // Ensure this is double
                double debitSarText = (data['debitsar'] ?? 0.0) as double; // Ensure this is double
                double creditText = (data['credit'] ?? 0.0) as double; // Ensure this is double
                double creditSarText = (data['creditsar'] ?? 0.0) as double; // Ensure this is double

                // Format DateTime for display
                String formattedDate = DateFormat('dd MMM yyyy').format(dateText);

                // Use FutureBuilder to fetch the account name asynchronously
                return FutureBuilder<String?>(
                  future: _accounts.getAccountName(acId),
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (futureSnapshot.hasError) {
                      return Center(child: Text('Error: ${futureSnapshot.error}'));
                    } else if (futureSnapshot.hasData) {
                      String? acName = futureSnapshot.data;

                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                        padding: const EdgeInsets.all(3),
                        child: ListTile(
                          title: Text('$acName'),
                          subtitle: Text('PK: $debitText * SR: $debitSarText\n$remarksText\n$formattedDate'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VoucherCpvAdd(
                                        docId: docID,
                                        type: kCPV,
                                        vDate: dateText,
                                        remarks: remarksText,
                                        drAcId: acId,
                                        crAcId: '',
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
                      return const Center(child: Text('Account name not available'));
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

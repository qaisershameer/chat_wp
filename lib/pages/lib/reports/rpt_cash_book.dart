import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/services/accounts/ac_voucher_service.dart';

class RptCashBook extends StatefulWidget {
  const RptCashBook({super.key});

  @override
  State<RptCashBook> createState() => RptCashBookState();
}

class RptCashBookState extends State<RptCashBook> {
  final AccountService _accounts = AccountService();
  final AcVoucherService _vouchers = AcVoucherService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Book Report'),
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
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _vouchers.getCashBookStream(kUserId, [kCRV, kCPV]), // Pass the list of types
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> customerList = snapshot.data!.docs;

            return FutureBuilder<Map<String, String?>>(
              future: _getAccountNames(customerList),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (futureSnapshot.hasError) {
                  return Center(child: Text('Error: ${futureSnapshot.error}'));
                } else if (futureSnapshot.hasData) {
                  Map<String, String?> accountNames = futureSnapshot.data!;

                  // Calculate totals
                  double totalDebitPK = 0;
                  double totalCreditPK = 0;
                  double totalDebitSR = 0;
                  double totalCreditSR = 0;

                  for (var document in customerList) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    totalDebitPK += (data['debit'] ?? 0.0) as double;
                    totalCreditPK += (data['credit'] ?? 0.0) as double;
                    totalDebitSR += (data['debitsar'] ?? 0.0) as double;
                    totalCreditSR += (data['creditsar'] ?? 0.0) as double;
                  }

                  // Calculate B/F Balance
                  double bfBalancePK = totalDebitPK - totalCreditPK;
                  double bfBalanceSR = totalDebitSR - totalCreditSR;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: constraints.maxWidth / 15, // Adjust column spacing
                          columns: [
                            const DataColumn(label: Text('Date')),
                            const DataColumn(label: Text('Account')), // Combined DR & CR Account
                            const DataColumn(label: Text('PK-Dr')),
                            const DataColumn(label: Text('PK-Cr')),
                            const DataColumn(label: Text('SR-Dr')),
                            const DataColumn(label: Text('SR-Cr')),
                            const DataColumn(label: Text('Remarks')),
                          ],
                          rows: [
                            ...customerList.map((document) {
                              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                              String drAcId = data['drAcId'] ?? '';
                              String crAcId = data['crAcId'] ?? '';
                              DateTime dateText = (data['date'] as Timestamp).toDate();
                              String formattedDate = DateFormat('dd MMM yy').format(dateText);
                              String remarksText = data['remarks'] ?? '';
                              double debitText = (data['debit'] ?? 0.0) as double;
                              double creditText = (data['credit'] ?? 0.0) as double;
                              double debitSarText = (data['debitsar'] ?? 0.0) as double;
                              double creditSarText = (data['creditsar'] ?? 0.0) as double;

                              String? drAcName = accountNames[drAcId] ?? '';
                              String? crAcName = accountNames[crAcId] ?? '';

                              // Display DR Account if available, otherwise display CR Account
                              String accountDisplayName = drAcId.isNotEmpty ? drAcName ?? 'Unknown Account' : crAcName ?? 'Unknown Account';

                              return DataRow(cells: [
                                DataCell(Text(formattedDate)),
                                DataCell(Text(accountDisplayName)),
                                DataCell(Text(debitText.toStringAsFixed(2))),
                                DataCell(Text(creditText.toStringAsFixed(2))),
                                DataCell(Text(debitSarText.toStringAsFixed(2))),
                                DataCell(Text(creditSarText.toStringAsFixed(2))),
                                DataCell(Text(remarksText)),
                              ]);
                            }).toList(),
                            // Add the totals row
                            DataRow(cells: [
                              const DataCell(Text('Totals', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataCell(Text('')),
                              DataCell(Text(totalDebitPK.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(totalCreditPK.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(totalDebitSR.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(totalCreditSR.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                              const DataCell(Text('')),
                            ]),
                            // Add the B/F Balance row
                            DataRow(cells: [
                              const DataCell(Text('B/F Balance', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataCell(Text('')),
                              DataCell(Text(bfBalancePK.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text('')),
                              DataCell(Text(bfBalanceSR.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text('')),
                              const DataCell(Text('')),
                            ]),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No account data to display!'));
                }
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

  Future<Map<String, String?>> _getAccountNames(List<DocumentSnapshot> customerList) async {
    Map<String, String?> accountNames = {};
    Set<String> accountIds = {}; // Use a Set to avoid duplicates

    // Collect all unique account IDs
    for (DocumentSnapshot document in customerList) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      // Check and add DR Account ID
      String drAcId = data['drAcId'] ?? '';
      if (drAcId.isNotEmpty) {
        accountIds.add(drAcId);
      }

      // Check and add CR Account ID
      String crAcId = data['crAcId'] ?? '';
      if (crAcId.isNotEmpty) {
        accountIds.add(crAcId);
      }
    }

    // Fetch account names for all unique IDs
    for (String acId in accountIds) {
      String? acName = await _accounts.getAccountName(acId);
      accountNames[acId] = acName;
    }

    return accountNames;
  }
}

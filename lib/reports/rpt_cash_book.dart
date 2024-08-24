import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  // Create a NumberFormat instance for comma-separated numbers
  final NumberFormat _numberFormat = NumberFormat('#,##0');

// Calculate totals
  double debitText = 0;
  double creditText = 0;
  double debitSrText = 0;
  double creditSrText = 0;

  // Calculate totals
  double totalDebitPK = 0;
  double totalCreditPK = 0;
  double totalDebitSR = 0;
  double totalCreditSR = 0;

  // Calculate b/f balances
  double bfBalancePK = 0;
  double bfBalanceSR = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Book Report'),
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printPdf,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 25.0, bottom: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(right: 10.0),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _vouchers
            .getCashBookStream(kUserId, [kCRV, kCPV]), // Pass the list of types
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

                  for (var document in customerList) {
                    Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                    totalDebitPK += (data['credit'] ?? 0.0);
                    totalCreditPK += (data['debit'] ?? 0.0);
                    totalDebitSR += (data['creditsar'] ?? 0.0);
                    totalCreditSR += (data['debitsar'] ?? 0.0);
                  }

                  // Calculate B/F Balance
                  bfBalancePK = totalDebitPK - totalCreditPK;
                  bfBalanceSR = totalDebitSR - totalCreditSR;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: constraints.maxWidth /
                              15, // Adjust column spacing
                          columns: const [
                            DataColumn(label: Text('SR-Dr')),
                            DataColumn(label: Text('SR-Cr')),
                            DataColumn(label: Text('PK-Dr')),
                            DataColumn(label: Text('PK-Cr')),
                            DataColumn(label: Text('Account')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Remarks')),
                          ],
                          rows: [
                            ...customerList.map((document) {
                              Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;

                              creditSrText = (data['creditsar'] ?? 0.0);
                              debitSrText = (data['debitsar'] ?? 0.0);
                              creditText = (data['credit'] ?? 0.0);
                              debitText = (data['debit'] ?? 0.0);

                              String drAcId = data['drAcId'] ?? '';
                              String crAcId = data['crAcId'] ?? '';
                              DateTime dateText = (data['date'] as Timestamp)
                                  .toDate();
                              String formattedDate = DateFormat('dd MM yy')
                                  .format(dateText);
                              String remarksText = data['remarks'] ?? '';

                              String? drAcName = accountNames[drAcId] ?? '';
                              String? crAcName = accountNames[crAcId] ?? '';

                              // Display DR Account if available, otherwise display CR Account
                              String accountDisplayName =
                              drAcId.isNotEmpty ? drAcName : crAcName;

                              return DataRow(cells: [
                                DataCell(Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        _numberFormat.format(creditSrText),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue)))),
                                DataCell(Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        _numberFormat.format(debitSrText),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue)))),
                                DataCell(Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        _numberFormat.format(creditText),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green)))),
                                DataCell(Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(_numberFormat.format(debitText),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green)))),
                                DataCell(Text(accountDisplayName)),
                                DataCell(Text(formattedDate)),
                                DataCell(Text(remarksText)),
                              ]);
                            }),
                            // Add the totals row
                            DataRow(cells: [
                              DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      _numberFormat.format(totalDebitSR),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue)))),
                              DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      _numberFormat.format(totalCreditSR),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue)))),
                              DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      _numberFormat.format(totalDebitPK),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)))),
                              DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      _numberFormat.format(totalCreditPK),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)))),
                              const DataCell(Text('Totals',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red))),
                              const DataCell(Text('')),
                              const DataCell(Text('')),
                            ]),
                            // Add the B/F Balance row
                            DataRow(cells: [
                              const DataCell(Text('')),
                              DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(_numberFormat.format(bfBalanceSR),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue)))),
                              const DataCell(Text('')),
                              DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(_numberFormat.format(bfBalancePK),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)))),
                              const DataCell(Text('Balance',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal))),
                              const DataCell(Text('')),
                              const DataCell(Text('')),
                            ]),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                      child: Text('No account data to display!'));
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

  Future<Map<String, String?>> _getAccountNames(
      List<DocumentSnapshot> customerList) async {
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

  void _printPdf() async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Generating PDF'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Please wait...'),
            ],
          ),
        );
      },
    );

    try {
      final snapshot = await _vouchers
          .getCashBookStream(kUserId, [kCRV, kCPV])
          .first;
      final customerList = snapshot.docs;

      final futureAccountNames = _getAccountNames(customerList);
      final accountNames = await futureAccountNames;

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Cash Book Report',
                    style: const pw.TextStyle(
                      fontSize: 20,
                    )),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Header row
                    pw.TableRow(
                      children: [
                        _buildHeaderCell('Date'),
                        _buildHeaderCell('SR-Dr'),
                        _buildHeaderCell('SR-Cr'),
                        _buildHeaderCell('PK-Dr'),
                        _buildHeaderCell('PK-Cr'),
                        _buildHeaderCell('AccountName'),
                        _buildHeaderCell('Remarks'),
                      ],
                    ),
                    // Data rows
                    ..._getPdfTableData(customerList, accountNames).map((row) {
                      return pw.TableRow(
                        children: [
                          _buildCell(row[0], pw.Alignment.center),
                          _buildCell(row[1], pw.Alignment.centerRight),
                          _buildCell(row[2], pw.Alignment.centerRight),
                          _buildCell(row[3], pw.Alignment.centerRight),
                          _buildCell(row[4], pw.Alignment.centerRight),
                          _buildCell(row[5], pw.Alignment.centerLeft),
                          _buildCell(row[6], pw.Alignment.centerLeft),
                        ],
                      );
                    }),
                    // Totals and Balance rows with bold font
                    pw.TableRow(
                      children: [
                        _buildBoldCell('Totals'),
                        _buildBoldCell(_numberFormat.format(totalDebitSR)),
                        _buildBoldCell(_numberFormat.format(totalCreditSR)),
                        _buildBoldCell(_numberFormat.format(totalDebitPK)),
                        _buildBoldCell(_numberFormat.format(totalCreditPK)),
                        pw.SizedBox(), // Empty cell
                        pw.SizedBox(), // Empty cell
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _buildBoldCell('Balance'),
                        pw.SizedBox(), // Empty cell
                        _buildBoldCell(_numberFormat.format(bfBalanceSR)),
                        pw.SizedBox(), // Empty cell
                        _buildBoldCell(_numberFormat.format(bfBalancePK)),
                        pw.SizedBox(), // Empty cell
                        pw.SizedBox(), // Empty cell
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      // Handle any errors
      // print('Error generating PDF: $e');
    } finally {
      // Dismiss the progress dialog
      Navigator.of(context).pop();
    }
  }

// Helper method to create table headers
  pw.Widget _buildHeaderCell(String text) {
    return pw.Align(
      alignment: pw.Alignment.center,
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(5.0),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ),
    );
  }

// Helper method to create table cells with alignment
  pw.Widget _buildCell(String text, pw.Alignment alignment) {
    return pw.Container(
      alignment: alignment,
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

// Helper method to create bold table cells
  pw.Widget _buildBoldCell(String text) {
    return pw.Container(
      alignment: pw.Alignment.center, padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(text,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  List<List<String>> _getPdfTableData(List<DocumentSnapshot> customerList,
      Map<String, String?> accountNames) {
    final data = <List<String>>[];

    // Adding table rows
    for (var document in customerList) {
      Map<String, dynamic> dataRow = document.data() as Map<String, dynamic>;

      String drAcId = dataRow['drAcId'] ?? '';
      String crAcId = dataRow['crAcId'] ?? '';
      DateTime dateText = (dataRow['date'] as Timestamp).toDate();
      String formattedDate = DateFormat('dd MM yy').format(dateText);
      String remarksText = dataRow['remarks'] ?? '';

      creditText = (dataRow['credit'] ?? 0.0);
      debitText = (dataRow['debit'] ?? 0.0);
      creditSrText = (dataRow['creditsar'] ?? 0.0);
      debitSrText = (dataRow['debitsar'] ?? 0.0);

      String? drAcName = accountNames[drAcId] ?? '';
      String? crAcName = accountNames[crAcId] ?? '';

      String accountDisplayName = drAcId.isNotEmpty ? drAcName : crAcName;

      data.add([
        formattedDate,
        _numberFormat.format(creditSrText),
        _numberFormat.format(debitSrText),
        _numberFormat.format(creditText),
        _numberFormat.format(debitText),
        accountDisplayName,
        remarksText,
      ]);
    }

    return data;
  }
}

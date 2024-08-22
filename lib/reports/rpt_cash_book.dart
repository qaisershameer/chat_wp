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
                color: Theme.of(context).colorScheme.primary,
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

                  // Calculate totals
                  double totalDebitPK = 0;
                  double totalCreditPK = 0;
                  double totalDebitSR = 0;
                  double totalCreditSR = 0;

                  for (var document in customerList) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    totalDebitPK += (data['credit'] ?? 0.0) as double;
                    totalCreditPK += (data['debit'] ?? 0.0) as double;
                    totalDebitSR += (data['creditsar'] ?? 0.0) as double;
                    totalCreditSR += (data['debitsar'] ?? 0.0) as double;
                  }

                  // Calculate B/F Balance
                  double bfBalancePK = totalDebitPK - totalCreditPK;
                  double bfBalanceSR = totalDebitSR - totalCreditSR;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: constraints.maxWidth /
                              15, // Adjust column spacing
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('PK-Dr')),
                            DataColumn(label: Text('PK-Cr')),
                            DataColumn(label: Text('SR-Dr')),
                            DataColumn(label: Text('SR-Cr')),
                            DataColumn(label: Text('Account')),
                            DataColumn(label: Text('Remarks')),
                          ],
                          rows: [
                            ...customerList.map((document) {
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;

                              String drAcId = data['drAcId'] ?? '';
                              String crAcId = data['crAcId'] ?? '';
                              DateTime dateText =
                                  (data['date'] as Timestamp).toDate();
                              String formattedDate =
                                  DateFormat('dd MM yy').format(dateText);
                              String remarksText = data['remarks'] ?? '';
                              double creditText =
                                  (data['credit'] ?? 0.0) as double;
                              double debitText =
                                  (data['debit'] ?? 0.0) as double;
                              double creditSarText =
                                  (data['creditsar'] ?? 0.0) as double;
                              double debitSarText =
                                  (data['debitsar'] ?? 0.0) as double;

                              String? drAcName = accountNames[drAcId] ?? '';
                              String? crAcName = accountNames[crAcId] ?? '';

                              // Display DR Account if available, otherwise display CR Account
                              String accountDisplayName =
                                  drAcId.isNotEmpty ? drAcName : crAcName;

                              return DataRow(cells: [
                                DataCell(Text(formattedDate)),
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
                                DataCell(Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        _numberFormat.format(creditSarText),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue)))),
                                DataCell(Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        _numberFormat.format(debitSarText),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue)))),
                                DataCell(Text(accountDisplayName)),
                                DataCell(Text(remarksText)),
                              ]);
                            }),
                            // Add the totals row
                            DataRow(cells: [
                              const DataCell(Text('Totals',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
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
                              const DataCell(Text('')),
                              const DataCell(Text('')),
                            ]),
                            // Add the B/F Balance row
                            DataRow(cells: [
                              const DataCell(Text('B/F Balance',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                              const DataCell(Text('')),
                              DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(_numberFormat.format(bfBalancePK),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)))),
                              const DataCell(Text('')),
                              DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(_numberFormat.format(bfBalanceSR),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue)))),
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
      final snapshot =
          await _vouchers.getCashBookStream(kUserId, [kCRV, kCPV]).first;
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
                        _buildHeaderCell('PK-Dr'),
                        _buildHeaderCell('PK-Cr'),
                        _buildHeaderCell('SR-Dr'),
                        _buildHeaderCell('SR-Cr'),
                        _buildHeaderCell('Account'),
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

  List<List<String>> _getPdfTableData(
      List<DocumentSnapshot> customerList, Map<String, String?> accountNames) {
    final data = <List<String>>[];

    // Adding table rows
    for (var document in customerList) {
      Map<String, dynamic> dataRow = document.data() as Map<String, dynamic>;

      String drAcId = dataRow['drAcId'] ?? '';
      String crAcId = dataRow['crAcId'] ?? '';
      DateTime dateText = (dataRow['date'] as Timestamp).toDate();
      String formattedDate = DateFormat('dd MM yy').format(dateText);
      String remarksText = dataRow['remarks'] ?? '';
      double creditText = (dataRow['credit'] ?? 0.0) as double;
      double debitText = (dataRow['debit'] ?? 0.0) as double;
      double creditSarText = (dataRow['creditsar'] ?? 0.0) as double;
      double debitSarText = (dataRow['debitsar'] ?? 0.0) as double;

      String? drAcName = accountNames[drAcId] ?? '';
      String? crAcName = accountNames[crAcId] ?? '';

      String accountDisplayName = drAcId.isNotEmpty ? drAcName : crAcName;

      data.add([
        formattedDate,
        _numberFormat.format(creditText),
        _numberFormat.format(debitText),
        _numberFormat.format(creditSarText),
        _numberFormat.format(debitSarText),
        accountDisplayName,
        remarksText,
      ]);
    }

    // Add totals and B/F Balance rows
    double totalDebitPK = 0;
    double totalCreditPK = 0;
    double totalDebitSR = 0;
    double totalCreditSR = 0;

    for (var document in customerList) {
      Map<String, dynamic> dataRow = document.data() as Map<String, dynamic>;
      totalDebitPK += (dataRow['credit'] ?? 0.0) as double;
      totalCreditPK += (dataRow['debit'] ?? 0.0) as double;
      totalDebitSR += (dataRow['creditsar'] ?? 0.0) as double;
      totalCreditSR += (dataRow['debitsar'] ?? 0.0) as double;
    }

    double bfBalancePK = totalDebitPK - totalCreditPK;
    double bfBalanceSR = totalDebitSR - totalCreditSR;

    data.add([
      'Totals',
      _numberFormat.format(totalDebitPK),
      _numberFormat.format(totalCreditPK),
      _numberFormat.format(totalDebitSR),
      _numberFormat.format(totalCreditSR),
      '',
      '',
    ]);
    data.add([
      'Balance',
      '',
      _numberFormat.format(bfBalancePK),
      '',
      _numberFormat.format(bfBalanceSR),
      '',
      '',
    ]);

    return data;
  }
}

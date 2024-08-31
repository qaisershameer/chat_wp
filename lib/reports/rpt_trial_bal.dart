import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_wp/themes/const.dart';
import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/services/accounts/ac_voucher_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RptTrialBal extends StatefulWidget {
  const RptTrialBal({super.key});

  @override
  State<RptTrialBal> createState() => RptTrialBalState();
}

class RptTrialBalState extends State<RptTrialBal> {
  final AccountService _accounts = AccountService();
  final AcVoucherService _vouchers = AcVoucherService();
  // final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  String? _selectedAcId, _selectedAcText, _selectedType;
  // bool _showData = false;

  final List<String> _accountType = <String>[
    'PARTY',
    'PARTY B',
    'ASSETS',
    'LIABILITY',
    'CAPITAL',
    'REVENUE',
    'EXPENSE',
  ];

  // Create a NumberFormat instance for comma-separated numbers
  final NumberFormat _numberFormat = NumberFormat('#,##0');
  final NumberFormat _numberFormat1 = NumberFormat('#,##0.0');
  final NumberFormat _numberFormat2 = NumberFormat('#,##0.00');

  // Numeric Fields Double Variables
  double debitText = 0;
  double creditText = 0;
  double debitSrText = 0;
  double creditSrText = 0;

  double totalDebitPK = 0;
  double totalCreditPK = 0;
  double totalDebitSR = 0;
  double totalCreditSR = 0;

  double bfBalancePK = 0;
  double bfBalanceSR = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trial Balance'),
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            // onPressed: _printPdf,
            onPressed: () {},
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
      body: Form(
        // key: _formKeyValue,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          children: <Widget>[
            // ACCOUNT TYPE Data COMBO
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.moneyBill,
                  size: 25.0,
                  color: Colors.teal,
                ),
                const SizedBox(width: 20.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.25,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    items: _accountType
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.teal),
                        ),
                      );
                    }).toList(),
                    onChanged: (typeValue) {
                      setState(() {
                        if (_selectedType != typeValue) {
                          _selectedType = typeValue;
                        }
                      });
                    },
                    value: _selectedType,
                    hint: const Text(
                      'Select Type',
                      style: TextStyle(color: Colors.teal),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an account type';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            if (_selectedType != null) rptTrial()
          ],
        ),
      ),
    );
  }

  Widget rptTrial() {
    totalDebitPK = 0;
    totalCreditPK = 0;
    totalDebitSR = 0;
    totalCreditSR = 0;
    bfBalancePK = 0;
    bfBalanceSR = 0;

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _vouchers.getTrialBalanceStream(kUserId, _selectedAcId ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final documents = snapshot.data ?? [];
        List<DocumentSnapshot> customerList =
        documents.cast<DocumentSnapshot>();

        return FutureBuilder<Map<String, String?>>(
          future: _getAccountNames(customerList),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (futureSnapshot.hasError) {
              return Center(child: Text('Error: ${futureSnapshot.error}'));
            } else if (futureSnapshot.hasData) {
              // Map<String, String?> accountNames = futureSnapshot.data!;

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: constraints.maxWidth / 15,
                        border: TableBorder.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        columns: const [
                          DataColumn(label: Center(child: Text('SR-Dr')),),
                          DataColumn(label: Center(child: Text('SR-Cr')),),
                          DataColumn(label: Center(child: Text('PK-Dr')),),
                          DataColumn(label: Center(child: Text('PK-Cr')),),
                          // DataColumn(label: Center(child: Text('Date')),),
                          // DataColumn(label: Center(child: Text('Remarks')),),
                        ],
                        rows: [
                          ...customerList.map((document) {
                            Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                            String drAcId = data['drAcId'] ?? '';
                            String crAcId = data['crAcId'] ?? '';
                            String type = data['type'] ?? '';
                            DateTime dateText =
                            (data['date'] as Timestamp).toDate();
                            String formattedDate =
                            DateFormat('dd MM yy').format(dateText);
                            String remarksText = data['remarks'] ?? '';

                            if (type == 'JV') {
                              if (_selectedAcId == drAcId) {
                                debitText = (data['credit'] ?? 0.0);
                                creditText = 0.0;
                                debitSrText = (data['creditsar'] ?? 0.0);
                                creditSrText = 0.0;
                              } else {
                                debitText = 0.0;
                                creditText = (data['debit'] ?? 0.0);
                                debitSrText = 0.0;
                                creditSrText = (data['debitsar'] ?? 0.0);
                              }
                            } else {
                              debitText = (data['credit'] ?? 0.0);
                              creditText = (data['debit'] ?? 0.0);
                              debitSrText = (data['creditsar'] ?? 0.0);
                              creditSrText = (data['debitsar'] ?? 0.0);
                            }

                            // Calculate Totals
                            totalDebitPK += creditText;
                            totalCreditPK += debitText;
                            totalDebitSR += creditSrText;
                            totalCreditSR += debitSrText;

                            // Calculate B/F Balances
                            bfBalancePK = totalDebitPK - totalCreditPK;
                            bfBalanceSR = totalDebitSR - totalCreditSR;

                            return DataRow(cells: [
                              DataCell(Container(alignment: Alignment.centerRight,
                                child: Text(
                                  _numberFormat.format(creditSrText),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              )),
                              DataCell(Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _numberFormat.format(debitSrText),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              )),
                              DataCell(Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _numberFormat.format(creditText),
                                  style: const TextStyle(
                                    color: Colors.green,
                                  ),
                                ),
                              )),
                              DataCell(Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _numberFormat.format(debitText),
                                  style: const TextStyle(
                                    color: Colors.green,
                                  ),
                                ),
                              )),
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
                                  color: Colors.blue,
                                ),
                              ),
                            )),
                            DataCell(Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(totalCreditSR),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            )),
                            DataCell(Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(totalDebitPK),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            )),
                            DataCell(Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(totalCreditPK),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            )),
                            const DataCell(Text(
                              'Totals',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            )),
                            const DataCell(Text('')),
                          ]),
                          // Add the B/F Balance row
                          DataRow(cells: [
                            const DataCell(Text('')),
                            DataCell(Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(bfBalanceSR),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            )),
                            const DataCell(Text('')),
                            DataCell(Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(bfBalancePK),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            )),
                            const DataCell(Text(
                              'Balance',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            )),
                            const DataCell(Text('')),
                          ]),
                        ],
                      ),
                    ),
                  );
                },
              );


            }

            return const Center(child: Text('No data available'));
          },
        );
      },
    );
  }

  Future<Map<String, String?>> _getAccountNames(
      List<DocumentSnapshot> customerList) async {
    Map<String, String?> accountNames = {};
    for (var document in customerList) {
      String drAcId = (document.data() as Map<String, dynamic>)['drAcId'] ?? '';
      if (drAcId.isNotEmpty) {
        // DocumentSnapshot accountDoc = await _accounts.getAccountById(drAcId);
        // accountNames[drAcId] = accountDoc.get('accountName');
        accountNames[drAcId] = 'QAISER SHAMEER';
      }
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
      await _vouchers.getCashBookStream(kUserId, [kCRV, kCPV], null, null).first;
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
                // pw.Text('Ledger: $_selectedAcText',
                pw.Text('Trial Balance',
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
                        _buildHeaderCell('SR-Cr'),
                        _buildHeaderCell('SR-Dr'),
                        _buildHeaderCell('PK-Cr'),
                        _buildHeaderCell('PK-Dr'),
                        // _buildHeaderCell('AccountName'),
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
                          // _buildCell(row[6], pw.Alignment.centerLeft),
                        ],
                      );
                    }),
                    // Totals and Balance rows with bold font
                    pw.TableRow(
                      children: [
                        _buildBoldCell('Totals', pw.Alignment.centerRight),
                        _buildBoldCell(_numberFormat.format(totalDebitSR),
                            pw.Alignment.centerRight),
                        _buildBoldCell(_numberFormat.format(totalCreditSR),
                            pw.Alignment.centerRight),
                        _buildBoldCell(_numberFormat.format(totalDebitPK),
                            pw.Alignment.centerRight),
                        _buildBoldCell(_numberFormat.format(totalCreditPK),
                            pw.Alignment.centerRight),
                        pw.SizedBox(), // Empty cell
                        // pw.SizedBox(), // Empty cell
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _buildBoldCell('Balance', pw.Alignment.centerRight),
                        pw.SizedBox(), // Empty cell
                        _buildBoldCell(_numberFormat.format(bfBalanceSR),
                            pw.Alignment.centerRight),
                        pw.SizedBox(), // Empty cell
                        _buildBoldCell(_numberFormat.format(bfBalancePK),
                            pw.Alignment.centerRight),
                        pw.SizedBox(), // Empty cell
                        // pw.SizedBox(), // Empty cell
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
  pw.Widget _buildBoldCell(String text, pw.Alignment alignment) {
    return pw.Container(
      alignment: alignment,
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
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
      String type = dataRow['type'] ?? '';

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
        // accountDisplayName,
        remarksText,
      ]);

      totalDebitPK = 0;
      totalCreditPK = 0;
      totalDebitSR = 0;
      totalCreditSR = 0;
      bfBalancePK = 0;
      bfBalanceSR = 0;

      if (type == 'JV') {
        if (_selectedAcId == drAcId) {
          debitText = debitText;
          creditText = 0.0;

          debitSrText = debitSrText;
          creditSrText = 0.0;
        } else {
          debitText = 0.0;
          creditText = creditText;

          debitSrText = 0.0;
          creditSrText = creditSrText;
        }
      } else {
        debitText = debitText;
        creditText = creditText;

        debitSrText = debitSrText;
        creditSrText = creditSrText;
      }

      totalDebitPK += creditText;
      totalCreditPK += debitText;
      totalDebitSR += creditSrText;
      totalCreditSR += debitSrText;

      // Calculate B/F Balance
      bfBalancePK = totalDebitPK - totalCreditPK;
      bfBalanceSR = totalDebitSR - totalCreditSR;
    }

    return data;
  }
}
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  DateTime? _selectedDateFrom = DateTime.now();
  DateTime? _selectedDateTo = DateTime.now();

  // Create a NumberFormat instance for comma-separated numbers
  final NumberFormat _numberFormat = NumberFormat('#,##0.00');

  String? _selectedReport;
  // bool _showData = false;

  final List<String> _accountType = <String>[
    'ALL',
    'SAR',
    'PKR',
  ];

  // field variables
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

  Future<void> _selectDate(BuildContext context, String type) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      currentDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    getDate(pickedDate, type);
  }

  void getDate(DateTime? pickedDate, String type) {
    if (pickedDate != null) {
      setState(() {
        if (type == 'from') {
          _selectedDateFrom = pickedDate;
          // print(pickedDate);
          _dateFromController.text = DateFormat('dd-MMM-yyyy').format(pickedDate);
        } else if (type == 'to') {
          _selectedDateTo = pickedDate;
          _dateToController.text = DateFormat('dd-MMM-yyyy').format(pickedDate);
        }
      });
    }else{
      _dateFromController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());
      _dateToController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with data from the previous screen
    // _voucherId = widget.docId;
    _dateFromController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    _dateToController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    DateTime now = DateTime.now();
    getDate(DateTime(now.year, now.month, now.day), 'from');
  }

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
      body: Form(
        // key: _formKeyValue,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          children: <Widget>[
            // Row for ACCOUNT TYPE Data COMBO and DATE FROM
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // ACCOUNT TYPE Data COMBO
                const Icon(
                  FontAwesomeIcons.database,
                  size: 25.0,
                  color: Colors.teal,
                ),
                const SizedBox(width: 10.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 7.0, // Adjusted width
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    items: _accountType.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.teal,fontSize: 12.0,),
                        ),
                      );
                    }).toList(),
                    onChanged: (typeValue) {
                      setState(() {
                        if (_selectedReport != typeValue) {
                          _selectedReport = typeValue;
                        }
                      });
                    },
                    value: _selectedReport,
                    hint: const Text(
                      'Style',
                      style: TextStyle(color: Colors.teal, fontSize: 12.0),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a valid report style';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10.0),
                // Date FROM Text Field

                Expanded(
                  child: TextFormField(
                    controller: _dateFromController,
                    keyboardType: TextInputType.none, // Disable// keyboard input
                    onTap: () {
                      FocusScope.of(context)
                          .requestFocus(FocusNode()); // Hide keyboard
                      _selectDate(context, 'from'); // Show date picker
                    },
                    style: const TextStyle(fontSize: 12.0,), // Set font size to 12.0
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.calendar_month, // Changed to a Flutter icon
                        color: Colors.teal,
                      ),
                      hintText: 'Date From',
                      labelText: 'From',
                      labelStyle: TextStyle(color: Colors.teal),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Invalid Date From';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10.0),
                // Date To Text Field
                Expanded(
                  child: TextFormField(
                    controller: _dateToController,
                    keyboardType: TextInputType.none, // Disable keyboard input
                    onTap: () {
                      FocusScope.of(context)
                          .requestFocus(FocusNode()); // Hide keyboard
                      _selectDate(context, 'to'); // Show date picker
                    },
                    style: const TextStyle(fontSize: 12.0,), // Set font size to 12.0
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.calendar_month, // Changed to a Flutter icon
                        color: Colors.teal,
                      ),
                      hintText: 'Date To',
                      labelText: 'To',
                      labelStyle: TextStyle(color: Colors.teal),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Invalid Date To';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            if (_selectedReport != null) _rptCashBook(),
          ],
        ),

      ),

    );
  }

  StreamBuilder<QuerySnapshot<Object?>> _rptCashBook() {
    return StreamBuilder<QuerySnapshot>(
      stream: _vouchers.getCashBookStream(kUserId, [kCRV, kCPV], _selectedDateFrom, _selectedDateTo), // Pass the list of types
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

                // Initialize totals
                totalDebitPK = 0.0;
                totalCreditPK = 0.0;
                totalDebitSR = 0.0;
                totalCreditSR = 0.0;

                // Calculate totals
                for (var document in customerList) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  totalDebitPK += (data['credit'] ?? 0.0);
                  totalCreditPK += (data['debit'] ?? 0.0);
                  totalDebitSR += (data['creditsar'] ?? 0.0);
                  totalCreditSR += (data['debitsar'] ?? 0.0);
                }

                // Calculate B/F Balance
                bfBalancePK = totalDebitPK - totalCreditPK;
                bfBalanceSR = totalDebitSR - totalCreditSR;

                // Determine columns to display based on _selectedReport
                List<DataColumn> columns = [];
                List<int> visibleColumns = [];

                switch (_selectedReport) {
                  case 'ALL':
                    columns = const [
                      DataColumn(label: Text('SR-Dr')),
                      DataColumn(label: Text('SR-Cr')),
                      DataColumn(label: Text('PK-Dr')),
                      DataColumn(label: Text('PK-Cr')),
                      DataColumn(label: Text('Account')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Remarks')),
                    ];
                    visibleColumns = [0, 1, 2, 3, 4, 5, 6];
                    break;
                  case 'SAR':
                    columns = const [
                      DataColumn(label: Text('SR-Dr')),
                      DataColumn(label: Text('SR-Cr')),
                      DataColumn(label: Text('Account')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Remarks')),
                    ];
                    visibleColumns = [0, 1, 4, 5, 6];
                    break;
                  case 'PKR':
                    columns = const [
                      DataColumn(label: Text('PK-Dr')),
                      DataColumn(label: Text('PK-Cr')),
                      DataColumn(label: Text('Account')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Remarks')),
                    ];
                    visibleColumns = [2, 3, 4, 5, 6];
                    break;
                  default:
                    columns = const [];
                    visibleColumns = [];
                    break;
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: constraints.maxWidth / 15, // Adjust column spacing
                          columns: columns,
                          rows: [
                            ...customerList.map((document) {
                              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                              final creditSrText = (data['creditsar'] ?? 0.0);
                              final debitSrText = (data['debitsar'] ?? 0.0);
                              final creditText = (data['credit'] ?? 0.0);
                              final debitText = (data['debit'] ?? 0.0);

                              final drAcId = data['drAcId'] ?? '';
                              final crAcId = data['crAcId'] ?? '';
                              final dateText = (data['date'] as Timestamp).toDate();
                              final formattedDate = DateFormat('dd MM yy').format(dateText);
                              final remarksText = data['remarks'] ?? '';

                              final drAcName = accountNames[drAcId] ?? '';
                              final crAcName = accountNames[crAcId] ?? '';

                              final accountDisplayName = drAcId.isNotEmpty ? drAcName : crAcName;

                              return DataRow(cells: [
                                if (visibleColumns.contains(0))
                                  DataCell(Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _numberFormat.format(creditSrText),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  )),
                                if (visibleColumns.contains(1))
                                  DataCell(Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _numberFormat.format(debitSrText),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  )),
                                if (visibleColumns.contains(2))
                                  DataCell(Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _numberFormat.format(creditText),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  )),
                                if (visibleColumns.contains(3))
                                  DataCell(Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _numberFormat.format(debitText),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  )),
                                if (visibleColumns.contains(4))
                                  DataCell(Text(accountDisplayName)),
                                if (visibleColumns.contains(5))
                                  DataCell(Text(formattedDate)),
                                if (visibleColumns.contains(6))
                                  DataCell(Text(remarksText)),
                              ]);
                            }),
                            // Add the totals row
                            DataRow(cells: [
                              if (visibleColumns.contains(0))
                                DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat.format(totalDebitSR),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                )),
                              if (visibleColumns.contains(1))
                                DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat.format(totalCreditSR),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                )),
                              if (visibleColumns.contains(2))
                                DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat.format(totalDebitPK),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                )),
                              if (visibleColumns.contains(3))
                                DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat.format(totalCreditPK),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                )),
                              if (visibleColumns.contains(4))
                                const DataCell(Text(
                                  'Totals',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                )),
                              if (visibleColumns.contains(5)) const DataCell(Text('')),
                              if (visibleColumns.contains(6)) const DataCell(Text('')),
                            ]),
                            // Add the B/F Balance row
                            DataRow(cells: [
                              if (visibleColumns.contains(0)) const DataCell(Text('')),
                              if (visibleColumns.contains(1))
                                DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat.format(bfBalanceSR),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                )),
                              if (visibleColumns.contains(2)) const DataCell(Text('')),
                              if (visibleColumns.contains(3))
                                DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat.format(bfBalancePK),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                )),
                              if (visibleColumns.contains(4))
                                const DataCell(Text(
                                  'Balance',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                )),
                              if (visibleColumns.contains(5)) const DataCell(Text('')),
                              if (visibleColumns.contains(6)) const DataCell(Text('')),
                            ]),
                          ],
                        ),
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
          .getCashBookStream(kUserId, [kCRV, kCPV], _selectedDateFrom, _selectedDateTo)
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

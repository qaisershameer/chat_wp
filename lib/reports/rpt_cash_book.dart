import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chat_wp/pages/accounts/voucher_crv_add.dart';
import 'package:chat_wp/pages/accounts/voucher_cpv_add.dart';
import 'package:chat_wp/pages/accounts/voucher_jv_add.add.dart';

import 'package:chat_wp/themes/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/services/accounts/ac_voucher_service.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  final NumberFormat _numberFormat = NumberFormat('#,##0');
  final NumberFormat _numberFormat1 = NumberFormat('#,##0.0');
  // final NumberFormat _numberFormat2 = NumberFormat('#,##0.00');

  String? _selectedReport;
  // bool _showData = false;

  final List<String> _accountType = <String>[
    'ALL',
    'SAR',
    'PKR',
  ];

  // Basic Fields Double Variables
  String voucherID = '';
  DateTime vDate = DateTime.now();
  String drAcId = '';
  String crAcId = '';
  String type = '';
  String remarksText = '';

  // Numeric Fields Double Variables
  double debitText = 0;
  double creditText = 0;
  double debitSrText = 0;
  double creditSrText = 0;

  // Calculate totals Double Variables
  double totalDebitPK = 0;
  double totalCreditPK = 0;
  double totalDebitSR = 0;
  double totalCreditSR = 0;

  // Calculate b/f balances Double Variables
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
          _dateFromController.text =
              DateFormat('dd-MMM-yyyy').format(pickedDate);
        } else if (type == 'to') {
          _selectedDateTo = pickedDate;
          _dateToController.text = DateFormat('dd-MMM-yyyy').format(pickedDate);
        }
      });
    } else {
      _dateFromController.text =
          DateFormat('dd-MMM-yyyy').format(DateTime.now());
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
    _selectedReport = 'SAR';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Book'),
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            // icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoucherCrvAdd(
                    docId: '',
                    type: '',
                    acType: kBank,
                    vDate: vDate,
                    remarks: 'Cash Received.',
                    drAcId: '',
                    crAcId: '',
                    debit: 0,
                    debitSar: 0,
                    credit: 0,
                    creditSar: 0,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.payment_rounded),
            // icon: const Icon(Icons.exposure_minus_1),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoucherCpvAdd(
                    docId: '',
                    type: '',
                    acType: kBank,
                    vDate: vDate,
                    remarks: 'Cash Paid.',
                    drAcId: '',
                    crAcId: '',
                    debit: 0,
                    debitSar: 0,
                    credit: 0,
                    creditSar: 0,
                  ),
                ),
              );
            },
          ),
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
                  width:
                      MediaQuery.of(context).size.width / 7.0, // Adjusted width
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    items: _accountType
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 12.0,
                          ),
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
                    keyboardType:
                        TextInputType.none, // Disable// keyboard input
                    onTap: () {
                      FocusScope.of(context)
                          .requestFocus(FocusNode()); // Hide keyboard
                      _selectDate(context, 'from'); // Show date picker
                    },
                    style: const TextStyle(
                      fontSize: 12.0,
                    ), // Set font size to 12.0
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
                    style: const TextStyle(
                      fontSize: 12.0,
                    ), // Set font size to 12.0
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
      stream: _vouchers.getCashBookStream(kUserId, [kCRV, kCPV],
          _selectedDateFrom, _selectedDateTo), // Pass the list of types
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<DocumentSnapshot> accountsList = snapshot.data!.docs;

          return FutureBuilder<Map<String, String?>>(
            future: _getAccountNames(accountsList),
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
                for (var document in accountsList) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  totalDebitPK += (data['debit'] ?? 0.0);
                  totalCreditPK += (data['credit'] ?? 0.0);
                  totalDebitSR += (data['debitsar'] ?? 0.0);
                  totalCreditSR += (data['creditsar'] ?? 0.0);
                }

                // Calculate B/F Balance
                bfBalancePK = totalCreditPK - totalDebitPK;
                bfBalanceSR = totalCreditSR - totalDebitSR;

                // Determine columns to display based on _selectedReport
                List<DataColumn> columns = [];
                List<int> visibleColumns = [];

                switch (_selectedReport) {
                  case 'ALL':
                    columns = const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Sr-Out')),
                      DataColumn(label: Text('Sr-in')),
                      DataColumn(label: Text('Pk-Out')),
                      DataColumn(label: Text('Pk-In')),
                      DataColumn(label: Text('Account')),
                      DataColumn(label: Text('Remarks')),
                    ];
                    visibleColumns = [0, 1, 2, 3, 4, 5, 6];
                    break;
                  case 'SAR':
                    columns = const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Sr-Out')),
                      DataColumn(label: Text('Sr-In')),
                      DataColumn(label: Text('Account')),
                      DataColumn(label: Text('Remarks')),
                    ];
                    visibleColumns = [0, 1, 2, 5, 6];
                    break;
                  case 'PKR':
                    columns = const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Pk-Out')),
                      DataColumn(label: Text('Pk-In')),
                      DataColumn(label: Text('Account')),
                      DataColumn(label: Text('Remarks')),
                    ];
                    visibleColumns = [0, 3, 4, 5, 6];
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

                          headingRowColor:WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                            // Return the color you want to use for the highlighted row
                            return Colors.grey.withOpacity(0.5); // Example color with transparency
                          }),

                          border: TableBorder.all(color: Colors.grey),

                          columnSpacing: constraints.maxWidth /
                              15, // Adjust column spacing
                          columns: columns,
                          rows: <DataRow>[
                            // Add the totals row
                            DataRow(
                                color: WidgetStateProperty.resolveWith<Color>(
                                    (Set<WidgetState> states) {
                                  // Return the color you want to use for the highlighted row
                                  return Colors.teal.withOpacity(
                                      0.25); // Example color with transparency
                                }),
                                cells: [
                                  if (visibleColumns.contains(0))
                                    DataCell(Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _selectedReport != 'PKR'
                                            ? _numberFormat.format(bfBalanceSR)
                                            : '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )),

                                  if (visibleColumns.contains(1))
                                    DataCell(Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _numberFormat.format(totalDebitSR),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                      ),
                                    )),
                                  if (visibleColumns.contains(2))
                                    DataCell(Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _numberFormat.format(totalCreditSR),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                      ),
                                    )),
                                  if (visibleColumns.contains(3))
                                    DataCell(Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _numberFormat1.format(totalDebitPK),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    )),
                                  if (visibleColumns.contains(4))
                                    DataCell(Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _numberFormat1.format(totalCreditPK),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    )),
                                  if (visibleColumns.contains(5))
                                    DataCell(Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _selectedReport != 'SAR'
                                            ? _numberFormat1.format(bfBalancePK)
                                            : '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.green,
                                        ),
                                      ),
                                    )),
                                  if (visibleColumns.contains(6))
                                    const DataCell(Text(
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black,
                                      ),
                                    )),
                                  // if (visibleColumns.contains(6)) const DataCell(Text('')),
                                ]),

                            // Add the detail row records
                            ...accountsList.map((document) {
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;

                              final voucherID = document
                                  .id; // Use final here to ensure immutability
                              // final data = document.data() as Map<String, dynamic>;

                              final creditSrText = (data['debitsar'] ?? 0.0);
                              final debitSrText = (data['creditsar'] ?? 0.0);
                              final creditText = (data['debit'] ?? 0.0);
                              final debitText = (data['credit'] ?? 0.0);

                              final drAcId = data['drAcId'] ?? '';
                              final crAcId = data['crAcId'] ?? '';
                              final dateText =
                                  (data['date'] as Timestamp).toDate();
                              final formattedDate =
                                  DateFormat('dd MMM').format(dateText);
                              final remarksText = data['remarks'] ?? '';
                              final type = data['type'] ?? '';

                              final drAcName = accountNames[drAcId] ?? '';
                              final crAcName = accountNames[crAcId] ?? '';

                              final accountDisplayName =
                                  drAcId.isNotEmpty ? drAcName : crAcName;

                              // Adding Detail Record Rows
                              return DataRow(
                                  // color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {// Return the color you want to use for the highlighted row
                                  //   return Colors.white.withOpacity(0.25); // Example color with transparency
                                  // }),

                                  cells: [
                                    if (visibleColumns.contains(0))
                                      DataCell(Text(formattedDate,
                                          style: const TextStyle(
                                            color: Colors.blueGrey,
                                          ))),
                                    if (visibleColumns.contains(1))
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
                                    if (visibleColumns.contains(2))
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
                                    if (visibleColumns.contains(3))
                                      DataCell(Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _numberFormat1.format(creditText),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      )),
                                    if (visibleColumns.contains(4))
                                      DataCell(Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _numberFormat1.format(debitText),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      )),
                                    if (visibleColumns.contains(5))
                                      DataCell(GestureDetector(
                                        onTap: () {
                                          // print('Navigating to VoucherCpvAdd with docId: $voucherID');
                                          try {
                                            if (voucherID.isNotEmpty) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    if (type == 'CP') {
                                                      return VoucherCpvAdd(
                                                        docId: voucherID,
                                                        type: type,
                                                        acType: kBank,
                                                        vDate: dateText,
                                                        remarks: remarksText,
                                                        drAcId: drAcId,
                                                        crAcId: '',
                                                        debit: data['debit'],
                                                        debitSar:
                                                            data['debitsar'],
                                                        credit: data['credit'],
                                                        creditSar:
                                                            data['creditsar'],
                                                      );
                                                    } else if (type == 'CR') {
                                                      return VoucherCrvAdd(
                                                        docId: voucherID,
                                                        type: type,
                                                        acType: kBank,
                                                        vDate: dateText,
                                                        remarks: remarksText,
                                                        drAcId: '',
                                                        crAcId: crAcId,
                                                        debit: data['debit'],
                                                        debitSar:
                                                            data['debitsar'],
                                                        credit: data['credit'],
                                                        creditSar:
                                                            data['creditsar'],
                                                      );
                                                    } else if (type == 'JV') {
                                                      return VoucherJvAdd(
                                                        docId: voucherID,
                                                        type: type,
                                                        vDate: dateText,
                                                        remarks: remarksText,
                                                        drAcId: drAcId,
                                                        crAcId: crAcId,
                                                        debit: data['debit'],
                                                        debitSar:
                                                            data['debitsar'],
                                                        credit: data['credit'],
                                                        creditSar:
                                                            data['creditsar'],
                                                      );
                                                    }
                                                    return const SizedBox
                                                        .shrink(); // Fallback if no type matches
                                                  },
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            // print('Error during navigation: $e');
                                          }
                                        },
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(accountDisplayName),
                                        ),
                                      )),
                                    if (visibleColumns.contains(6))
                                      DataCell(Text(remarksText)),
                                  ]);
                            }),
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
      List<DocumentSnapshot> accountsList) async {
    Map<String, String?> accountNames = {};
    Set<String> accountIds = {}; // Use a Set to avoid duplicates

    // Collect all unique account IDs
    for (DocumentSnapshot document in accountsList) {
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
          .getCashBookStream(
              kUserId, [kCRV, kCPV], _selectedDateFrom, _selectedDateTo)
          .first;
      final accountsList = snapshot.docs;

      final futureAccountNames = _getAccountNames(accountsList);
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
                    ..._getPdfTableData(accountsList, accountNames).map((row) {
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
      alignment: pw.Alignment.center,
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
      List<DocumentSnapshot> accountsList, Map<String, String?> accountNames) {
    final data = <List<String>>[];

    // Adding table rows
    for (var document in accountsList) {
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

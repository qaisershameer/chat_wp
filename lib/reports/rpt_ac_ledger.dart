import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chat_wp/themes/const.dart';
import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/services/accounts/ac_voucher_service.dart';

import 'package:chat_wp/pages/accounts/voucher_crv_add.dart';
import 'package:chat_wp/pages/accounts/voucher_cpv_add.dart';
import 'package:chat_wp/pages/accounts/voucher_jv_add.add.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RptAcLedger extends StatefulWidget {
  const RptAcLedger({super.key});

  @override
  State<RptAcLedger> createState() => RptAcLedgerState();
}

class RptAcLedgerState extends State<RptAcLedger> {
  final AccountService _accounts = AccountService();
  final AcVoucherService _vouchers = AcVoucherService();
  // final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  String? _selectedAcId, _selectedAcText, _selectedReport;
  // bool _showData = false;

  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  DateTime? _selectedDateFrom = DateTime.now();
  DateTime? _selectedDateTo = DateTime.now();

  // Create a NumberFormat instance for comma-separated numbers
  final NumberFormat _numberFormat = NumberFormat('#,##0');
  final NumberFormat _numberFormat1 = NumberFormat('#,##0.0');
  final NumberFormat _numberFormat2 = NumberFormat('#,##0.00');

  final List<String> _reportType = <String>[
    'ALL',
    'SAR',
    'PKR',
  ];

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

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with data from the previous screen
    // _voucherId = widget.docId;
    // _dateFromController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());    // OKAY WORKING but i change below line
    _dateFromController.text = kStartDate; // SESSION START DATE
    _dateToController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());

    // For Form Load From Variable Default Value Set here
    DateTime now = DateTime.now();
    // getDate(DateTime(now.year, now.month, now.day), 'from'); // OKAY WORKING but i change below line
    getDate(DateTime(now.year, 1, 1), 'from');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger'),
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
                    vDate: vDate,
                    remarks: 'Cash Received.',
                    drAcId: '',
                    crAcId: _selectedAcId!,
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
                    vDate: vDate,
                    remarks: 'Cash Paid.',
                    drAcId: _selectedAcId!,
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
            icon: const Icon(Icons.ac_unit_sharp),
            // icon: const Icon(Icons.safety_divider),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoucherJvAdd(
                    docId: '',
                    type: '',
                    vDate: vDate,
                    remarks: 'Amount Transferred.',
                    drAcId: _selectedAcId!,
                    crAcId: _selectedAcId!,
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
            // onPressed: _printPdf,
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, bottom: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(right: 5.0),
            ),
          ),
        ],
      ),
      body: Form(
        // key: _formKeyValue,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          children: <Widget>[
            // REPORT TYPE Data COMBO, DATE FROM, DATE TO
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
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
                    items: _reportType
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

            const SizedBox(height: 5.0),

            // Account TYPE Data COMBO
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _accounts.getAccountsStream(kUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      List<DocumentSnapshot> accountList =
                          snapshot.data?.docs ?? [];

                      return DropdownSearch<DocumentSnapshot>(
                        items: accountList,
                        itemAsString: (DocumentSnapshot document) {
                          Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                          return data[
                          'accountName']; // or any other field you want to display
                        },
                        selectedItem: accountList.isNotEmpty &&
                            accountList.any(
                                    (document) => document.id == _selectedAcId)
                            ? accountList.firstWhere(
                                (document) => document.id == _selectedAcId)
                            : null,
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          fit: FlexFit.loose,
                          constraints: BoxConstraints.tightFor(),
                        ),
                        onChanged: (DocumentSnapshot? document) {
                          if (document != null) {
                            setState(() {
                              _selectedAcId = document.id;
                              _selectedAcText = (document.data()
                              as Map<String, dynamic>)['accountName'];
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5.0),

            if (_selectedAcId != null) rptLedger()
          ],
        ),
      ),
    );
  }

  Widget rptLedger() {
    totalDebitPK = 0;
    totalCreditPK = 0;
    totalDebitSR = 0;
    totalCreditSR = 0;
    bfBalancePK = 0;
    bfBalanceSR = 0;

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _vouchers.getAcLedgerStream(
          kUserId, _selectedAcId ?? '', _selectedDateFrom, _selectedDateTo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final documents = snapshot.data ?? [];
        List<DocumentSnapshot> accountsList = documents.cast<DocumentSnapshot>();

        return FutureBuilder<Map<String, String?>>(
          future: _getAccountNames(accountsList),
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
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: constraints.maxWidth / 15,
                      columns: const [
                        DataColumn(label: Text('SR-Dr')),
                        DataColumn(label: Text('SR-Cr')),
                        DataColumn(label: Text('PK-Dr')),
                        DataColumn(label: Text('PK-Cr')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Remarks')),
                      ],
                      rows: [
                        ...accountsList.map((document) {
                          final voucherID = document.id ?? ''; // Use final here to ensure immutability
                          final data = document.data() as Map<String, dynamic>;

                          final drAcId = data['drAcId'] ?? '';
                          final crAcId = data['crAcId'] ?? '';
                          final type = data['type'] ?? '';
                          final dateText = (data['date'] as Timestamp).toDate();
                          final formattedDate = DateFormat('dd MM yy').format(dateText);
                          final remarksText = data['remarks'] ?? '';

                          double debitText, creditText, debitSrText, creditSrText;

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

                          totalDebitPK += creditText;
                          totalCreditPK += debitText;
                          totalDebitSR += creditSrText;
                          totalCreditSR += debitSrText;

                          bfBalancePK = totalDebitPK - totalCreditPK;
                          bfBalanceSR = totalDebitSR - totalCreditSR;

                          // print('Voucher ID: $voucherID');
                          // print('Type: $type');
                          // print('Remarks: $remarksText');

                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat.format(creditSrText),
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat.format(debitSrText),
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat1.format(creditText),
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat1.format(debitText),
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    if (voucherID.isNotEmpty) {
                                      // print('Navigating with Voucher ID: $voucherID');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            if (type == 'CP') {
                                              return VoucherCpvAdd(
                                                docId: voucherID,
                                                type: type,
                                                vDate: dateText,
                                                remarks: remarksText,
                                                drAcId: drAcId,
                                                crAcId: '',
                                                debit: data['debit'],
                                                debitSar: data['debitsar'],
                                                credit: data['credit'],
                                                creditSar: data['creditsar'],
                                              );
                                            } else if (type == 'CR') {
                                              return VoucherCrvAdd(
                                                docId: voucherID,
                                                type: type,
                                                vDate: dateText,
                                                remarks: remarksText,
                                                drAcId: '',
                                                crAcId: crAcId,
                                                debit: data['debit'],
                                                debitSar: data['debitsar'],
                                                credit: data['credit'],
                                                creditSar: data['creditsar'],
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
                                                debitSar: data['debitsar'],
                                                credit: data['credit'],
                                                creditSar: data['creditsar'],
                                              );
                                            }
                                            return const SizedBox.shrink(); // fallback if no type matches
                                          },
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(formattedDate),
                                  ),
                                ),
                              ),
                              DataCell(Text(remarksText)),
                            ],
                          );
                        }),

                        // Add the totals row
                        DataRow(cells: [
                          DataCell(
                            Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(totalDebitSR),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(totalCreditSR),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat2.format(totalDebitPK),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat2.format(totalCreditPK),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const DataCell(
                            Text(
                              'Totals',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const DataCell(Text('')),
                        ]),

                        // Add the B/F Balance row
                        DataRow(cells: [
                          const DataCell(Text('')),
                          DataCell(
                            Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(bfBalanceSR),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                          ),
                          const DataCell(Text('')),
                          DataCell(
                            Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat2.format(bfBalancePK),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                          ),
                          const DataCell(
                            Text(
                              'Balance',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                          const DataCell(Text('')),
                        ]),
                      ],
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
      List<DocumentSnapshot> accountsList) async {
    Map<String, String?> accountNames = {};
    // for (var document in accountsList) {
    //   String drAcId = (document.data() as Map<String, dynamic>)['drAcId'] ?? '';
    //   if (drAcId.isNotEmpty) {
    //     // DocumentSnapshot accountDoc = await _accounts.getAccountById(drAcId);
    //     // accountNames[drAcId] = accountDoc.get('accountName');
    //     accountNames[drAcId] = 'QAISER SHAMEER';
    //   }
    // }
    accountNames['drAcId'] =
    'QAISER SHAMEER'; // FOR UN-COMMIT ABOVE THEN REMOVE THIS LINE
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
          .getCashBookStream(kUserId, [kCRV, kCPV], null, null)
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
                // pw.Text('Ledger: $_selectedAcText',
                pw.Text('Account Ledger',
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
                    ..._getPdfTableData(accountsList, accountNames).map((row) {
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
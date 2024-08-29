import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:dropdown_search/dropdown_search.dart';

import 'package:chat_wp/themes/const.dart';
import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/services/accounts/ac_voucher_service.dart';
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
  final NumberFormat _numberFormat = NumberFormat('#,##0.00');

  final List<String> _accountType = <String>[
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
        title: const Text('Account Ledger'),
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            // onPressed: _printPdf,
            onPressed: (){},
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

            const SizedBox(height: 5.0),

            // Account Data COMBO
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

                      List<DocumentSnapshot> accountList = snapshot.data?.docs ?? [];

                      return DropdownSearch<DocumentSnapshot>(
                        items: accountList,
                        itemAsString: (DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          return data['accountName']; // or any other field you want to display
                        },
                        selectedItem: accountList.firstWhere(
                              (document) => document.id == _selectedAcId,
                          // orElse: () => {},
                        ),
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          fit: FlexFit.loose,
                          constraints: BoxConstraints.tightFor(),
                        ),
                        onChanged: (DocumentSnapshot? document) {
                          if (document != null) {
                            setState(() {
                              _selectedAcId = document.id;
                              _selectedAcText = (document.data() as Map<String, dynamic>)['accountName'];
                            });
                          }
                        },
                      );


                      List<DropdownMenuItem<String>> dropdownItems =
                        accountList.map((document) {String docID = document.id;
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                        _selectedAcText = data['accountName'];

                        return DropdownMenuItem<String>(
                          value: docID,
                          child: Text(
                            _selectedAcText!,
                            style: const TextStyle(color: Colors.teal),
                          ),
                        );
                      }).toList();

                      String? initialAccount = dropdownItems.isNotEmpty ? dropdownItems[0].value : null;

                      // Ensure _selectedAccount is valid or fallback to initialAccount
                      String? currentAccount = dropdownItems
                              .any((item) => item.value == _selectedAcId)
                          ? _selectedAcId: initialAccount;


                      // return DropdownButtonFormField<String>(
                      //   value: currentAccount,
                      //   items: dropdownItems,
                      //   hint: const Text(
                      //     'Select Account',
                      //     style: TextStyle(color: Colors.teal),
                      //   ),
                      //   isExpanded: true,
                      //   onChanged: (accountValue) {
                      //     setState(() {
                      //       _selectedAcId = accountValue;
                      //       // _showData = true;
                      //     });
                      //   },
                      //   validator: (value) {
                      //     if (value == null || value == '') {
                      //       return 'Please select a valid account';
                      //     }
                      //     if (_selectedAcId == null ||
                      //         _selectedAcId == '') {
                      //       return 'Please select a valid account';
                      //     }
                      //     return null;
                      //   },
                      // );

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
      stream: _vouchers.getAcLedgerStream(kUserId, _selectedAcId ?? '', _selectedDateFrom, _selectedDateTo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final documents = snapshot.data ?? [];
        List<DocumentSnapshot> customerList = documents.cast<DocumentSnapshot>();

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
                        ...customerList.map((document) {
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;

                          String drAcId = data['drAcId'] ?? '';
                          String crAcId = data['crAcId'] ?? '';
                          String type = data['type'] ?? '';
                          DateTime dateText =(data['date'] as Timestamp).toDate();
                          String formattedDate = DateFormat('dd MM yy').format(dateText);
                          String remarksText = data['remarks'] ?? '';

                          // String? drAcName = accountNames[drAcId] ?? '';

                          // Display DR Account if available, otherwise display CR Account
                          // String accountDisplayName = drAcId.isNotEmpty ? drAcName : 'N/A';

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
                          } else  {

                            debitText = (data['credit'] ?? 0.0);
                            creditText = (data['debit'] ?? 0.0);

                            debitSrText = (data['creditsar'] ?? 0.0);
                            creditSrText = (data['debitsar'] ?? 0.0);

                          }

                            totalDebitPK += creditText;
                            totalCreditPK += debitText;
                            totalDebitSR += creditSrText;
                            totalCreditSR += debitSrText;

                          // Calculate B/F Balance
                          bfBalancePK = totalDebitPK - totalCreditPK;
                          bfBalanceSR = totalDebitSR - totalCreditSR;

                          return DataRow(cells: [
                            DataCell(Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(creditSrText),
                                style: const TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            )),
                            DataCell(Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(debitSrText),
                                style: const TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            )),
                            DataCell(Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(creditText),
                                style: const TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            )),
                            DataCell(Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _numberFormat.format(debitText),
                                style: const TextStyle(
                                  // fontWeight: FontWeight.bold,
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
                                color: Colors.red,
                              ),
                            ),
                          )),
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
                          const DataCell(Text(
                            'Totals',
                            style: TextStyle(fontWeight: FontWeight.bold,
                              color: Colors.red,),
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
                                color: Colors.teal,
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
                                color: Colors.teal,
                              ),
                            ),
                          )),
                          const DataCell(Text('Balance',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.teal),)),
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
      List<DocumentSnapshot> customerList) async {
    Map<String, String?> accountNames = {};
    // for (var document in customerList) {
    //   String drAcId = (document.data() as Map<String, dynamic>)['drAcId'] ?? '';
    //   if (drAcId.isNotEmpty) {
    //     // DocumentSnapshot accountDoc = await _accounts.getAccountById(drAcId);
    //     // accountNames[drAcId] = accountDoc.get('accountName');
    //     accountNames[drAcId] = 'QAISER SHAMEER';
    //   }
    // }
    accountNames['drAcId'] = 'QAISER SHAMEER';  // FOR UN-COMMIT ABOVE THEN REMOVE THIS LINE
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
                        _buildBoldCell(_numberFormat.format(totalDebitSR), pw.Alignment.centerRight),
                        _buildBoldCell(_numberFormat.format(totalCreditSR), pw.Alignment.centerRight),
                        _buildBoldCell(_numberFormat.format(totalDebitPK), pw.Alignment.centerRight),
                        _buildBoldCell(_numberFormat.format(totalCreditPK), pw.Alignment.centerRight),
                        pw.SizedBox(), // Empty cell
                        // pw.SizedBox(), // Empty cell
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _buildBoldCell('Balance', pw.Alignment.centerRight),
                        pw.SizedBox(), // Empty cell
                        _buildBoldCell(_numberFormat.format(bfBalanceSR), pw.Alignment.centerRight),
                        pw.SizedBox(), // Empty cell
                        _buildBoldCell(_numberFormat.format(bfBalancePK), pw.Alignment.centerRight),
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
        alignment: alignment,padding: const pw.EdgeInsets.all(8.0),
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
      } else  {

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

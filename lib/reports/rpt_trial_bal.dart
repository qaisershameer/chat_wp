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

  String? _selectedAcId, _selectedAcText, _selectedAcType, _selectedReport;
  // bool _showData = false;

  final List<String> _reportType = <String>[
    'ALL',
    'SAR',
    'PKR',
  ];

  final List<String> _accountType = <String>[
    'ALL',
    'PARTY',
    'PARTY B',
    'ASSETS',
    'LIABILITY',
    'CAPITAL',
    'REVENUE',
    'EXPENSE',
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

  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  DateTime? _selectedDateFrom = DateTime.now();
  DateTime? _selectedDateTo = DateTime.now();

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
        title: const Text('Trial Balance'),
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            // onPressed: _printPdf,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.print),
            // onPressed: _printPdf,
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, bottom: 6.0),
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          children: <Widget>[
            // REPORT TYPE Data COMBO, DATE FROM, DATE TO
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.database,
                  size: 20.0,
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
            // ACCOUNT TYPE Data COMBO
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.moneyBill,
                  size: 20.0,
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
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 12.0,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (typeValue) {
                      setState(() {
                        if (_selectedAcType != typeValue) {
                          typeValue == 'ALL'
                              ? _selectedAcType = null
                              : _selectedAcType = typeValue;
                        }
                      });
                    },
                    value: _selectedAcType,
                    hint: const Text(
                      'Select Type',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5.0),

            if (_selectedReport != null || _selectedAcType != null)
              _getAccounts(),
            // if (_selectedAcType != null) _getAccounts(),
          ],
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> _getAccounts() {
    return StreamBuilder<QuerySnapshot>(
      stream: _selectedAcType != null
          ? _accounts.getAccountsTypeStream(kUserId, _selectedAcType!)
          : _accounts.getAccountsStream(kUserId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<DocumentSnapshot> accountsList = snapshot.data!.docs;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('SR-Dr')),
                  DataColumn(label: Text('SR-Cr')),
                  DataColumn(label: Text('PK-Dr')),
                  DataColumn(label: Text('PK-Cr')),
                  DataColumn(label: Text('Name')),
                ],
                rows: accountsList.map<DataRow>((DocumentSnapshot document) {
                  String accountId = document.id; // Retrieving document ID

                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

                  return DataRow(
                    cells: <DataCell>[
                      DataCell(FutureBuilder<Map<String, double>>(
                        future: calculateLedgerTotals(accountId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData) {
                            return const Text('No data');
                          } else {
                            Map<String, double> totals = snapshot.data!;
                            double totalDebitSr = totals['totalDebitSr'] ?? 0.0;
                            return Text(
                              _numberFormat1.format(totalDebitSr),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            );
                          }
                        },
                      )),
                      DataCell(FutureBuilder<Map<String, double>>(
                        future: calculateLedgerTotals(accountId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData) {
                            return const Text('No data');
                          } else {
                            Map<String, double> totals = snapshot.data!;
                            double totalCreditSr = totals['totalCreditSr'] ?? 0.0;
                            return Text(
                              _numberFormat1.format(totalCreditSr),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            );
                          }
                        },
                      )),
                      DataCell(FutureBuilder<Map<String, double>>(
                        future: calculateLedgerTotals(accountId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData) {
                            return const Text('No data');
                          } else {
                            Map<String, double> totals = snapshot.data!;
                            double totalDebitPk = totals['totalDebitPk'] ?? 0.0;
                            return Text(
                              _numberFormat1.format(totalDebitPk),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            );
                          }
                        },
                      )),
                      DataCell(FutureBuilder<Map<String, double>>(
                        future: calculateLedgerTotals(accountId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData) {
                            return const Text('No data');
                          } else {
                            Map<String, double> totals = snapshot.data!;
                            double totalCreditPk = totals['totalCreditPk'] ?? 0.0;
                            return Text(
                              _numberFormat1.format(totalCreditPk),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            );
                          }
                        },
                      )),
                      DataCell(Text(data['accountName'] ?? '')),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return const Center(child: Text('No account data to display!'));
        }
      },
    );
  }

  Future<Map<String, double>> calculateLedgerTotals(String accountId) async {
    double totalDebitPK = 0.0;
    double totalCreditPK = 0.0;
    double totalDebitSR = 0.0;
    double totalCreditSR = 0.0;

    try {
      // Fetch the documents from the stream
      final snapshot = await _vouchers.getAcTrialBalanceStream(kUserId, _selectedAcId ?? '', _selectedDateFrom, _selectedDateTo).first;

      List<DocumentSnapshot> voucherList = snapshot.cast<DocumentSnapshot>();

      for (var document in voucherList) {
        final data = document.data() as Map<String, dynamic>;
        final drAcId = data['drAcId'] ?? '';
        final crAcId = data['crAcId'] ?? '';
        final type = data['type'] ?? '';

        // print('DrAcID: $drAcId');
        // print('CrAcID: $crAcId');

        double debitText, creditText, debitSrText, creditSrText;

        if (type == 'JV') {
          if (accountId == drAcId) {
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
      }
    } catch (error) {
      // Handle errors if needed
      // print('Error: $error');
    }

    return {
      'totalDebitPk': totalDebitPK,
      'totalCreditPk': totalCreditPK,
      'totalDebitSr': totalDebitSR,
      'totalCreditSr': totalCreditSR,
    };
  }

}

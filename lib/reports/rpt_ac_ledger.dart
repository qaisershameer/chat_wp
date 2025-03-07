import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/services/accounts/ac_voucher_service.dart';

import 'package:chat_wp/pages/accounts/home_page.dart';
import 'package:chat_wp/pages/accounts/voucher_crv_add.dart';
import 'package:chat_wp/pages/accounts/voucher_cpv_add.dart';
import 'package:chat_wp/pages/accounts/voucher_jv_add.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RptAcLedger extends StatefulWidget {
  final String accountId;
  final String accountType;
  const RptAcLedger({super.key, required this.accountId, required this.accountType});

  @override
  State<RptAcLedger> createState() => RptAcLedgerState();
}

class RptAcLedgerState extends State<RptAcLedger> {
  final AccountService _accounts = AccountService();
  final AcVoucherService _vouchers = AcVoucherService();
  // final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  String? _selectedAcId, _selectedAcText, _selectedAcType, _selectedReport;
  // bool _showData = false;

  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  DateTime? _selectedDateFrom = DateTime.now();
  DateTime? _selectedDateTo = DateTime.now();

  // Create a NumberFormat instance for comma-separated numbers
  final NumberFormat _numberFormat = NumberFormat('#,##0');
  final NumberFormat _numberFormat1 = NumberFormat('#,##0.0');
  // final NumberFormat _numberFormat2 = NumberFormat('#,##0.00');

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
    _selectedAcId = widget.accountId;
    _selectedAcType = widget.accountType;
    _selectedReport = 'SAR';
    // _dateFromController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());    // OKAY WORKING but i change below line
    _dateFromController.text = kStartDate; // SESSION START DATE
    _dateToController.text = DateFormat('dd-MMM-yyyy').format(DateTime.now());

    // For Form Load From Variable Default Value Set here
    DateTime now = DateTime.now();
    // getDate(DateTime(now.year, now.month, now.day), 'from'); // OKAY WORKING but i change below line
    getDate(DateTime(now.year, 1, 1), 'from');

    // total fields doing empty 0 blank on load screen
    totalDebitPK = 0;
    totalCreditPK = 0;
    totalDebitSR = 0;
    totalCreditSR = 0;

    bfBalancePK = 0;
    bfBalanceSR = 0;

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
            onPressed: () {
              // navigate to settings page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
            icon: const Icon(
              // Icons.account_balance_rounded,
              Icons.home,
              color: Colors.teal,
            ),
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

      body: Column(
        children: [
          // The form and the ListView
          Expanded(
            child: Form(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                children: <Widget>[
                  // REPORT TYPE Data COMBO
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
                        width: MediaQuery.of(context).size.width / 7.0,
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
                          keyboardType: TextInputType.none,
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _selectDate(context, 'from');
                          },
                          style: const TextStyle(fontSize: 12.0),
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.calendar_month,
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
                          keyboardType: TextInputType.none,
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _selectDate(context, 'to');
                          },
                          style: const TextStyle(fontSize: 12.0),
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.calendar_month,
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

                  // Account Name Data COMBO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _accounts.getAccountsStream(kUserId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
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
                                return data['accountName'];
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
                                    _selectedAcText = (document.data() as Map<String, dynamic>)['accountName'];
                                    _selectedAcType = (document.data() as Map<String, dynamic>)['type'];
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
                  if (_selectedAcId != '') rptLedger(),
                ],
              ),
            ),
          ),

          // The buttons at the bottom of the screen
          Padding(
            // padding: const EdgeInsets.symmetric(horizontal: 15.0),
            // padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),  // Added bottom padding of 15.0
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                // YOU GIVE BUTTON
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                    ),
                    child: const Text(
                      'You Give -',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VoucherCpvAdd(
                            docId: '',
                            type: '',
                            acType: _selectedAcType!,
                            vDate: vDate,
                            remarks: 'Cash Paid.',
                            drAcId: _selectedAcId!,
                            crAcId: '',
                            debit: 0.0,
                            debitSar: 0.0,
                            credit: 0.0,
                            creditSar: 0.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 5.0),
                // YOU GOT BUTTON
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade900,
                    ),
                    child: const Text(
                      'You Got +',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VoucherCrvAdd(
                            docId: '',
                            type: '',
                            acType: _selectedAcType!,
                            vDate: vDate,
                            remarks: 'Cash Received.',
                            drAcId: '',
                            crAcId: _selectedAcId!,
                            debit: 0.0,
                            debitSar: 0.0,
                            credit: 0.0,
                            creditSar: 0.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget rptLedger() {
    // print('A/c Id: $_selectedAcId');

    // Numeric Fields Double Variables
    debitText = 0;
    creditText = 0;
    debitSrText = 0;
    creditSrText = 0;

    // // Calculate totals Double Variables
    // totalDebitPK = 0;
    // totalCreditPK = 0;
    // totalDebitSR = 0;
    // totalCreditSR = 0;
    //
    // // Calculate b/f balances Double Variables
    // bfBalancePK = 0;
    // bfBalanceSR = 0;

    List<DataColumn> myColumns;
    List<int> visibleColumns;

    switch (_selectedReport) {
      case 'ALL':
        myColumns = const [
          DataColumn(label: Text('Date', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Sr-Out', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Sr-In', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Pk-Out', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Pk-In', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('VC', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Remarks', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        ];
        visibleColumns = [0, 1, 2, 3, 4, 5, 6];
        break;
      case 'SAR':
        myColumns = const [
          DataColumn(label: Text('Date', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Sr-Out', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Sr-In', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('VC', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Remarks', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        ];
        visibleColumns = [0, 1, 2, 5, 6];
        break;
      case 'PKR':
        myColumns = const [
          DataColumn(label: Text('Date', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Pk-Out', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Pk-In', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('VC', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Remarks', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        ];
        visibleColumns = [0, 3, 4, 5, 6];
        break;
      default:
        myColumns = const [];
        visibleColumns = [];
        break;
    }

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
        List<DocumentSnapshot> accountsList =
            documents.cast<DocumentSnapshot>();
        // Calculate totals Double Variables
        totalDebitPK = 0;
        totalCreditPK = 0;
        totalDebitSR = 0;
        totalCreditSR = 0;

        // Calculate b/f balances Double Variables
        bfBalancePK = 0;
        bfBalanceSR = 0;

        // First loop through the data to accumulate totals
        for (var document in accountsList) {
          final data = document.data() as Map<String, dynamic>;
          final drAcId = data['drAcId'] ?? '';
          final crAcId = data['crAcId'] ?? '';
          final type = data['type'] ?? '';

          double debitText, creditText, debitSrText, creditSrText;

          // print('Selected_Ledger_Id: $_selectedAcId');
          // print('debit_id: $drAcId');

          if (type == 'JV') {
            if (_selectedAcId == drAcId) {
              debitText = (data['debit'] ?? 0.0);
              debitSrText = (data['debitsar'] ?? 0.0);
              creditText = 0.0;
              creditSrText = 0.0;
            } else {
              debitText = 0.0;
              debitSrText = 0.0;
              creditText = (data['credit'] ?? 0.0);
              creditSrText = (data['creditsar'] ?? 0.0);
            }
          } else {
            debitText = (data['debit'] ?? 0.0);
            debitSrText = (data['debitsar'] ?? 0.0);
            creditText = (data['credit'] ?? 0.0);
            creditSrText = (data['creditsar'] ?? 0.0);
          }

          totalDebitPK += debitText;
          totalCreditPK += creditText;
          totalDebitSR += debitSrText;
          totalCreditSR += creditSrText;
        }

        // Calculate the balances after looping through the data
        bfBalancePK = totalDebitPK - totalCreditPK;
        bfBalanceSR = totalDebitSR - totalCreditSR;

        return FutureBuilder<Map<String, String?>>(
          future: _getAccountNames(accountsList),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (futureSnapshot.hasError) {
              return Center(child: Text('Error: ${futureSnapshot.error}'));
            } else if (futureSnapshot.hasData) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(

                      headingRowColor:WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                        // Return the color you want to use for the highlighted row
                        return Colors.grey.withOpacity(0.5); // Example color with transparency
                      }),

                      border: TableBorder.all(color: Colors.grey),

                      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold,),

                      headingRowHeight: 30.0,
                      dataRowMinHeight: 30.0,
                      dataRowMaxHeight: 35.0,
                      columnSpacing: constraints.maxWidth / 50,

                      columns: myColumns,
                      rows: [

                        // Add the B/F Balances row at the top after heading
                        DataRow(
                            color: WidgetStateProperty.resolveWith<Color>(
                                    (Set<WidgetState> states) {
                                  // Return the color you want to use for the highlighted row
                                  return Colors.yellow.withOpacity(0.25); // Example color with transparency
                                }),
                            cells: [
                              if (visibleColumns.contains(0))
                                const DataCell(Text('',)),
                              if (visibleColumns.contains(1))
                                const DataCell(Text('',)),
                              if (visibleColumns.contains(2))
                                DataCell(Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _selectedReport != 'PKR'
                                        ? _numberFormat.format(bfBalanceSR)
                                        : '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // fontStyle: FontStyle.italic,
                                      color: Colors.blue,
                                    ),
                                  ),
                                )),
                              if (visibleColumns.contains(3))
                                const DataCell(Text('',)),
                              if (visibleColumns.contains(4))
                                DataCell(Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _selectedReport != 'SAR'
                                        ? _numberFormat1.format(bfBalancePK)
                                        : '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // fontStyle: FontStyle.italic,
                                      color: Colors.green,
                                    ),
                                  ),
                                )),
                              if (visibleColumns.contains(5))
                                const DataCell(Text(
                                  ' B/F',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontStyle: FontStyle.italic,
                                    color: Colors.teal,
                                  ),
                                )),
                              if (visibleColumns.contains(6))
                                const DataCell(Text('',)),
                              // if (visibleColumns.contains(6)) const DataCell(Text('')),
                            ]),

                        // Add the totals row at the 2nd top after heading
                        DataRow(
                          color: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                            // Return the color you want to use for the highlighted row
                            return Colors.teal.withOpacity(
                                0.25); // Example color with transparency
                          }),
                          cells: [
                            if (visibleColumns.contains(0))
                              const DataCell(Text('',)),
                            if (visibleColumns.contains(1))
                              DataCell(
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat.format(totalDebitSR),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // fontStyle: FontStyle.italic,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                  ),
                                ),
                              ),
                            if (visibleColumns.contains(2))
                              DataCell(
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat.format(totalCreditSR),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // fontStyle: FontStyle.italic,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                  ),
                                ),
                              ),
                            if (visibleColumns.contains(3))
                              DataCell(
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat1.format(totalDebitPK),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // fontStyle: FontStyle.italic,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                              ),
                            if (visibleColumns.contains(4))
                              DataCell(
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _numberFormat1.format(totalCreditPK),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // fontStyle: FontStyle.italic,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                              ),
                            if (visibleColumns.contains(5))
                              const DataCell(Text(
                                ' Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // fontStyle: FontStyle.italic,
                                  color: Colors.black54,
                                ),
                              )
                              ),
                            if (visibleColumns.contains(6))
                              const DataCell(Text('',)),
                          ],
                        ),

                        ...accountsList.map((document) {
                          final voucherID = document.id;
                          final data = document.data() as Map<String, dynamic>;

                          if (data != null) {
                            final drAcId = data['drAcId'] ?? '';
                            final crAcId = data['crAcId'] ?? '';
                            final type = data['type'] ?? '';
                            final remarksText = data['remarks'] ?? '';
                            final dateText = (data['date'] as Timestamp).toDate();
                            final formattedDate = DateFormat('dd MMM').format(dateText);
                            // final remarks = '$type\n . $remarksText';

                            double debitText, creditText, debitSrText, creditSrText;

                            if (type == 'JV') {
                              if (_selectedAcId == drAcId) {
                                debitText = (data['debit'] ?? 0.0);
                                debitSrText = (data['debitsar'] ?? 0.0);
                                creditText = 0.0;
                                creditSrText = 0.0;
                              } else {
                                debitText = 0.0;
                                debitSrText = 0.0;
                                creditText = (data['credit'] ?? 0.0);
                                creditSrText = (data['creditsar'] ?? 0.0);
                              }

                              // remarksText = data['remarks'] ?? '';

                            } else {

                              debitText = (data['debit'] ?? 0.0);
                              creditText = (data['credit'] ?? 0.0);
                              debitSrText = (data['debitsar'] ?? 0.0);
                              creditSrText = (data['creditsar'] ?? 0.0);

                              // remarksText = data['remarks'] ?? '';

                            }

                            // Returning a valid Detail Record DataRow
                            return DataRow(
                              cells: [
                                if (visibleColumns.contains(0))
                                  DataCell(
                                    GestureDetector(
                                      onTap: () {
                                        if (voucherID.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                // Navigation logic for different voucher types
                                                if (type == 'CP') {
                                                  return VoucherCpvAdd(
                                                    docId: voucherID,
                                                    type: type,
                                                    acType: _selectedAcType!,
                                                    vDate: dateText,
                                                    remarks: remarksText,
                                                    drAcId: drAcId,
                                                    crAcId: '',
                                                    debit: data['debit'],
                                                    debitSar: data['debitsar'],
                                                    credit: data['credit'],
                                                    creditSar:
                                                        data['creditsar'],
                                                  );
                                                } else if (type == 'CR') {
                                                  return VoucherCrvAdd(
                                                    docId: voucherID,
                                                    type: type,
                                                    acType: _selectedAcType!,
                                                    vDate: dateText,
                                                    remarks: remarksText,
                                                    drAcId: '',
                                                    crAcId: crAcId,
                                                    debit: data['debit'],
                                                    debitSar: data['debitsar'],
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
                                                    debitSar: data['debitsar'],
                                                    credit: data['credit'],
                                                    creditSar: data['creditsar'],
                                                  );
                                                }
                                                return const SizedBox
                                                    .shrink(); // fallback in case no type matches
                                              },
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(formattedDate, style: const TextStyle(
                                          color: Colors.blueGrey,
                                        )),
                                      ),
                                    ),
                                  ),
                                if (visibleColumns.contains(1))
                                  DataCell(
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _numberFormat.format(debitSrText),
                                        style:
                                            const TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                if (visibleColumns.contains(2))
                                  DataCell(
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _numberFormat.format(creditSrText),
                                        style:
                                            const TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                if (visibleColumns.contains(3))
                                  DataCell(
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _numberFormat1.format(debitText),
                                        style: const TextStyle(
                                            color: Colors.green),
                                      ),
                                    ),
                                  ),
                                if (visibleColumns.contains(4))
                                  DataCell(
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _numberFormat1.format(creditText),
                                        style: const TextStyle(
                                            color: Colors.green),
                                      ),
                                    ),
                                  ),
                                if (visibleColumns.contains(5))
                                  DataCell(Container(
                                    alignment: Alignment.center,
                                    child: Text(type, style: const TextStyle(
                                        color: Colors.red),),
                                  )),
                                if (visibleColumns.contains(6))
                                  DataCell(Text(remarksText)),
                              ],
                            );
                          } else {
                            // Handle case when `data` is null, returning an empty DataRow or skipping the row
                            return const DataRow(
                                cells: []); // Or handle differently if necessary
                          }
                        }), // Convert to list here
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

  // PDF CODING STARTING FROM THIS POINT FORWARD ///////////////////////////////////////
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
      // String crAcId = dataRow['crAcId'] ?? '';
      DateTime dateText = (dataRow['date'] as Timestamp).toDate();
      String formattedDate = DateFormat('dd MM yy').format(dateText);
      String remarksText = dataRow['remarks'] ?? '';
      String type = dataRow['type'] ?? '';

      creditText = (dataRow['credit'] ?? 0.0);
      debitText = (dataRow['debit'] ?? 0.0);
      creditSrText = (dataRow['creditsar'] ?? 0.0);
      debitSrText = (dataRow['debitsar'] ?? 0.0);

      // String? drAcName = accountNames[drAcId] ?? '';
      // String? crAcName = accountNames[crAcId] ?? '';

      // String accountDisplayName = drAcId.isNotEmpty ? drAcName : crAcName;

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

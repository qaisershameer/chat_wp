import 'package:chat_wp/reports/rpt_ac_ledger.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_wp/themes/const.dart';
import 'package:chat_wp/services/accounts/area_service.dart';
import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/services/accounts/ac_voucher_service.dart';

class RptTrialBal extends StatefulWidget {
  const RptTrialBal({super.key});

  @override
  State<RptTrialBal> createState() => RptTrialBalState();
}

class RptTrialBalState extends State<RptTrialBal> {
  final AreaService _areas = AreaService();
  final AccountService _accounts = AccountService();
  final AcVoucherService _vouchers = AcVoucherService();
  // final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  String? _selectedAcId, _selectedReport, _selectedAcType, _selectedArea;
  // bool _showData = false;

  final List<String> _reportType = <String>[
    'ALL',
    'SAR',
    'PKR',
  ];

  final List<String> _accountType = <String>[
    'ALL',
    'PARTY',
    'CUSTOMER',
    'SUPPLIER',
    'BANK',
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
  // final NumberFormat _numberFormat2 = NumberFormat('#,##0.00');

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
    _selectedReport = 'SAR';
    _selectedAcType = 'CUSTOMER';

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
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.moneyBill,
                  size: 20.0,
                  color: Colors.teal,
                ),

                const SizedBox(width: 10.0),

                // ACCOUNT TYPE Data COMBO
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
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
                      'Account Type',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 5.0),

                const Icon(
                  FontAwesomeIcons.chartArea,
                  size: 20.0,
                  color: Colors.teal,
                ),

                const SizedBox(width: 10.0),

                // Area Data Combo
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _areas.getAreasStream(kUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      List<DocumentSnapshot> areaList = snapshot.data?.docs ?? [];
                      List<DropdownMenuItem<String>> dropdownItems = areaList.map((document) {
                        String docID = document.id;
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        String areaText = data['area_name'];

                        return DropdownMenuItem<String>(
                          value: docID,
                          child: Text(
                            areaText,
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 12.0,
                            ),
                          ),
                        );
                      }).toList();

                      // Add "ALL" option at index 0
                      dropdownItems.insert(
                        0,
                        const DropdownMenuItem<String>(
                          value: 'ALL',
                          child: Text(
                            'ALL',
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      );

                      String? initialArea = dropdownItems.isNotEmpty
                          ? dropdownItems[0].value
                          : null;

                      // Ensure _selectedArea is valid or fallback to initialArea
                      String? currentArea = dropdownItems.any((item) => item.value == _selectedArea)
                          ? _selectedArea
                          : initialArea;

                      return DropdownButtonFormField<String>(
                        value: currentArea,
                        items: dropdownItems,
                        hint: const Text(
                          'Select Area',
                          style: TextStyle(color: Colors.teal),
                        ),
                        isExpanded: false,
                        onChanged: (areaValue) {
                          setState(() {
                            _selectedArea = areaValue;
                          });
                        },
                      );
                    },
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

    List<DataColumn> myColumns;
    List<int> visibleColumns;

    switch (_selectedReport) {
      case 'ALL':
        myColumns = const [
          DataColumn(label: Text('Sr-Out')),
          DataColumn(label: Text('Sr-In')),
          DataColumn(label: Text('Pk-Out')),
          DataColumn(label: Text('Pk-In')),
          DataColumn(label: Text('Name')),
        ];
        visibleColumns = [0, 1, 2, 3, 4];
        break;
      case 'SAR':
        myColumns = const [
          DataColumn(label: Text('SR-Dr')),
          DataColumn(label: Text('SR-Cr')),
          DataColumn(label: Text('Account')),
        ];
        visibleColumns = [0, 1, 4];
        break;
      case 'PKR':
        myColumns = const [
          DataColumn(label: Text('PK-Dr')),
          DataColumn(label: Text('PK-Cr')),
          DataColumn(label: Text('Account')),
        ];
        visibleColumns = [2, 3, 4];
        break;
      default:
        myColumns = const [];
        visibleColumns = [];
        break;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _selectedAcType != null || _selectedArea != null
      // ? _accounts.getAccountsTypeAreaStream(kUserId, _selectedAcType!)
          ? _accounts.getAccountsTypeAreaStream(kUserId, _selectedAcType ?? 'ALL', _selectedArea ?? 'ALL')
          : _accounts.getAccountsStream(kUserId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {

          List<DocumentSnapshot> accountsList = snapshot.data!.docs;

          // Create a Future for each row to fetch ledger totals
          Future<List<Map<String, double>>> fetchLedgerTotals(
              List<String> accountIds) async {
            List<Map<String, double>> results = [];
            for (var id in accountIds) {
              results.add(await calculateLedgerTotals(id));
            }
            return results;
          }

          List<String> accountIds = accountsList.map((doc) => doc.id).toList();

          return FutureBuilder<List<Map<String, double>>>(
            future: fetchLedgerTotals(accountIds),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              } else {

                List<Map<String, double>> ledgerTotalsList = snapshot.data!;

                // Calculate totals for all columns
                double totalDebitSr = 0.0;
                double totalCreditSr = 0.0;
                double totalDebitPk = 0.0;
                double totalCreditPk = 0.0;

                double displayBalanceSr = 0.0;
                double displayBalancePk = 0.0;

                List<DataRow> dataRows = accountsList.asMap().entries.map<DataRow>((entry) {
                  int index = entry.key;
                  DocumentSnapshot document = entry.value;

                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                  final _selectedAcId = document.id;

                  Map<String, double> totals = ledgerTotalsList[index];

                  double totalDebitSrRow = totals['totalDebitSr'] ?? 0.0;
                  double totalCreditSrRow = totals['totalCreditSr'] ?? 0.0;
                  double totalDebitPkRow = totals['totalDebitPk'] ?? 0.0;
                  double totalCreditPkRow = totals['totalCreditPk'] ?? 0.0;

                  double bfSAR = totalDebitSrRow - totalCreditSrRow;
                  double bfPKR = totalDebitPkRow - totalCreditPkRow;

                  double displayDebitSr = bfSAR > 0 ? bfSAR : 0;
                  double displayCreditSr = bfSAR < 0 ? bfSAR : 0;
                  double displayDebitPk = bfPKR > 0 ? bfPKR : 0;
                  double displayCreditPk = bfPKR < 0 ? bfPKR : 0;

                  // Accumulate totals
                  totalDebitSr += displayDebitSr;
                  totalCreditSr += displayCreditSr;
                  totalDebitPk += displayDebitPk;
                  totalCreditPk += displayCreditPk;

                  // b/f totals
                  displayBalanceSr = totalDebitSr + totalCreditSr;
                  displayBalancePk = totalDebitPk + totalCreditPk;

                  return DataRow(

                    // Get Selected Row accountId to view ledger
                    // selected: _selectedAcId == currentAcId,
                    // onSelectChanged: (isSelected) {
                    //   if (isSelected != null && isSelected) {
                    //     setState(() {
                    //       _selectedAcId = currentAcId;
                    //     });
                    //   }
                    // },

                    cells: <DataCell>[
                      if (visibleColumns.contains(0))
                        DataCell(Text(
                          _numberFormat.format(displayDebitSr),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        )),
                      if (visibleColumns.contains(1))
                        DataCell(Text(
                          _numberFormat.format(displayCreditSr),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        )),
                      if (visibleColumns.contains(2))
                        DataCell(Text(
                          _numberFormat1.format(displayDebitPk),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        )),
                      if (visibleColumns.contains(3))
                        DataCell(Text(
                          _numberFormat1.format(displayCreditPk),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        )),
                      if (visibleColumns.contains(4))
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              // print('Navigating to VoucherCpvAdd with docId: $voucherID');
                              try {
                                if (_selectedAcId!= '') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) {
                                          return RptAcLedger(
                                            accountId: _selectedAcId,
                                          );
                                        }
                                      // return const SizedBox.shrink(); // Fallback if no type matches
                                    ),
                                  );
                                }
                              } catch (e) {
                                // print('Error during navigation: $e');
                              }
                            },
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(data['accountName'] ?? '')),
                          ),
                        ),
                      // DataCell(Text(data['accountName'] ?? '')),
                    ],
                  );
                }).toList();

                // Add the total row
                dataRows.add(DataRow(
                  cells: <DataCell>[
                    if (visibleColumns.contains(0))
                      DataCell(Text(
                        _numberFormat.format(totalDebitSr),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      )),
                    if (visibleColumns.contains(1))
                      DataCell(Text(
                        _numberFormat.format(totalCreditSr),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      )),
                    if (visibleColumns.contains(2))
                      DataCell(Text(
                        _numberFormat1.format(totalDebitPk),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      )),
                    if (visibleColumns.contains(3))
                      DataCell(Text(
                        _numberFormat1.format(totalCreditPk),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      )),
                    if (visibleColumns.contains(4))
                      const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red,))),
                  ],
                ));

                // Add the b/f balances row
                dataRows.add(DataRow(

                  cells: <DataCell>[

                    if (visibleColumns.contains(0))
                      const DataCell(Text(''),),

                    if (visibleColumns.contains(1))
                      DataCell(Text(
                        _numberFormat.format(displayBalanceSr),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      )),

                    if (visibleColumns.contains(2))
                      const DataCell(Text(''),),

                    if (visibleColumns.contains(3))
                      DataCell(Text(
                        _numberFormat1.format(displayBalancePk),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      )),

                    if (visibleColumns.contains(4))
                      const DataCell(Text('Balance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal,))),
                  ],
                ));

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: myColumns,
                      rows: dataRows,
                    ),
                  ),
                );
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

  Future<Map<String, double>> calculateLedgerTotals(String accountId) async {
    double totalDebitPK = 0.0;
    double totalCreditPK = 0.0;
    double totalDebitSR = 0.0;
    double totalCreditSR = 0.0;

    try {
      // Fetch the documents from the stream
      final snapshot = await _vouchers
          .getAcTrialBalanceStream(
          kUserId, accountId, _selectedDateFrom, _selectedDateTo)
          .first;

      List<DocumentSnapshot> voucherList = snapshot.cast<DocumentSnapshot>();

      for (var document in voucherList) {
        final data = document.data() as Map<String, dynamic>;
        final drAcId = data['drAcId'] ?? '';
        // final crAcId = data['crAcId'] ?? '';
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
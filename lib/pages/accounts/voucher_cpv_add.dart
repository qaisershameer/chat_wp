import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/services/accounts/ac_voucher_service.dart';

class VoucherCpvAdd extends StatefulWidget {
  final String docId;
  final String type;
  final DateTime vDate;
  final String remarks;

  final String drAcId;
  final String craAcId;
  final double debit;
  final double debitSar;
  final double credit;
  final double creditSar;

  const VoucherCpvAdd({
    super.key,
    required this.docId,
    required this.type,
    required this.vDate,
    required this.remarks,
    required this.drAcId,
    required this.craAcId,
    required this.debit,
    required this.debitSar,
    required this.credit,
    required this.creditSar,
  });

  @override
  State<VoucherCpvAdd> createState() => VoucherCpvAddState();
}

class VoucherCpvAddState extends State<VoucherCpvAdd> {
  final AccountService _accounts = AccountService();
  final AcVoucherService _voucher = AcVoucherService();

  String? _voucherId, _selectedAccount;

  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _pkrController = TextEditingController();
  final TextEditingController _sarController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MMM-yyyy').format(pickedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with data from the previous screen
    _voucherId = widget.docId;
    _dateController.text = DateFormat('dd-MMM-yyyy').format(widget.vDate);
    _remarksController.text = widget.remarks;
    _selectedAccount = widget.drAcId;
    _pkrController.text = widget.debit.toString();
    _sarController.text = widget.debitSar.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.bars,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        title: Container(
          alignment: Alignment.center,
          child: const Text(
            'Cash Payment',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: const <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.coins,
              color: Colors.white,
              size: 20.0,
            ),
            onPressed: null,
          ),
        ],
      ),
      body: Form(
        key: _formKeyValue,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          children: [
            // Date Text Field
            TextFormField(
              controller: _dateController,
              keyboardType: TextInputType.none, // Disable keyboard input
              onTap: () {
                FocusScope.of(context)
                    .requestFocus(FocusNode()); // Hide keyboard
                _selectDate(context); // Show date picker
              },
              decoration: const InputDecoration(
                icon: Icon(
                  Icons.calendar_month, // Changed to a Flutter icon
                  color: Colors.teal,
                ),
                hintText: 'Select Date',
                labelText: 'Date',
                labelStyle:
                    TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid date';
                }
                return null;
              },
            ),

            const SizedBox(height: 20.0),

            // Account Data COMBO
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.circleUser,
                  size: 25.0,
                  color: Colors.teal,
                ),
                const SizedBox(width: 20.0),
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

                      List<DocumentSnapshot> areaList =
                          snapshot.data?.docs ?? [];
                      List<DropdownMenuItem<String>> dropdownItems =
                          areaList.map((document) {
                        String docID = document.id;
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String areaText = data['accountName'];

                        return DropdownMenuItem<String>(
                          value: docID,
                          child: Text(
                            areaText,
                            style: const TextStyle(color: Colors.teal),
                          ),
                        );
                      }).toList();

                      String? initialAccount = dropdownItems.isNotEmpty
                          ? dropdownItems[0].value
                          : null;

                      // Ensure _selectedAccount is valid or fallback to initialAccount
                      String? currentAccount = dropdownItems
                              .any((item) => item.value == _selectedAccount)
                          ? _selectedAccount
                          : initialAccount;

                      return DropdownButtonFormField<String>(
                        value: currentAccount,
                        items: dropdownItems,
                        hint: const Text(
                          'Select Account',
                          style: TextStyle(color: Colors.teal),
                        ),
                        isExpanded: true,
                        onChanged: (accountValue) {
                          setState(() {
                            _selectedAccount = accountValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a valid account';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // PKR Amount Number Text Field
            TextFormField(
              controller: _pkrController,
              decoration: const InputDecoration(
                icon: Icon(
                  FontAwesomeIcons.moneyBill,
                  color: Colors.teal,
                ),
                hintText: 'Enter PKR Amount',
                labelText: 'PKR Amount',
                labelStyle:
                    TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid PKR amount';
                } else if (!RegExp(r'^\+?[0-9.]').hasMatch(value)) {
                  return 'Please enter a valid PKR Amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 20.0),

            // SAR Number Text Field
            TextFormField(
              controller: _sarController,
              decoration: const InputDecoration(
                icon: Icon(
                  FontAwesomeIcons.moneyBillTransfer,
                  color: Colors.teal,
                ),
                hintText: 'Enter SAR amount',
                labelText: 'SAR Amount',
                labelStyle:
                    TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid SAR amount';
                } else if (!RegExp(r'^\+?[0-9.]').hasMatch(value)) {
                  return 'Please enter a valid SAR amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 20.0),

            // Remarks Multi Line Text Field
            TextFormField(
              controller: _remarksController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(
                  FontAwesomeIcons.pencil,
                  color: Colors.teal,
                ),
                hintText: 'Enter Voucher Remarks',
                labelText: 'Remarks',
                labelStyle:
                    TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your voucher remarks';
                }
                return null;
              },
            ),

            const SizedBox(height: 20.0),

            // FORM SAVE
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKeyValue.currentState!.validate()) {
                        // print(_voucherId);
                        // print(kCPV);
                        // print(_dateController.text);
                        // print(_remarksController.text);
                        // print(_selectedAccount);
                        // print(_pkrController.text);
                        // print(_sarController.text);
                        // print(kUserId);

                        // Convert date string to DateTime
                        DateTime date = DateFormat('dd-MMM-yyyy').parse(_dateController.text);

                        // Convert string to double
                        double pkrAmount = double.tryParse(_pkrController.text) ?? 0.0;
                        double sarAmount = double.tryParse(_sarController.text) ?? 0.0;

                        if (_voucherId == null || _voucherId == '') {
                          _voucher.addVoucher(
                              kCPV,
                              date,
                              _remarksController.text,
                              _selectedAccount!,
                              '',
                              pkrAmount,
                              sarAmount,
                              0,
                              0,
                              kUserId);
                        } else {
                          _voucher.updateVoucher(
                              _voucherId,
                              kCPV,
                              date,
                              _remarksController.text,
                              _selectedAccount!,
                              '',
                              pkrAmount,
                              sarAmount,
                              0,
                              0,
                              kUserId);
                        }

                        const snackBar = SnackBar(
                          content: Text(
                            'Cash Payment saved successfully!',
                            style: TextStyle(color: Colors.teal),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        _dateController.clear();
                        _pkrController.clear();
                        _remarksController.clear();

                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),

                  // Cancel Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

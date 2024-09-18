import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/services/accounts/ac_voucher_service.dart';

class VoucherJvAdd extends StatefulWidget {
  final String docId;
  final String type;
  final DateTime vDate;
  final String remarks;

  final String drAcId;
  final String crAcId;
  final double debit;
  final double debitSar;
  final double credit;
  final double creditSar;

  const VoucherJvAdd({
    super.key,
    required this.docId,
    required this.type,
    required this.vDate,
    required this.remarks,
    required this.drAcId,
    required this.crAcId,
    required this.debit,
    required this.debitSar,
    required this.credit,
    required this.creditSar,
  });

  @override
  State<VoucherJvAdd> createState() => VoucherJvAddState();
}

class VoucherJvAddState extends State<VoucherJvAdd> {
  final AccountService _accounts = AccountService();
  final AcVoucherService _voucher = AcVoucherService();

  String? _voucherId, _selectedAccountDrId, _selectedAccountCrId;
  String? _selectedAccountDrText, _selectedAccountCrText;

  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _pkrDrController = TextEditingController();
  final TextEditingController _pkrCrController = TextEditingController();
  final TextEditingController _sarDrController = TextEditingController();
  final TextEditingController _sarCrController = TextEditingController();
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
    _selectedAccountDrId = widget.drAcId;
    _selectedAccountCrId = widget.crAcId;
    _pkrDrController.text = widget.debit.toString();
    _pkrCrController.text = widget.credit.toString();
    _sarDrController.text = widget.debitSar.toString();
    _sarCrController.text = widget.creditSar.toString();
  }

  void _deleteVoucherBox(BuildContext context, String docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete JV'),
        content: const Text('Are you sure you want to delete this JV Voucher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _voucher.deleteVoucher(docID);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('JV Voucher deleted!'),
                ),
              );
            },
            child: const Text('Delete JV'),
          ),
        ],
      ),
    );
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
            'Journal Voucher',
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
                FocusScope.of(context).requestFocus(FocusNode()); // Hide keyboard
                _selectDate(context); // Show date picker
              },
              decoration: const InputDecoration(
                icon: Icon(
                  Icons.calendar_month, // Changed to a Flutter icon
                  color: Colors.teal,
                ),
                hintText: 'Select Date',
                labelText: 'Date',
                labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid date';
                }
                return null;
              },
            ),

            const SizedBox(height: 10.0),

            // Credit Account Data COMBO
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.copyright,
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

                      List<DocumentSnapshot> accountList = snapshot.data?.docs ?? [];

                      return DropdownSearch<DocumentSnapshot>(
                        items: accountList,
                        itemAsString: (DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          return data['accountName']; // or any other field you want to display
                        },
                        selectedItem: accountList.isNotEmpty && accountList.any((document) => document.id == _selectedAccountCrId)
                            ? accountList.firstWhere((document) => document.id == _selectedAccountCrId)
                            : null,
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          fit: FlexFit.loose,
                          constraints: BoxConstraints.tightFor(),
                        ),
                        onChanged: (DocumentSnapshot? document) {
                          if (document != null) {
                            setState(() {
                              _selectedAccountCrId = document.id;
                              _selectedAccountCrText = (document.data() as Map<String, dynamic>)['accountName'];
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            // Debit Account Data COMBO
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

                      List<DocumentSnapshot> accountList = snapshot.data?.docs ?? [];

                      return DropdownSearch<DocumentSnapshot>(
                        items: accountList,
                        itemAsString: (DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          return data['accountName']; // or any other field you want to display
                        },
                        selectedItem: accountList.isNotEmpty && accountList.any((document) => document.id == _selectedAccountDrId)
                            ? accountList.firstWhere((document) => document.id == _selectedAccountDrId)
                            : null,
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          fit: FlexFit.loose,
                          constraints: BoxConstraints.tightFor(),
                        ),
                        onChanged: (DocumentSnapshot? document) {
                          if (document != null) {
                            setState(() {
                              _selectedAccountDrId = document.id;
                              _selectedAccountDrText = (document.data() as Map<String, dynamic>)['accountName'];
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            // SAR Debit and Credit Amounts Row
            Row(
              children: [

                Expanded(
                  child: TextFormField(
                    controller: _sarCrController,
                    onTap: () => _sarCrController.selection = TextSelection(baseOffset: 0, extentOffset: _sarCrController.value.text.length),
                    decoration: const InputDecoration(
                      icon: Icon(
                        FontAwesomeIcons.moneyBillTransfer,
                        color: Colors.teal,
                      ),
                      hintText: 'Enter SAR Credit',
                      labelText: 'SAR Credit',
                      labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid SAR Credit';
                      } else if (!RegExp(r'^\+?[0-9.]').hasMatch(value)) {
                        return 'Please enter a valid SAR Credit';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 10.0),

                Expanded(
                  child: TextFormField(
                    controller: _sarDrController,
                    onTap: () => _sarDrController.selection = TextSelection(baseOffset: 0, extentOffset: _sarDrController.value.text.length),
                    decoration: const InputDecoration(
                      icon: Icon(
                        FontAwesomeIcons.moneyBillTransfer,
                        color: Colors.teal,
                      ),
                      hintText: 'Enter SAR Debit',
                      labelText: 'SAR Debit',
                      labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid SAR Debit';
                      } else if (!RegExp(r'^\+?[0-9.]').hasMatch(value)) {
                        return 'Please enter a valid SAR Debit';
                      }
                      return null;
                    },
                  ),),

              ],
            ),

            const SizedBox(height: 10.0),

            // PKR Debit and Credit Amounts Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pkrCrController,
                    onTap: () => _pkrCrController.selection = TextSelection(baseOffset: 0, extentOffset: _pkrCrController.value.text.length),
                    decoration: const InputDecoration(
                      icon: Icon(
                        FontAwesomeIcons.moneyBill,
                        color: Colors.teal,
                      ),
                      hintText: 'Enter PKR Credit',
                      labelText: 'PKR Credit',
                      labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid PKR Credit';
                      } else if (!RegExp(r'^\+?[0-9.]').hasMatch(value)) {
                        return 'Please enter a valid PKR Credit100';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10.0),

                Expanded(
                  child: TextFormField(
                    controller: _pkrDrController,
                    onTap: () => _pkrDrController.selection = TextSelection(baseOffset: 0, extentOffset: _pkrDrController.value.text.length),
                    decoration: const InputDecoration(
                      icon: Icon(
                        FontAwesomeIcons.moneyBill,
                        color: Colors.teal,
                      ),
                      hintText: 'Enter PKR Debit',
                      labelText: 'PKR Debit',
                      labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid PKR Debit';
                      } else if (!RegExp(r'^\+?[0-9.]').hasMatch(value)) {
                        return 'Please enter a valid PKR';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            // Remarks Multi Line Text Field
            TextFormField(
              controller: _remarksController,
              onTap: () => _remarksController.selection = TextSelection(baseOffset: 0, extentOffset: _remarksController.value.text.length),
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(
                  FontAwesomeIcons.pencil,
                  color: Colors.teal,
                ),
                hintText: 'Enter Voucher Remarks',
                labelText: 'Remarks',
                labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your voucher remarks';
                }
                return null;
              },
            ),

            const SizedBox(height: 10.0),

            // FORM SAVE
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKeyValue.currentState!.validate()) {
                        // Convert date string to DateTime
                        DateTime date = DateFormat('dd-MMM-yyyy').parse(_dateController.text);

                        // Convert string to double
                        double pkrDrAmount = double.tryParse(_pkrDrController.text) ?? 0.0;
                        double pkrCrAmount = double.tryParse(_pkrCrController.text) ?? 0.0;
                        double sarDrAmount = double.tryParse(_sarDrController.text) ?? 0.0;
                        double sarCrAmount = double.tryParse(_sarCrController.text) ?? 0.0;

                        if (_voucherId == null || _voucherId == '') {
                          _voucher.addVoucher(
                            kJV,
                            date,
                            _remarksController.text,
                            _selectedAccountDrId!,
                            _selectedAccountCrId!,
                            pkrDrAmount,
                            sarDrAmount,
                            pkrCrAmount,
                            sarCrAmount,
                            kUserId,
                          );
                        } else {
                          _voucher.updateVoucher(
                            _voucherId,
                            kJV,
                            date,
                            _remarksController.text,
                            _selectedAccountDrId!,
                            _selectedAccountCrId!,
                            pkrDrAmount,
                            sarDrAmount,
                            pkrCrAmount,
                            sarCrAmount,
                            kUserId,
                          );
                        }

                        const snackBar = SnackBar(
                          content: Text(
                            'Journal Voucher saved successfully!',
                            style: TextStyle(color: Colors.teal),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        _dateController.clear();
                        _pkrDrController.clear();
                        _pkrCrController.clear();
                        _sarDrController.clear();
                        _sarCrController.clear();
                        _remarksController.clear();

                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),

                  // Delete Button
                  ElevatedButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      if (_voucherId != null && _voucherId != '') {
                        _deleteVoucherBox(context, _voucherId!);
                      }
                    },
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

            const SizedBox(height: 10.0),
          ],
        ),
      ),

    );
  }
}

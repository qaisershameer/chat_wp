import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chat_wp/services/accounts/area_service.dart';
import 'package:chat_wp/services/accounts/currency_service.dart';
import 'package:chat_wp/services/accounts/account_service.dart';

class AccountAdd extends StatefulWidget {
  final String docId;
  final String name;
  final String phone;
  final String email;
  final String type;
  final String currency;
  final String area;

  const AccountAdd(
      {super.key,
      required this.docId,
      required this.name,
      required this.phone,
      required this.email,
      required this.type,
      required this.currency,
      required this.area});

  @override
  State<AccountAdd> createState() => _AccountAddState();
}

class _AccountAddState extends State<AccountAdd> {
  final AreaService _areas = AreaService();
  final AccountService _accounts = AccountService();
  final CurrencyService _currency = CurrencyService();

  String? _accountId, _selectedType, _selectedCurrency, _selectedArea;

  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  final List<String> _accountType = <String>[
    'ASSETS',
    'LIABILITIES',
    'REVENUES',
    'EXPENSES',
    'PARTIES',
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text controller with the data from the previous screen
    _accountId = widget.docId;
    _nameController.text = widget.name;
    _phoneController.text = widget.phone;
    _emailController.text = widget.email;

    _selectedType = widget.type;
    // print(_selectedType);
    _selectedCurrency = widget.currency;
    _selectedArea = widget.area;
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
            'Customer Details',
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
            // Name Text Field
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(
                  FontAwesomeIcons.circleUser,
                  color: Colors.teal,
                ),
                hintText: 'Enter your name',
                labelText: 'Name',
                labelStyle:
                    TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),

            // Phone Number Text Field
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                icon: Icon(
                  FontAwesomeIcons.phone,
                  color: Colors.teal,
                ),
                hintText: 'Enter your phone number',
                labelText: 'Phone Number',
                labelStyle:
                    TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                } else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),

            // Email Text Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                icon: Icon(
                  FontAwesomeIcons.envelope,
                  color: Colors.teal,
                ),
                hintText: 'Enter your E-mail Address',
                labelText: 'Email',
                labelStyle:
                    TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),

            const SizedBox(height: 20.0),

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
                        // print(typeValue);
                        // print(_selectedType);
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

            // CURRENCY Data COMBO
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.moneyBillTransfer,
                  size: 25.0,
                  color: Colors.teal,
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  // Use Expanded here
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _currency.getCurrencyStream(kUserId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<DocumentSnapshot> currencyList =
                            snapshot.data!.docs;

                        // Create a list of dropdown items
                        List<DropdownMenuItem<String>> dropdownItems =
                            currencyList.map((document) {
                          String docID = document.id;
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          String currencyText = data['currencyName'];

                          return DropdownMenuItem<String>(
                            value: docID,
                            child: Text(
                              currencyText,
                              style: const TextStyle(color: Colors.teal),
                            ),
                          );
                        }).toList();

                        return DropdownButtonFormField<String>(
                          value: _selectedCurrency,
                          hint: const Text(
                            'Select Currency',
                            style: TextStyle(color: Colors.teal),
                          ),
                          items: dropdownItems,
                          isExpanded:
                              true, // Make dropdown button expand to fill available space
                          onChanged: (currencyValue) {
                            setState(() {
                              if (_selectedCurrency != currencyValue) {
                                _selectedCurrency = currencyValue;
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select Currency';
                            }
                            return null;
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return const Center(
                            child: Text('No Currency defined!'));
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // AREA Data COMBO
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.chartArea,
                  size: 25.0,
                  color: Colors.teal,
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _areas.getAreasStream(kUserId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<DocumentSnapshot> areaList = snapshot.data!.docs;

                        // Create a list of dropdown items
                        List<DropdownMenuItem<String>> dropdownItems =
                            areaList.map((document) {
                          String docID = document.id;
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          String areaText = data['area_name'];

                          return DropdownMenuItem<String>(
                            value: docID,
                            child: Text(
                              areaText,
                              style: const TextStyle(color: Colors.teal),
                            ),
                          );
                        }).toList();

                        return SizedBox(
                          width: MediaQuery.of(context).size.width / 1.25,
                          child: DropdownButtonFormField<String>(
                            value: _selectedArea,
                            hint: const Text(
                              'Select Area',
                              style: TextStyle(color: Colors.teal),
                            ),
                            items: dropdownItems,
                            isExpanded: true,
                            onChanged: (areaValue) {
                              setState(() {
                                _selectedArea = areaValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select an area';
                              }
                              return null;
                            },
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return const Center(child: Text('No Area defined!'));
                      }
                    },
                  ),
                ),
              ],
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
                      // print(_accountId);

                      // Handle the form submission
                      if (_formKeyValue.currentState!.validate()) {
                        // Perform the form submission logic
                        if (_accountId == null) {
                          // add a customer to database
                          _accounts.addAccount(
                              _nameController.text,
                              _phoneController.text,
                              _emailController.text,
                              _selectedType!,
                              _selectedCurrency!,
                              _selectedArea!,
                              kUserId);
                        } else {
                          // update customer to database
                          _accounts.updateAccount(
                              _nameController.text,
                              _phoneController.text,
                              _emailController.text,
                              _selectedType!,
                              _selectedCurrency!,
                              _selectedArea!,
                              kUserId);
                        }

                        // For example, you might want to send data to Firestore or another service
                        const snackBar = SnackBar(
                          content: Text(
                            'Account saved successfully!',
                            style: TextStyle(color: Colors.teal),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        // You can also perform further actions here
                        // clear the text controller after adding into database
                        _nameController.clear();
                        _phoneController.clear();
                        _emailController.clear();

                        // close to dialogue box
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chat_wp/services/auth/auth_service.dart';
import 'package:chat_wp/services/accounts/area_service.dart';

class AreaList extends StatefulWidget {
  const AreaList({super.key});

  @override
  State<AreaList> createState() => AreaListState();
}

class AreaListState extends State<AreaList> {
  // area services
  final AuthService _authService = AuthService();
  final AreaService _areaService = AreaService();

  final CollectionReference _currency =
  FirebaseFirestore.instance.collection('currency');

  String? _selectedType, _selectedCurrency, _selectedArea;

  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  final List<String> _accountType = <String>[
    'Customer',
    'Supplier',
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // GET CURRENT USER ID
    String userId = _authService.getCurrentUser()!.uid;

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
            'Supplier Details',
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
                        _selectedType = typeValue;
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
                StreamBuilder<QuerySnapshot>(
                  stream: _currency.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('loading...'));
                    } else {
                      List<DropdownMenuItem<String>> currencyItems = [];
                      for (int i = 0; i < snapshot.data!.docs.length; i++) {
                        DocumentSnapshot snap = snapshot.data!.docs[i];
                        currencyItems.add(
                          DropdownMenuItem<String>(
                            value: snap.id,
                            child: Text(
                              snap.id,
                              style: const TextStyle(color: Colors.teal),
                            ),
                          ),
                        );
                      }
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 1.25,
                        child: DropdownButtonFormField<String>(
                          items: currencyItems,
                          onChanged: (currencyValue) {
                            setState(() {
                              _selectedCurrency = currencyValue;
                            });
                          },
                          value: _selectedCurrency,
                          isExpanded: true,
                          hint: const Text(
                            'Select Currency',
                            style: TextStyle(color: Colors.teal),
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a currency';
                            }
                            return null;
                          },
                        ),
                      );
                    }
                  },
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
                StreamBuilder<QuerySnapshot>(
                  stream: _areaService.getAreasStream(userId),
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
              ],
            ),

            const SizedBox(height: 20.0),

            // FORM SUBMIT
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      // Handle the form submission
                      if (_formKeyValue.currentState!.validate()) {
                        // Perform the form submission logic
                        // For example, you might want to send data to Firestore or another service
                        const snackBar = SnackBar(
                          content: Text(
                            'Form submitted successfully!',
                            style: TextStyle(color: Colors.teal),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        // You can also perform further actions here
                      }
                    },
                    child: const Text('Submit'),
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

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

  final CollectionReference _area =
  FirebaseFirestore.instance.collection('area');

  String? selectedType, selectedCurrency, selectedArea;

  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  final List<String> _accountType = <String>[
    'Savings',
    'Deposit',
    'Checking',
    'Brokerage',
  ];

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

            TextFormField(
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(
                  FontAwesomeIcons.circleUser,
                  color: Colors.teal,
                ),
                hintText: 'Enter your name',
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ),

            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(
                  FontAwesomeIcons.phone,
                  color: Colors.teal,
                ),
                hintText: 'Enter your phone number',
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ),

            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                icon: Icon(
                  FontAwesomeIcons.envelope,
                  color: Colors.teal,
                ),
                hintText: 'Enter your E-mail Address',
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20.0),

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
                  width:MediaQuery.of(context).size.width/1.25,
                  child: DropdownButton<String>(
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
                      final snackBar = SnackBar(
                        content: Text(
                          'Selected Account Type Value is $typeValue',
                          style: const TextStyle(color: Colors.teal),
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      setState(() {
                        selectedType = typeValue;
                      });
                    },
                    value: selectedType,
                    hint: const Text(
                      'Choose Account Type',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

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
                        width:MediaQuery.of(context).size.width/1.25,
                        child: DropdownButton<String>(
                          items: currencyItems,
                          onChanged: (currencyValue) {
                            final snackBar = SnackBar(
                              content: Text(
                                'Selected Currency Value is $currencyValue',
                                style: const TextStyle(color: Colors.teal),
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(snackBar);

                            setState(() {
                              selectedCurrency = currencyValue;
                            });
                          },
                          value: selectedCurrency,
                          isExpanded: true,
                          hint: const Text(
                            'Select Currency',
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20.0),

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
                  stream: _area.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('loading...'));
                    } else {
                      List<DropdownMenuItem<String>> currencyItems = [];
                      for (int i = 0; i < snapshot.data!.docs.length; i++) {
                        DocumentSnapshot snap = snapshot.data!.docs[i];
                        // String areaText = snapshot.data!.docs['area_name'];
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
                        width:MediaQuery.of(context).size.width/1.25,
                        child: DropdownButton<String>(
                          items: currencyItems,
                          onChanged: (areaValue) {
                            final snackBar = SnackBar(
                              content: Text(
                                'Selected Area Name is $areaValue',
                                style: const TextStyle(color: Colors.teal),
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(snackBar);

                            setState(() {
                              selectedArea = areaValue;
                            });
                          },
                          value: selectedArea,
                          isExpanded: true,
                          hint: const Text(
                            'Select Area',
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),


            const SizedBox(height: 20.0),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

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
                      }
                    },
                    child: const Text('Submit'),
                  ),

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
                      }
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

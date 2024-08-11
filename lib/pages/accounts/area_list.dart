import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:chat_wp/services/auth/auth_service.dart';
// import 'package:chat_wp/services/accounts/area_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AreaList extends StatefulWidget {
  const AreaList({super.key});

  @override
  State<AreaList> createState() => AreaListState();
}

class AreaListState extends State<AreaList> {

  final CollectionReference _currency =
  FirebaseFirestore.instance.collection('currency');

  var selectedType;
  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();
  final List<String> _accountType = <String>[
    'Savings',
    'Deposit',
    'Checking',
    'Brokerage',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
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
            'Account Details',
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
        // autovalidate: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          children: [
            TextFormField(
              decoration: const InputDecoration(
                  icon: Icon(
                    FontAwesomeIcons.userCircle,
                    color: Color(0xff11b719),
                  ),
                  hintText: 'Enter your name',
                  labelText: 'Name'),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  icon: Icon(
                    FontAwesomeIcons.phone,
                    color: Color(0xff11b719),
                  ),
                  hintText: 'Enter your phone number',
                  labelText: 'Phone Number'),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  icon: Icon(
                    FontAwesomeIcons.envelope,
                    color: Color(0xff11b719),
                  ),
                  hintText: 'Enter your E-mail Address',
                  labelText: 'Email'),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.moneyBill,
                  size: 25.0,
                  color: Color(0xff11b719),
                ),
                const SizedBox(
                  width: 50.0,
                ),
                DropdownButton<String>(
                  items: _accountType
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Color(0xff11b719)),
                      ),
                    );
                  }).toList(),
                  onChanged: (selectedAccountType) {
                    setState(() {
                      selectedType = selectedAccountType;
                    });
                  },
                  value: selectedType,
                  isExpanded: false,
                  hint: const Text(
                    'Choose Account Type',
                    style: TextStyle(color: Color(0xff11b719)),
                  ),
                ),

                const SizedBox(
                  height: 40.0,
                ),

                // StreamBuilder<QuerySnapshot>(
                //   stream: _areaService.getAreasStream(userId),
                //   builder: (context, snapshot) {
                //     // if we have data, get all the docs.
                //     if (snapshot.hasData) {
                //       List areaList = snapshot.data!.docs;
                //
                //       // display as a list
                //       return ListView.builder(
                //           itemCount: areaList.length,
                //           itemBuilder: (context, index) {
                //             // get each individual doc
                //             DocumentSnapshot document = areaList[index];
                //             String docID = document.id;
                //
                //             // get area from each doc
                //             Map<String, dynamic> data =
                //             document.data() as Map<String, dynamic>;
                //
                //             String areaText = data['area_name'];
                //
                //             Timestamp timeStamp = data['timestamp'] as Timestamp;
                //             DateTime date = timeStamp.toDate();
                //             String formatedDT = DateFormat('dd MMM yyyy hh:mm:ss a').format(date);
                //
                //             // display as a list title
                //             return Container(
                //               decoration: BoxDecoration(
                //                 color: Theme.of(context).colorScheme.secondary,
                //                 borderRadius: BorderRadius.circular(12),
                //               ),
                //               margin:
                //               const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                //               padding: const EdgeInsets.all(3),
                //               child: ListTile(
                //                 title: Text(areaText),
                //                 subtitle: Text(formatedDT),
                //                 trailing: Row(
                //                   mainAxisSize: MainAxisSize.min,
                //                   children: [
                //                     // update button
                //                     IconButton(
                //                       onPressed: () => openAreaBox(docID, areaText, userId),
                //                       icon: const Icon(Icons.settings),
                //                     ),
                //                     // delete button
                //                     IconButton(
                //                       onPressed: () =>_deleteAreaBox(context, docID, userId),
                //                       icon: const Icon(Icons.delete),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             );
                //           });
                //     } else {
                //       return const Center(child: Text('no area data to display!'));
                //     }
                //   },
                // ),



              ],
            ),
          ],
        ),
      ),
    );
  }
}

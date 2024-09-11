import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart'; // Import TypeAhead package

class AccountSearch extends StatefulWidget {
  final String userId;

  const AccountSearch({super.key, required this.userId});

  @override
  AccountSearchState createState() => AccountSearchState();
}

class AccountSearchState extends State<AccountSearch> {
  // String? _selectedAcId;
  // String? _selectedAcText;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('accounts') // Adjust collection path as needed
          .where('userId', isEqualTo: widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // List<DocumentSnapshot> accountList = snapshot.data?.docs ?? [];

        // return TypeAheadFormField(
        //   textFieldConfiguration: TextFieldConfiguration(
        //     decoration: InputDecoration(
        //       labelText: 'Select Account',
        //       hintText: 'Type to search',
        //       hintStyle: const TextStyle(color: Colors.teal, fontSize: 12.0),
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(4.0),
        //       ),
        //     ),
        //   ),
        //   suggestionsCallback: (pattern) {
        //     return accountList.where((document) {
        //       String accountName =
        //           (document.data() as Map<String, dynamic>)['accountName'] ??
        //               '';
        //       return accountName.toLowerCase().contains(pattern.toLowerCase());
        //     }).map((document) {
        //       return (document.data() as Map<String, dynamic>)['accountName'];
        //     }).toList();
        //   },
        //   itemBuilder: (context, suggestion) {
        //     return ListTile(
        //       title: Text(
        //         suggestion,
        //         style: const TextStyle(color: Colors.teal, fontSize: 12.0),
        //       ),
        //     );
        //   },
        //   onSuggestionSelected: (suggestion) {
        //     final selectedDocument = accountList.firstWhere(
        //           (document) =>
        //       (document.data() as Map<String, dynamic>)['accountName'] ==
        //           suggestion,
        //     );
        //     setState(() {
        //       _selectedAcId = selectedDocument.id;
        //       _selectedAcText = suggestion; // Update selected account text
        //     });
        //   },
        //   validator: (value) {
        //     if (value == null || value.isEmpty) {
        //       return 'Please select a valid account';
        //     }
        //     return null;
        //   },
        //   initialValue: _selectedAcText, // Set initial value
        // );
        return const Text('Qaiser Shameer');
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchBanks(String userId, String type) async {
  try {
    // Fetch data from Firestore with specified conditions
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('accounts')
        .where('uid', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .orderBy('accountName', descending: false) // Order by accountName in ascending order
        .get();

    // Map the documents to a list of maps
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      'accountName': doc['accountName'],
    }).toList();
  } catch (e) {
    print('Error fetching banks: $e');
    return [];
  }
}

void showBankSelectionDialog(BuildContext context, String userId, String type) async {
  final List<Map<String, dynamic>> banks = await fetchBanks(userId, type);
  final TextEditingController searchController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Bank'),
        content: SizedBox(
          width: double.maxFinite, // Ensure the dialog takes the full width of the screen
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(labelText: 'Search'),
                onChanged: (text) {
                  // Trigger a rebuild to filter the list
                  (context as Element).markNeedsBuild();
                },
              ),
              // ConstrainedBox to prevent ListView from growing indefinitely
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 300, // Adjust this height based on your requirements
                ),
                child: SingleChildScrollView(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: Stream.fromFuture(Future.value(banks)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No banks found.'));
                      }

                      final filteredBanks = snapshot.data!.where((bank) {
                        final accountName = bank['accountName'].toLowerCase();
                        final query = searchController.text.toLowerCase();
                        return accountName.contains(query);
                      }).toList();

                      return Column(
                        children: filteredBanks.map((bank) {
                          return ListTile(
                            title: Text(bank['accountName']),
                            onTap: () {
                              Navigator.of(context).pop(bank['id']);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).then((selectedId) {
    if (selectedId != null) {
      // Handle the selected bank ID
      print('Selected Bank ID: $selectedId');
    }
  });
}



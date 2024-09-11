import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchBanks(String userId, String type) async {
  try {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('accounts')
        .where('uid', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .orderBy('accountName', descending: false) // Order by accountName in ascending order
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      'accountName': doc['accountName'],
    }).toList();
  } catch (e) {
    print('Error fetching banks: $e');
    return [];
  }
}

Future<bool> showBankSelectionDialog(
    BuildContext context, String userId, String type, Function(String, String) onBankSelected) async {
  final List<Map<String, dynamic>> banks = await fetchBanks(userId, type);
  final TextEditingController searchController = TextEditingController();

  return showDialog<bool>(
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
                  (context as Element).markNeedsBuild();
                },
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
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
                              Navigator.of(context).pop(true); // Indicate that a bank was selected
                              onBankSelected(bank['id'], bank['accountName']);
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
  ).then((selected) {
    if (selected == null) {
      return false; // Return false if the dialog was dismissed
    }
    return selected; // Return true if a bank was selected
  });
}

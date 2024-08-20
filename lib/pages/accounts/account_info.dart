// import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_wp/pages/accounts/account_add.dart';
import 'package:chat_wp/services/accounts/account_service.dart';

class AccountInfo extends StatefulWidget {
  const AccountInfo({super.key});
  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  // account services
  final AccountService _accounts = AccountService();

  // open a dialogue box to delete account
  void _deleteAccountBox(BuildContext context, String docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete this account?'),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // delete button
          TextButton(
            onPressed: () {
              _accounts.deleteAccount(docID);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deleted!'),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, bottom: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountAdd(
                        docId: '',
                        name: '',
                        phone: '',
                        email: '',
                        type: '',
                        currency: '',
                        area: '',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _accounts.getAccountsStream(kUserId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> customerList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: customerList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = customerList[index];
                String docID = document.id;

                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                String customerText = data['accountName'] ?? '';
                String phoneText = data['phone'] ?? '';
                String emailText = data['email'] ?? '';
                String typeText = data['type'] ?? '';
                String currencyText = data['currency'] ?? '';
                String areaIdText = data['areaId'] ?? '';

                // Timestamp? timeStamp = data['timestamp'] as Timestamp?;
                // DateTime date = timeStamp?.toDate() ?? DateTime.now();
                // String formatedDT = DateFormat('dd MMM yyyy hh:mm:ss a').format(date);

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                  padding: const EdgeInsets.all(3),
                  child: ListTile(
                    title: Text(customerText),
                    subtitle: Text('$phoneText * $typeText\n $emailText'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // update button
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountAdd(
                                  docId: docID,
                                  name: customerText,
                                  phone: phoneText,
                                  email: emailText,
                                  type: typeText,
                                  currency: currencyText,
                                  area: areaIdText,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings),
                        ),
                        // delete button
                        IconButton(
                          onPressed: () => _deleteAccountBox(context, docID),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: Text('No account data to display!'));
          }
        },
      ),
    );
  }
}
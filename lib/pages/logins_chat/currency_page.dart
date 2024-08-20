import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_wp/services/accounts/currency_service.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  // crud services
  final CurrencyService _currency = CurrencyService();

  // text controller
  final TextEditingController _textNotes = TextEditingController();

  // open a dialogue box to add a note
  void openNoteBox(String? docID, String? noteText) {
    _textNotes.text = noteText ?? 'NA';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _textNotes,
        ),
        actions: [
          // button to save notes
          ElevatedButton(
            onPressed: () {
              if (docID == null || docID == '') {
                // add a note to database in notes table
                _currency.addCurrency(_textNotes.text, kUserId);
              } else {
                // update a note to database in notes table
                _currency.updateCurrency(docID, _textNotes.text, kUserId);
              }

              // clear the text controller after adding into database
              _textNotes.clear();

              // close to dialogue box
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteNoteBox(BuildContext context, String docID) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Currency'),
          content: const Text('Are you sure! want to Delete this Currency?'),
          actions: [
            // cancel button
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),

            // unblock button
            TextButton(
                onPressed: () {
                  // _chatService.unBlockUser(userId);
                  _currency.deleteCurrency(docID);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Currency deleted!'),
                    ),
                  );
                },
                child: const Text('Delete')),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency'),
        // centerTitle: true,
        // backgroundColor: Colors.transparent,
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, bottom: 16.0),
            // logout button
            child: Container(
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 10.0),
                child: IconButton(
                    onPressed: () => openNoteBox(null, ''),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ))),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _currency.getCurrencyStream(kUserId),
        builder: (context, snapshot) {
          // if we have data, get all the docs.
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;

            // display as a list
            return ListView.builder(
                itemCount: noteList.length,
                itemBuilder: (context, index) {
                  // get each individual doc
                  DocumentSnapshot document = noteList[index];
                  String docID = document.id;

                  // get note from each doc
                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

                  String noteText = data['currencyName'];
                  // Timestamp? timeStamp = data['timestamp'];

                  Timestamp timeStamp = data['timestamp'] as Timestamp;
                  DateTime date = timeStamp.toDate();
                  String formatedDT =
                  DateFormat('dd MMM yyyy hh:mm:ss a').format(date);

                  // display as a list title
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                    padding: const EdgeInsets.all(3),
                    child: ListTile(
                      title: Text(noteText),
                      subtitle: Text(formatedDT),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // update button
                          IconButton(
                            onPressed: () => openNoteBox(docID, noteText),
                            icon: const Icon(Icons.settings),
                          ),
                          // delete button
                          IconButton(
                            onPressed: () =>_deleteNoteBox(context, docID),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          } else {
            return const Center(child: Text('no currency data to display!'));
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   // open note box dialogue box
      //   onPressed: () => openNoteBox(null),
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

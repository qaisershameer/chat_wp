import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_wp/services/chat/crud_service.dart';
import 'package:chat_wp/services/accounts/account_service.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class CrudPage extends StatefulWidget {
  const CrudPage({super.key});
  @override
  State<CrudPage> createState() => CrudPageState();
}

class CrudPageState extends State<CrudPage> {
  // crud services & account service
  final CrudService _crud = CrudService();
  final AccountService _account = AccountService();

  // text controller
  final TextEditingController _textNotes = TextEditingController();

  bool isLoading = false;
  // List userData = [];
  List<dynamic> userData = [];

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
                _crud.addNote(_textNotes.text, kUserId);
              } else {
                // update a note to database in notes table
                _crud.updateNote(docID, _textNotes.text, kUserId);
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
              title: const Text('Delete Notes'),
              content: const Text('Are you sure! want to Delete this Note?'),
              actions: [
                // cancel button
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),

                // unblock button
                TextButton(
                    onPressed: () {
                      // _chatService.unBlockUser(userId);
                      _crud.deleteNote(docID);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Note deleted!'),
                        ),
                      );
                    },
                    child: const Text('Delete')),
              ],
            ));
  }

  Future<void> fetchAccounts() async {
    userData = await _account.getAccountRecords();
  }

  @override
  void initState() {
    fetchAccounts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Notes'),
        title: Text(
          '${apiUrl}accounts',
          style: const TextStyle(fontSize: 15),
        ),
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green), // You can customize the color
              ),
            )
          : // Your normal widget tree here when not loading
          ListView.builder(
              itemCount: userData.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(1),
                  child: ListTile(
                    onTap: () {},
                    leading: const Icon(
                      Icons.heart_broken,
                      color: Colors.red,
                    ),
                    title: Text(
                      userData[index]['acTitle']!,
                      style: const TextStyle(color: Colors.blue),
                    ),
                    subtitle: Text(
                      'ID: ${userData[index]['acId']!}',
                      style: const TextStyle(color: Colors.black45),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // IconButton(
                        //   onPressed: () {},
                        //   icon: const Icon(
                        //     Icons.settings,
                        //     color: Colors.blue,
                        //   ),
                        // ),
                        IconButton(
                          onPressed: () {
                            // deleteRecords(userData[index]['uid']!);
                            // _showDeleteBox(context, userData[index]['uid']!);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

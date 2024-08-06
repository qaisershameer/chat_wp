import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_wp/services/auth/crud_service.dart';
import 'package:intl/intl.dart';

class CrudPage extends StatefulWidget {
  const CrudPage({super.key});
  @override
  State<CrudPage> createState() => CrudPageState();
}

class CrudPageState extends State<CrudPage> {
  // crud services
  final CrudService _crudService = CrudService();

  // text controller
  final TextEditingController _textNotes = TextEditingController();

  // open a dialogue box to add a note
  void openNoteBox(String? docID) {
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
              if (docID == null) {
                // add a note to database in notes table
                _crudService.addNote(_textNotes.text);
              } else {
                // update a note to database in notes table
                _crudService.updateNote(docID, _textNotes.text);
              }

              // clear the text controller after adding into database
              _textNotes.clear();

              // close to dialogue box
              Navigator.pop(context);
            },
            child: const Text('Enter Note'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _crudService.getNotesStream(),
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

                  String noteText = data['note'];
                  // Timestamp? timeStamp = data['timestamp'];

                  Timestamp timeStamp = data['timestamp'] as Timestamp;
                  DateTime date = timeStamp.toDate();

                  String formatedDT = DateFormat('dd MMM yyyy hh:mm:ss a').format(date);

                  // display as a list title
                  return ListTile(
                    title: Text(noteText),
                    subtitle: Text(formatedDT),
                        // '${date.day.toString()} ${date.month.toString()} ${date.year.toString()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // update button
                        IconButton(
                          onPressed: () => openNoteBox(docID),
                          icon: const Icon(Icons.settings),
                        ),
                        // delete button
                        IconButton(
                          onPressed: () => _crudService.deleteNote(docID),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                });
          } else {
            return const Text('no notes data to display!');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // open note box dialogue box
        onPressed: () => openNoteBox(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

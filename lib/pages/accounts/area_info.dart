import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_wp/services/auth/auth_service.dart';
import 'package:chat_wp/services/accounts/area_service.dart';

class AreaInfo extends StatefulWidget {
  const AreaInfo({super.key});

  @override
  State<AreaInfo> createState() => AreaInfoState();
}

class AreaInfoState extends State<AreaInfo> {
  // area services
  final AuthService _authService = AuthService();
  final AreaService _areaService = AreaService();

  // text controller
  final TextEditingController _textArea = TextEditingController();

  // open a dialogue box to add area
  void openAreaBox(String? docID, String? areaText, String userId) {
    _textArea.text = areaText ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _textArea,
        ),
        actions: [
          // button to save Areas
          ElevatedButton(
            onPressed: () {
              if (docID == null || docID == '') {
                // add a area to database in area table
                _areaService.addArea(_textArea.text, userId);
              } else {
                // update area to database in area table
                _areaService.updateArea(docID, _textArea.text, userId);
              }

              // clear the text controller after adding into database
              _textArea.clear();

              // close to dialogue box
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // open a dialogue box to delete area
  void _deleteAreaBox(BuildContext context, String docID) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Area'),
              content: const Text('Are you sure! want to Delete this Area?'),
              actions: [
                // cancel button
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),

                // delete button
                TextButton(
                    onPressed: () {
                      _areaService.deleteArea(docID);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Area deleted!'),
                        ),
                      );
                    },
                    child: const Text('Delete')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    // GET CURRENT USER ID
    String userId = _authService.getCurrentUser()!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Areas'),
        // centerTitle: true,
        // backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, bottom: 16.0),
            // add button
            child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(
                  right: 10.0,
                ),
                child: IconButton(
                    onPressed: () => openAreaBox(null, '', userId),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ))),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _areaService.getAreasStream(userId),
        builder: (context, snapshot) {
          // if we have data, get all the docs.
          if (snapshot.hasData) {
            List areaList = snapshot.data!.docs;

            // display as a list
            return ListView.builder(
                itemCount: areaList.length,
                itemBuilder: (context, index) {
                  // get each individual doc
                  DocumentSnapshot document = areaList[index];
                  String docID = document.id;

                  // get area from each doc
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;

                  String areaText = data['area_name'];

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
                      title: Text(areaText),
                      subtitle: Text(formatedDT),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // update button
                          IconButton(
                            onPressed: () =>
                                openAreaBox(docID, areaText, userId),
                            icon: const Icon(Icons.settings),
                          ),
                          // delete button
                          IconButton(
                            onPressed: () => _deleteAreaBox(context, docID),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          } else {
            return const Center(child: Text('no area data to display!'));
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   // open area box dialogue box
      //   onPressed: () => openAreaBox(null),
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

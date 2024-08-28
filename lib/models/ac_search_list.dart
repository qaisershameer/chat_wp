import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccSearch extends StatefulWidget {
  const AccSearch({super.key});

  @override
  State<AccSearch> createState() => AccSearchState();
}

class AccSearchState extends State<AccSearch> {
  List<Map<String, dynamic>> searchResult = [];

  Future<void> searchFromFirebase(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResult = [];
      });
      return;
    }

    try {
      final result = await FirebaseFirestore.instance
          .collection('search')
          .where('string_id_array', arrayContains: query)
          .get();

        print(result);

      setState(() {
        searchResult = result.docs.map((e) => e.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error searching from Firebase: $e');
      // Optionally, show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Search"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Search Here",
              ),
              onChanged: (query) {
                searchFromFirebase(query);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResult.length,
              itemBuilder: (context, index) {
                final item = searchResult[index];
                return ListTile(
                  title: Text(item['number_id'] ?? 'No ID'),
                  subtitle: Text(item['string_id'] ?? 'No String ID'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

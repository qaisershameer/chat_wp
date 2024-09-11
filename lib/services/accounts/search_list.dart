import 'package:flutter/material.dart';

class SearchList extends StatefulWidget {
  const SearchList({super.key});

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  final List<Map<String, dynamic>> _allUsers = [
    {'id': 1, 'name': 'Andy', 'age': 29},
    {'id': 2, 'name': 'Aragon', 'age': 40},
    {'id': 3, 'name': 'Bob', 'age': 5},
    {'id': 4, 'name': 'Barbara', 'age': 35},
    {'id': 5, 'name': 'Candy', 'age': 21},
    {'id': 6, 'name': 'Colin', 'age': 55},
    {'id': 7, 'name': 'Audra', 'age': 30},
    {'id': 8, 'name': 'Banana', 'age': 4},
    {'id': 9, 'name': 'Caver sky', 'age': 100},
    {'id': 10, 'name': 'Becky', 'age': 32},
  ];

  late List<Map<String, dynamic>> _foundUsers = [];
  // final TextEditingController _selectedItem = TextEditingController();

  @override
  void initState() {
    _foundUsers = _allUsers;
    super.initState();
  }

  void _runFilter(String enterKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enterKeyword.isEmpty) {
      // if search field is empty or contains white-space, we'll display all data
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
      // we use the toLowerCase method to make it case-insensitive
      user['name'].toLowerCase().contains(enterKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Search List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                labelText: 'Search your desired person name',
                suffixIcon: Icon(Icons.search),
                // hintText: 'Select your desired person name',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _foundUsers.length,
                itemBuilder: (context, index) => Card(
                  key: ValueKey(_foundUsers[index]['id']),
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 3.0),
                  child: ListTile(
                    leading: Text(
                      _foundUsers[index]['id'].toString(),
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    title: Text(
                      _foundUsers[index]['name'].toString(),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    subtitle: Text(
                      '${_foundUsers[index]['age']} years old.',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    // onTap: () {
                    //   _selectedItem.text = _foundUsers[index]['name'].toString();
                    // },
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
// import 'data.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ApExample extends StatefulWidget {
  const ApExample({super.key});
  @override
  State<ApExample> createState() => _ApExampleState();
}

class _ApExampleState extends State<ApExample> {

  final TextEditingController _selectedItem = TextEditingController();

  final List _fruits = [
    'Apple',
    'Banana',
    'Orange',
    'Grapes',
    'Strawberry',
    'Pineapple',
    'Watermelon',
    'Mangoes',
    'Kiwi',
    'Blueberry',
  ];

  final List<Map<String, dynamic>> _allCoffeeData = [
    {
      'name': 'Espresso',
      'description': 'Strong Continetal Coffee with enriched flavoer',
      'id': 'BAR-001',
    },
    {
      'name': 'Capcuino',
      'description': 'Strong Capcuino Coffee with enriched flavoer',
      'id': 'BAR-002',
    },
    {
      'name': 'Lattee Cold Coffee',
      'description': 'Strong Continetal Coffee with enriched flavoer',
      'id': 'BAR-003',
    },
    {
      'name': 'Black Coffee',
      'description': 'Strong Continetal Coffee with enriched flavoer',
      'id': 'BAR-004',
    },
    {
      'name': 'Strong Coffe',
      'description': 'Strong Continetal Coffee with enriched flavoer',
      'id': 'BAR-005',
    },
  ];

  late List<Map<String, dynamic>> _foundData = [];

  @override
  void initState() {
    _foundData = _allCoffeeData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Coffee Cafe',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TypeAheadField(
            itemBuilder: (context, dataItem){

            // for Fruit List Data Type use this code

            //   return ListTile(
            //     title: Text(dataItem),
            //   );
            // },
            // onSelected: (value){
            //   _selectedItem.text = value;
            // },
            // controller: _selectedItem,

            // suggestionsCallback: (value){
            //   return _fruits.where((element) {
            //     return element.contains(value);
            //   }).toList();
            // }),

            // for multi data list use this value
              return ListTile(
                leading: Text(dataItem['id']),
                title: Text(dataItem['name']),
                subtitle: Text(dataItem['description']),
              );
            },
            onSelected: (value){
              _selectedItem.text = value['name'];
            },
            controller: _selectedItem,
            suggestionsCallback: (value){
              return _allCoffeeData.where((element) {
                return element['name'].toLowerCase().contains(value).toLowerCase();
              }).toList();
            },
          builder: (context, con, fn) {
              return TextField(
                controller: con,
                focusNode: fn,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.search),
                  hintText: 'Choose Your Coffee',
                ),
              );
          },

        ),
      ),
    );
  }
}

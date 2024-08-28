import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchAccounts extends StatefulWidget {
  const SearchAccounts({super.key});
  @override
  State<SearchAccounts> createState() => SearchAccountsState();
}

class SearchAccountsState extends State<SearchAccounts> {
  List _allAccounts = [];
  List _searchResult = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  _onSearchChanged() {
    // print(_searchController.text);
    searchResultList();
  }

  searchResultList() {
    var showResults = [];
    if (_searchController.text != '') {
      for (var accountSnapShot in _allAccounts) {
        var name = accountSnapShot['accountName'].toString().toLowerCase();
        if (name.contains(_searchController.text.toLowerCase())) {
          showResults.add(accountSnapShot);
        }
      }
    } else {
      showResults = List.from(_allAccounts);
    }

    setState(() {
      _searchResult = showResults;
    });
  }

  getAccountStream() async {
    var data = await FirebaseFirestore.instance
        .collection('accounts')
        .where('uid', isEqualTo: kUserId)
        .orderBy('accountName')
        .get();

    setState(() {
      _allAccounts = data.docs;
    });
    searchResultList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getAccountStream();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Account Ledger'),
        title: CupertinoSearchTextField(
          controller: _searchController,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
          itemCount: _searchResult.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                _searchResult[index]['accountName'],
              ),
              subtitle: Text(
                _searchResult[index]['phone'],
              ),
              trailing: Text(
                _searchResult[index]['type'],
              ),
            );
          }),
    );
  }
}

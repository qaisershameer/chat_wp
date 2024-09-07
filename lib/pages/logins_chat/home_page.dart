import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:chat_wp/components/my_drawer.dart';
import 'package:chat_wp/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_wp/services/accounts/account_service.dart';

class HomePage extends StatefulWidget {
  static const String id = 'home_screen';
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // auth services
  final AuthService _authService = AuthService();
  final AccountService _accounts = AccountService();

  List _allAccounts = [];
  List _allCustomers = [];
  List _allSuppliers = [];
  List _allBanks = [];
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

    // var data = await _accounts.getAccountsStream(kUserId);

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
    _accounts.getAccountsStream(kUserId);
    // _accounts.getAccountsTypeStream(kUserId, 'CUSTOMER');
    // _accounts.getAccountsTypeStream(kUserId, 'SUPPLIER');
    // _accounts.getAccountsTypeStream(kUserId, 'BANK');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text('admin'),
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text('Customers'),
              ),
              Tab(
                child: Text('Suppliers'),
              ),
              Tab(
                child: Text('Banks'),
              ),
              Tab(
                child: Text('ALL'),
              ),
            ],
          ),

          actions: [
            const Icon(Icons.search),
            const SizedBox(width: 10.0),
            PopupMenuButton(
              child: const Icon(Icons.more_vert_outlined),
              itemBuilder: (
                  context,
                  ) =>
              [
                const PopupMenuItem(
                  value: '1',
                  child: Text('New Group'),
                ),
                const PopupMenuItem(
                  value: '2',
                  child: Text('Settings'),
                ),
                const PopupMenuItem(
                  value: '3',
                  child: Text('Log Out'),
                ),
              ],
            ),
            const SizedBox(width: 10.0),
          ],
        ),

        drawer: const MyDrawer(),

        body: TabBarView(
          children: [
            // 1st Menu Body Data CUSTOMERS
            ListAccounts(searchResult: _searchResult,type: 'CUSTOMER',),

            // 2nd Menu Body Data SUPPLIERS

            ListAccounts(searchResult: _searchResult,type: 'SUPPLIER',),

            // 3rd Menu Body Data BANKS
            ListAccounts(searchResult: _searchResult,type: 'BANK',),

            // 4th Menu Body Data ALL ACCOUNTS
            ListAccounts(searchResult: _searchResult,type: 'ALL',),
          ],
        ),
      ),
    );
  }

}
class ListAccounts extends StatefulWidget {
  const ListAccounts({
    super.key,
    required List searchResult,
    required this.type,
  }) : _searchResult = searchResult;

  final List _searchResult;
  final String type;

  @override
  State<ListAccounts> createState() => _ListAccountsState();
}

class _ListAccountsState extends State<ListAccounts> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget._searchResult.length,
      itemBuilder: (context, index) {
        // Check if the current item's type matches the passed type
        bool matchesType=true;
        if(widget.type!='ALL'){
        matchesType = widget.type == widget._searchResult[index]['type'];
        }

        // If it matches, show the ListTile; otherwise, return a SizedBox.shrink()
        return matchesType ? ListTile(
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green,
                width: 3,
              ),
            ),
            child: const CircleAvatar(
              backgroundImage: AssetImage('images/imran_khan.jpg'),
            ),
          ),
          title: Text(
            widget._searchResult[index]['accountName'],
          ),
          subtitle: Text(
            widget._searchResult[index]['phone'],
          ),
          trailing: Text(
            widget._searchResult[index]['type'],
          ),
        ) : const SizedBox.shrink();
      },
    );
  }
}

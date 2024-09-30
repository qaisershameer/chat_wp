import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/pages/accounts/account_add.dart';

import 'package:chat_wp/pages/accounts/acc_dashboard.dart';
// import 'package:chat_wp/pages/inventory/a_inv_dashboard.dart';
import 'package:chat_wp/pages/logins_chat/settings_page.dart';

import 'package:chat_wp/reports/rpt_cash_book.dart';
import 'package:chat_wp/reports/rpt_ac_ledger.dart';
import 'package:chat_wp/reports/rpt_trial_bal.dart';

class HomePage extends StatefulWidget {
  static const String id = 'home_screen';
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // String? _selectedAcId, _selectedAcType;
  // account services
  final AccountService _accounts = AccountService();

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
          automaticallyImplyLeading: false, // Prevents the back arrow from showing
          backgroundColor: Colors.teal,
          // title: const Text('admin'),

          // leading: null,

          title: SizedBox(
            width: 300, // Adjust this width as needed
            child: CupertinoSearchTextField(
              controller: _searchController,
              backgroundColor: Colors.white,
            ),
          ),

          bottom: const TabBar(
            // title: const Text('Account Ledger'),
            tabs: [
              Tab(
                child: Text('Customer'),
              ),
              Tab(
                child: Text('Supplier'),
              ),
              Tab(
                child: Text('Banks'),
              ),
              Tab(
                child: Text('ALL'),
              ),
            ],

            indicatorColor: Colors.white, // Change the indicator color here
            labelColor: Colors.black, // Change the selected tab color here
            unselectedLabelColor:
                Colors.white, // Change the unselected tab color here
          ),
          actions: [
            SizedBox(
              width: 35,
              child: IconButton(
                onPressed: () {
                  // navigate to Accounts Dash Board
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountsDashboard(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(
              width: 35,
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
                  color: Colors.black,
                ),
              ),
            ),


            SizedBox(
              width: 35,
              child: IconButton(
                onPressed: () {
                  // navigate to Accounts Dash Board
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RptCashBook(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.payment_rounded,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(
              width: 35.0,
              child: IconButton(
                onPressed: () {
                  // navigate to Accounts Dash Board
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RptTrialBal(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.table_chart,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(width: 3.0),

            PopupMenuButton(
              child: const Icon(Icons.more_vert_outlined),
              itemBuilder: (
                context,
              ) =>
                  [
                PopupMenuItem(
                  value: '1',
                  child: const Text('Cash Book'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RptCashBook()),
                    );
                  },
                ),
                PopupMenuItem(
                  value: '2',
                  child: const Text('Trial Balance'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RptTrialBal()),
                    );
                  },
                ),
                PopupMenuItem(
                  value: '3',
                  child: const Text('Settings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                ),
                const PopupMenuItem(
                  value: '3',
                  child: Text('Log Out'),
                ),
              ],
            ),
            const SizedBox(width: 2.0),
          ],
        ),

        // drawer: const MyDrawer(),

        body: TabBarView(
          children: [
            // 1st Menu Body Data CUSTOMERS
            ListAccounts(
              searchResult: _searchResult,
              type: 'CUSTOMER',
            ),

            // 2nd Menu Body Data SUPPLIERS

            ListAccounts(
              searchResult: _searchResult,
              type: 'SUPPLIER',
            ),

            // 3rd Menu Body Data BANKS
            ListAccounts(
              searchResult: _searchResult,
              type: 'BANK',
            ),

            // 4th Menu Body Data ALL ACCOUNTS
            ListAccounts(
              searchResult: _searchResult,
              type: 'ALL',
            ),
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
  State<ListAccounts> createState() => ListAccountsState();
}

class ListAccountsState extends State<ListAccounts> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget._searchResult.length,
      itemBuilder: (context, index) {
        // Check if the current item's type matches the passed type
        bool matchesType = true;
        if (widget.type != 'ALL') {
          matchesType = widget.type == widget._searchResult[index]['type'];
        }

        // If it matches, show the ListTile; otherwise, return a SizedBox.shrink()
        return matchesType
            ? ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const CircleAvatar(
                    backgroundImage: AssetImage('images/pk01.jpg'),
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
                onTap: () {
                  try {
                    final accountId = widget._searchResult[index]
                        .id; // Access the document ID directly
                    final selectedAcType = widget._searchResult[index]['type'];

                    // print('Account Type: $selectedAcType');

                    if (accountId != '') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return RptAcLedger(
                              accountId: accountId,
                              accountType: selectedAcType,
                            ); // Pass the document ID (accountId)
                          },
                        ),
                      );
                    }
                  } catch (e) {
                    const Text('Error loading record...');
                  }
                })
            : const SizedBox.shrink();
      },
    );
  }
}

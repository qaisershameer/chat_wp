import 'package:flutter/material.dart';
import 'package:chat_wp/components/my_drawer.dart';
import 'package:chat_wp/components/my_list_tile.dart';

class AccountsDashboard extends StatelessWidget {
  const AccountsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('A C C O U N T S'),
        // centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, bottom: 12.0, top: 5.0),
            // logout button
            child: Container(
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 10.0),
                child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white,
                    ))),
          )
        ],
      ),
      drawer: const MyDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: const Column(
            children: [
              // Dash Board Pages
              // users currency list
              MyListTile(pageNo: 1, text: 'Currency List', icon: Icons.currency_pound),
              MyListTile(pageNo: 2, text: 'Areas List', icon: Icons.area_chart_sharp),
              MyListTile(pageNo: 3, text: 'Accounts List', icon: Icons.person),
              MyListTile(pageNo: 4, text: 'Cash Receipt', icon: Icons.receipt_long_rounded),
              MyListTile(pageNo: 5, text: 'Cash Payment', icon: Icons.payment_rounded),
              MyListTile(pageNo: 6, text: 'Journal Voucher', icon: Icons.ac_unit_sharp),
              MyListTile(pageNo: 7, text: 'Cash Book', icon: Icons.payment_rounded),
              MyListTile(pageNo: 8, text: 'Account Ledger', icon: Icons.search_sharp),
              MyListTile(pageNo: 9, text: 'Trial Balance', icon: Icons.table_chart),
              MyListTile(pageNo: 10, text: 'Profit & Loss', icon: Icons.table_chart),
              MyListTile(pageNo: 11, text: 'Balance Sheet', icon: Icons.table_chart),
            ],
          ),
        ),
      ),
    );
  }
}
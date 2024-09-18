import 'package:flutter/material.dart';
import 'package:chat_wp/components/my_drawer.dart';
import 'package:chat_wp/components/my_list_tile.dart';
import 'package:chat_wp/pages/logins_chat/home_page.dart';

class InventoryDashboard extends StatelessWidget {
  const InventoryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('I N V E N T O R Y'),
        // centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, bottom: 12.0, top: 5.0),
            // Home button
            child: Container(
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 10.0),
                child: IconButton(
                    onPressed: () {
                      // navigate to settings page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );

                    },
                    icon: const Icon(
                      // Icons.account_balance_rounded,
                      Icons.home,
                      color: Colors.white,
                    )),
            ),
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
              MyListTile(pageNo: 16, text: 'Group Information', icon: Icons.grade),
              MyListTile(pageNo: 17, text: 'Brand Information', icon: Icons.branding_watermark_outlined),
              MyListTile(pageNo: 18, text: 'Items Information', icon: Icons.inventory_outlined),
              // MyListTile(pageNo: 19, text: 'Party Information', icon: Icons.person),

              MyListTile(pageNo: 19, text: 'Purchase Invoice', icon: Icons.receipt_long_rounded),
              MyListTile(pageNo: 20, text: 'Sales Invoice', icon: Icons.payment_rounded),

              MyListTile(pageNo: 21, text: 'Party Ledger', icon: Icons.search_sharp),
              MyListTile(pageNo: 22, text: 'Party Balances', icon: Icons.search_sharp),

              MyListTile(pageNo: 23, text: 'Purchases Report', icon: Icons.payment_rounded),
              MyListTile(pageNo: 24, text: 'Sales Report', icon: Icons.payment_rounded),

              MyListTile(pageNo: 25, text: 'Item Ledger', icon: Icons.ac_unit_sharp),
              MyListTile(pageNo: 26, text: 'Stock Report', icon: Icons.payment_rounded),

            ],
          ),
        ),
      ),
    );
  }
}
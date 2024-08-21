import 'package:chat_wp/components/my_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:chat_wp/themes/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('S E T T I N G S'),
        // centerTitle: true,
        actions: const [],
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.teal,
        elevation: 0,
        // actions: [
        //   // logout button
        //   IconButton(onPressed: logout, icon: const Icon(Icons.logout))
        // ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // dark mode
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // dark mode
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Dark Mode Theme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    // switch toggle
                    CupertinoSwitch(
                      value: Provider.of<ThemeProvider>(context, listen: false)
                          .isDarkMode,
                      onChanged: (value) =>
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleThemes(),
                    )
                  ],
                ),
              ),

              // blocked users
              const MyListTile(pageNo: 12, text: 'Blocked Users', icon: Icons.person),

              // user notes
              const MyListTile(pageNo: 13, text: 'User Notes', icon: Icons.receipt_long_rounded),

              // users currency list
              const MyListTile(pageNo: 14, text: 'Currency List', icon: Icons.currency_pound),

              // search list example
              const MyListTile(pageNo: 15, text: 'Search List Example', icon: Icons.search_sharp),

            ],
          ),
        ),
      ),
    );
  }
}

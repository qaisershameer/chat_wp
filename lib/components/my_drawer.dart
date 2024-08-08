import 'package:chat_wp/home_screen.dart';
import 'package:chat_wp/pages/accounts/acc_dashboard.dart';
import 'package:chat_wp/pages/logins_chat/home_page.dart';
import 'package:flutter/material.dart';
import '../pages/logins_chat/settings_page.dart';
import '../services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    // get auth service
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // logo
              DrawerHeader(
                child: Center(
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 100,
                  ),
                ),
              ),

              // home list tile
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: ListTile(
                  title: const Text('H O M E'),
                  leading: Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    // // pop the drawer
                    // Navigator.pop(context);

                    // navigate to settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );

                  },
                ),
              ),

              // accounts list tile
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: ListTile(
                  title: const Text('A C C O U N T S'),
                  leading: Icon(
                    Icons.account_balance_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    // pop the drawer
                    Navigator.pop(context);

                    // navigate to settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountsDashboard(),
                      ),
                    );
                  },
                ),
              ),

              // settings list tile
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: ListTile(
                  title: const Text('S E T T I N G S'),
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    // pop the drawer
                    Navigator.pop(context);

                    // navigate to settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ),

              // WhatsApp UI/UX list tile
              Padding(
                padding: const EdgeInsets.only(left: 15.0, bottom: 25.0),
                child: ListTile(
                  title: const Text('WHATS APP UI/UX'),
                  leading: Icon(
                    Icons.message,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    // pop the drawer
                    Navigator.pop(context);

                    // navigate to settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // logout list tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
            child: ListTile(
              title: const Text('L O G O U T'),
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}

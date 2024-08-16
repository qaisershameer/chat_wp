import 'package:chat_wp/components/user_tile.dart';
import 'package:chat_wp/services/auth/auth_service.dart';
import 'package:chat_wp/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});

  // chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // show confirm unblock box
  void _showUnblockBox(BuildContext context, String userId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Unblock User'),
              content: const Text('Are you sure! want to unblock this user?'),
              actions: [
                // cancel button
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),

                // unblock button
                TextButton(
                    onPressed: () {
                      _chatService.unBlockUser(userId);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User Unblocked done!'),
                        ),
                      );
                    },
                    child: const Text('Unblock')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    // GET CURRENT USER ID
    String userId = _authService.getCurrentUser()!.uid;

    // UI - BLOCKED USERS
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('BLOCKED USERS'),
          centerTitle: true,
          actions: [],
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey,
          elevation: 0,
          // actions: [
          //   // logout button
          //   IconButton(onPressed: logout, icon: const Icon(Icons.logout))
          // ],
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _chatService.getBlockedUsersStream(userId),
          builder: (context, snapshot) {
            // check if any Errors
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error loading Blocked Users'),
              );
            }

            // loading...
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ?? null safety
            final blockedUsers = snapshot.data ?? [];

            // no blocked users...
            if (blockedUsers.isEmpty) {
              return const Text('No Blocked Users');
            }

            // loading complete...
            return ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                return UserTile(
                  text: user['email'],
                  onTap: () => _showUnblockBox(context, user['uid']),
                  onLongPress: null,
                );
              },
            );
          },
        ));
  }
}

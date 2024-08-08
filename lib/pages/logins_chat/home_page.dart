import 'package:flutter/material.dart';
import 'package:chat_wp/components/my_drawer.dart';
import 'package:chat_wp/services/auth/auth_service.dart';
import 'package:chat_wp/services/chat/chat_service.dart';
import 'package:chat_wp/pages/logins_chat/chat_page.dart';
import 'package:chat_wp/components/user_tile.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void logout() {
    _authService.signOut();
  }

  // show confirm block box
  void showBlockBox(BuildContext context, String userId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Block User'),
          content: const Text('Are you sure! want to block this user?'),
          actions: [
            // cancel button
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),

            // unblock button
            TextButton(
                onPressed: () {
                  _chatService.blockUser(userId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User blocked!'),
                    ),
                  );
                },
                child: const Text('Block')),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Network Users List'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            // logout button
            child: IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
          )
        ],
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStreamExcludingBlocked(),
      builder: (context, snapshot) {
        // errors
        if (snapshot.hasError) {
          return const Center(child: Text('Error Found in User List.'));
        }

        // loading..
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading..');
        }

        // return list view
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // build individual list tile for users
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // display all users except current user
    if (userData['email'] != _authService.getCurrentUser()) {
      return UserTile(
        text: userData['email'],
        onLongPress: () => showBlockBox(context, userData['uid']),
        onTap: () {
          // tapped on user and go to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData['email'],
                receiverID: userData['uid'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}

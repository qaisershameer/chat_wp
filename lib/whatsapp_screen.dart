import 'package:flutter/material.dart';
import 'package:chat_wp/components/my_drawer.dart';
import 'package:chat_wp/services/auth/auth_service.dart';
import 'package:chat_wp/services/chat/chat_service.dart';
import 'package:chat_wp/pages/logins_chat/chat_page.dart';
import 'package:chat_wp/components/user_tile.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text('WhatsApp'),
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Icon(Icons.message_outlined),
                // child: Text('Friends'),
              ),
              Tab(
                child: Text('Chats'),
              ),
              Tab(
                child: Text('Status'),
              ),
              Tab(
                child: Text('Calls'),
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
            // 1st Menu Body Data Camera
            // const Icon(Icons.camera_alt),
            _buildUserList(),

            // 2nd Menu Body Data Chats
            ListView.builder(
                itemCount: 100,
                itemBuilder: (context, index) {
                  return const ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('images/qaiser.jpg'),
                    ),
                    title: Text('Qaiser Shameer'),
                    subtitle: Text('Have you not follow my Orders!'),
                    trailing: Text('12:45 PM'),
                  );
                }),

            // 3rd Menu Body Data Status
            ListView.builder(
                itemCount: 100,
                itemBuilder: (context, index){
                  return ListTile(
                    leading: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green,
                              width: 3,
                            )
                        ),
                        child: const CircleAvatar(backgroundImage: AssetImage('images/imran_khan.jpg'),)),
                    title: Text(index % 2 == 0 ? 'Imran Khan' : 'Pakistan Tahreek-e-Insaf'),
                    subtitle:Text('$index minutes ago'),
                  );
                }),

            // 4th Menu Body Data Calls
            ListView.builder(
                itemCount: 100,
                itemBuilder: (context, index) {
                  return  ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('images/qaiser1.jfif'),
                    ),
                    title: const Text('Qurban Raza'),
                    subtitle: Text(index % 2 == 0 ? 'You missed a Audio Call $index minutes ago' : 'You missed a Video Call $index minutes ago'),
                    trailing: Icon(index % 2 == 0 ? Icons.phone: Icons.video_call ),
                  );
                }),
          ],
        ),
      ),
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
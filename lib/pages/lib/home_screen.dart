import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                child: Icon(Icons.camera_alt),
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
        body: TabBarView(
          children: [
            // 1st Menu Body Data Camera
            const Icon(Icons.camera_alt),

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
                title: Text(index % 2 == 0 ? 'Imran Khan' : 'Pakistan Tahreeke-e-Insaf'),
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
}

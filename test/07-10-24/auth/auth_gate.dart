import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:chat_wp/pages/accounts/home_page.dart';
import 'package:chat_wp/services/auth/login_or_register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('loading...');
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            print('error Occurred...');
            return const Text('Some error has occurred');
          } else if (snapshot.hasData) {

            final prefs = snapshot.data!;
            final userId = prefs.getInt('id') ?? 1;
            final userName = prefs.getString('name') ?? 'qaiser';
            final userEmail = prefs.getString('email') ?? 'qrdevteam@gmail.com';
            final token = prefs.getString('token'); // Can be null

            // Assigning id, name, email & token to constant variables
            kUserIdNew = userId;
            kUserName = userName;
            kUserEmail = userEmail;
            kToken = token ?? '';

            print('id: $kUserIdNew');
            print('name: $kUserName');
            print('email: $kUserEmail');
            print('token: $kToken');

            // Navigate based on token presence
            if (token != null && token.isNotEmpty) {
              return const HomePage(); // User is authenticated
            } else {
              return const LoginOrRegister(); // User needs to log in
            }
          } else {
            return const LoginOrRegister(); // Default to login if no data
          }
        },
      ),
    );
  }
}

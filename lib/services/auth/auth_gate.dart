import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_wp/pages/accounts/home_page.dart';
import 'package:chat_wp/services/auth/login_or_register.dart';

import 'package:http/http.dart' as http;

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshopt) {

          // user is logged in
          if(snapshopt.hasData){
            return const HomePage();
            // return const AccountsDashboard();
          }

          // user is not logged in
          else {
            return const LoginOrRegister();
          }

        },
      ),
    );
  }
}

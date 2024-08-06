import 'package:chat_wp/services/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_wp/pages/home_page.dart';

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
            return HomePage();
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

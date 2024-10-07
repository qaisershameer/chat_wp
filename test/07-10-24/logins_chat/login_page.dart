import 'package:flutter/material.dart';
import 'package:chat_wp/services/auth/auth_service.dart';
import 'package:chat_wp/components/my_button.dart';
import 'package:chat_wp/components/my_textfield.dart';

import 'dart:convert';
import 'package:chat_wp/themes/const.dart';
import 'package:chat_wp/services/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_wp/pages/accounts/home_page.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // email & password text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  List userData = [];

  // // login Method
  // void login(BuildContext context) async {
  //   // auth service
  //   final authService = AuthService();
  //
  //   // try login
  //   try {
  //     await authService.signInWithEmailPassword(
  //       _emailController.text,
  //       _pwdController.text,
  //     );
  //
  //     // catch any errors
  //   } catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text(e.toString()),
  //       ),
  //     );
  //   }
  // }

  void loginUser() async {

    final sendData = {
      'email': _emailController.text.toString(),
      'password': _pwdController.text.toString(),
    };

    final result = await API().postRequest(route: 'login', data: sendData);
    final getData = jsonDecode(result.body);

    // var response = await http.get(Uri.parse(url), headers: kHeaders);

    // print(response);
    // print(getData['status']);

    if (getData['status'].toString() == 'true') {

     // var data = jsonDecode(response.body);
        var users = getData['user'];

        SharedPreferences preferences = await SharedPreferences.getInstance();

        await preferences.setInt('id', users['id']);
        await preferences.setString('name', users['name']);
        await preferences.setString('email', users['email']);
        await preferences.setString('token', getData['token']);

        final userId = users['id'];
        final userName = users['name'];
        final userEmail = users['email'];
        final token = getData['token'];

        // assigning id, name, email & token to constant kToken variable
        kUserIdNew = userId;
        kUserName = userName??'';
        kUserEmail = userEmail??'';
        kToken = token??'';

        print('id: $kUserId');
        print('name: $kUserName');
        print('email: $kUserEmail');
        print('token: $kToken');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getData['message']),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>  const HomePage(),
          ),
        );
      } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getData['message']),
        ),
      );

    }

  }

  // for textfield focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // add a listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // cause a delay so that the keyboard has time to showup
        // then the amount of remaining space will be calculated,
        // then scroll down
        // Future.delayed(
        //   const Duration(microseconds: 500),
        //       () => scrollDown(),
        // );
      }
    });

    // wait a bit for listview to be build, then scroll to bottom
    Future.delayed(
      const Duration(milliseconds: 500),
      // () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _emailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  // scroll controller
  // final ScrollController _scrollController = ScrollController();
  // void scrollDown() {
  //   _scrollController.animateTo(
  //     _scrollController.position.maxScrollExtent,
  //     duration: const Duration(seconds: 1),
  //     curve: Curves.fastOutSlowIn,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Icon(
              Icons.message,
              size: 60.0,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 50.0),

            // welcome back message
            Text(
              'Welcome back! you have been missed.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18.0,
              ),
            ),

            const SizedBox(height: 25.0),

            // email textfield
            MyTextField(
              hintText: 'Email',
              obsecureText: false,
              controller: _emailController,
              focusNode: null, //myFocusNode,
              textInputType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 10.0),

            // pwd textfield
            MyTextField(
              hintText: 'Password',
              obsecureText: true,
              controller: _pwdController,
              focusNode: null, //myFocusNode,
              textInputType: TextInputType.text,
            ),

            const SizedBox(height: 25.0),

            // login button
            MyButton(
              // onTap: () => login(context),
              onTap: () => loginUser(),
              text: 'Login',
            ),

            const SizedBox(height: 25.0),

            // register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not a Member? ',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Register Now.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}

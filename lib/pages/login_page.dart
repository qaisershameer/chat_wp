import 'package:chat_wp/services/auth/auth_service.dart';
import 'package:chat_wp/components/my_button.dart';
import 'package:chat_wp/components/my_textfield.dart';
import 'package:flutter/material.dart';

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

  // login Method
  void login(BuildContext context) async {
    // auth service
    final authService = AuthService();

    // try login
    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _pwdController.text,
      );

      // catch any errors
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
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
        Future.delayed(
          const Duration(microseconds: 500),
              () => scrollDown(),
        );
      }
    });

    // wait a bit for listview to be build, then scroll to bottom
    Future.delayed(
      const Duration(milliseconds: 500),
          () => scrollDown(),
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
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

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
              textInputType: TextInputType.emailAddress,
              hintText: 'Email',
              obsecureText: false,
              controller: _emailController,
              focusNode: null, //myFocusNode,
            ),

            const SizedBox(height: 10.0),

            // pwd textfield
            MyTextField(
              textInputType: TextInputType.text,
              hintText: 'Password',
              obsecureText: true,
              controller: _pwdController,
              focusNode: null, //myFocusNode,
            ),

            const SizedBox(height: 25.0),

            // login button
            MyButton(
              onTap: () => login(context),
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

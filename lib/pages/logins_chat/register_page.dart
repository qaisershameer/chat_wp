import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';
import '../../components/my_button.dart';
import '../../components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // email & password text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();

  // registration method
  void register(BuildContext context) async {
    // auth service
    final authService = AuthService();

    // passwords match -> create user
    if (_pwdController.text == _confirmPwdController.text) {
      // try login
      try {
        await authService.signUpWithEmailPassword(
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
      // passwords not matched -> show error
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords don't match!"),
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
    _confirmPwdController.dispose();
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
              "Let's create a new account for you!",
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
            ),

            const SizedBox(height: 10.0),

            // pwd textfield
            MyTextField(
              hintText: 'Password',
              obsecureText: true,
              controller: _pwdController,
              focusNode: null, //myFocusNode,
            ),

            const SizedBox(height: 10.0),

            // pwd textfield
            MyTextField(
              hintText: 'Confirm Password',
              obsecureText: true,
              controller: _confirmPwdController,
              focusNode: null, //myFocusNode,
            ),

            const SizedBox(height: 25.0),

            // register button
            MyButton(
              onTap: () => register(context),
              text: 'Register',
            ),

            const SizedBox(height: 25.0),

            // register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Login Now.',
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

import 'package:chat_wp/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_wp/services/auth/auth_gate.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBY6lJkkiY5lT0PopaXEJjxFFfmeAywpp0',        // web api key done
        appId: '1:880776645949:android:02dda9cef0faf2d26e8954',   // app id done
        messagingSenderId: '880776645949',                        // project number done
        projectId: 'chatpk-7861',                                 // project id done
        storageBucket: 'myapp-b9yt18.appspot.com',                // firebase default value
      )
  );

  runApp(
    ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      child: const MyApp(),
    )
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp',
      // theme: ThemeData(primarySwatch: Colors.teal,),
      theme: Provider.of<ThemeProvider>(context).themeData,
      // home: LoginPage(),
      home: const AuthGate(),
    );
  }
}

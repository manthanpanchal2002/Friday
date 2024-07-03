import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:friday_app/routes/routes.dart';
import 'package:friday_app/screens/chat_screen.dart';
import 'package:friday_app/screens/help_screen.dart';
import 'package:friday_app/screens/noInternet_screen.dart';
import 'package:friday_app/screens/privacyPolicy_screen.dart';
import 'package:friday_app/screens/splash_screen.dart';
import 'package:friday_app/screens/subscription_screen.dart';
import 'package:friday_app/screens/userProfile_screen.dart';
import 'package:friday_app/screens/welcome_screen.dart';

Future<void> main() async {
  // Connect with Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: MyRoutes.splashScreen,
      routes: {
        '/splashScreen': (context) => splashScreen(),
        '/welcomeScreen': (context) => welcomeScreen(),
        '/chatScreen': (context) => chatScreen(),
        '/privacyPolicyScreen': (context) => privacyPolicyScreen(),
        '/userProfileScreen': (context) => userProfileScreen(),
        '/subscriptionScreen': (context) => subscriptionScreen(),
        '/noInternetScreen': (context) => noInternetScreen(),
        '/helpScreen': (context) => helpScreen(),
      },
    );
  }
}

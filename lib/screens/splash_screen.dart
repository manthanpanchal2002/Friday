import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:friday_app/screens/chat_screen.dart';
import 'package:friday_app/screens/noInternet_screen.dart';
import 'package:friday_app/screens/welcome_screen.dart';
import 'package:friday_app/utils/colors.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splashScreen extends StatefulWidget {
  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  bool isLogin = false;
  String? user_key;

  @override
  void initState() {
    super.initState();
    checkLoginAndConnectivity();
  }

  Future<void> checkLoginAndConnectivity() async {
    await getUserKey();
    await startAnimation();
  }

  Future<void> getUserKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_key = prefs.getString('user_key');

    if (user_key != null) {
      setState(() {
        isLogin = true;
      });
    } else {
      setState(() {
        isLogin = false;
      });
    }
  }

  Future<void> startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    // Check internet connection
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.single == ConnectivityResult.none) {
      // Navigate to no internet screen
      Get.off(() => noInternetScreen(),
          transition: Transition.rightToLeft,
          duration: Duration(milliseconds: 300));
    } else {
      isLogin
          ? // Navigate to Home Screen
          Get.off(
              () => chatScreen(),
              transition: Transition.rightToLeft,
              duration: Duration(milliseconds: 300),
            )
          : // Navigate to Login Screen
          Get.off(
              () => welcomeScreen(),
              transition: Transition.rightToLeft,
              duration: Duration(milliseconds: 300),
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: appColor.white,
        body: SafeArea(
            child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Image.asset(
              'assets/videos/FRIDAY loader.gif',
              height: 50,
            ),
          ),
        )),
      ),
    );
  }
}

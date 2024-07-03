import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:friday_app/screens/chat_screen.dart';
import 'package:friday_app/screens/welcome_screen.dart';
import 'package:friday_app/utils/colors.dart';
import 'package:friday_app/utils/font_size.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class noInternetScreen extends StatefulWidget {
  @override
  State<noInternetScreen> createState() => _noInternetScreenState();
}

class _noInternetScreenState extends State<noInternetScreen> {
  bool _isLoading = false;
  String? user_key;

  Future<void> _checkInternetAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user_key = prefs.getString('user_key');
    final result = await Connectivity().checkConnectivity();
    if (result.single != ConnectivityResult.none) {
      if (user_key != null) {
        Get.off(() => chatScreen(),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: 500));
      } else {
        Get.off(() => welcomeScreen(),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: 500));
      }
    }
  }

  Future<void> refreshPage() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    await _checkInternetAndNavigate();

    await Future.delayed(Duration(seconds: 5));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: appColor.silver.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Remix.wifi_off_line,
                      size: 80,
                      color: appColor.white,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "No internet connection",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontSize: fontSize.subtitle_fs,
                        fontWeight: FontWeight.w600,
                        color: appColor.silver.withOpacity(0.5)),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Please check your internet connection and try again",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontSize: fontSize.body_fs,
                        fontWeight: FontWeight.w500,
                        color: appColor.silver.withOpacity(0.5)),
                  ),
                ),
                SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all<Size>(
                        Size.fromHeight(60),
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
                        appColor.silver.withOpacity(0.1),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                    onPressed: () {
                      refreshPage();
                    },
                    child: _isLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(appColor.black),
                          )
                        : Text(
                            "Retry",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: fontSize.subtitle_fs,
                                fontWeight: FontWeight.w600,
                                color: appColor.silver.withOpacity(0.5),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

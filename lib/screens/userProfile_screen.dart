import 'package:flutter/material.dart';
import 'package:friday_app/models/sharedPreferenced_data.dart';
import 'package:friday_app/screens/help_screen.dart';
import 'package:friday_app/screens/privacyPolicy_screen.dart';
import 'package:friday_app/screens/welcome_screen.dart';
import 'package:friday_app/utils/colors.dart';
import 'package:friday_app/utils/font_size.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userProfileScreen extends StatefulWidget {
  @override
  State<userProfileScreen> createState() => _userProfileScreenState();
}

class _userProfileScreenState extends State<userProfileScreen> {
  bool _isLoading = false;

  // Get user details from shared preferences
  Future<void> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedPreferencedData.user_displayName = prefs.getString('displayName');
    sharedPreferencedData.user_email = prefs.getString('email');
    sharedPreferencedData.user_profileUrl = prefs.getString('photoUrl');
    setState(() {
      _isLoading = false;
    });
  }

  // Remove user
  Future<String?> clearUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user_key = prefs.getString('user_key');
    prefs.remove('displayName');
    prefs.remove('email');
    prefs.remove('user_key');
    prefs.remove('photoUrl');
    return user_key;
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 13, right: 20, top: 20, bottom: 0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          overlayColor: WidgetStateProperty.all<Color>(
                            Colors.transparent,
                          ),
                          onTap: () {
                            // Get.off(
                            //   () => chatScreen(),
                            //   transition: Transition.leftToRight,
                            //   duration: Duration(milliseconds: 300),
                            // );
                            Get.back();
                          },
                          child: Icon(
                            Remix.arrow_left_s_line,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Settings",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: fontSize.subtitle_fs,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: Colors.transparent,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(appColor.black),
                        ),
                        Center(
                          child: Text(
                            "Wait a moment",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: fontSize.body_fs,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Divider(
                      thickness: 0.1,
                      color: appColor.silver,
                    ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: appColor.black,
                          ),
                          child: sharedPreferencedData.user_profileUrl == null
                              ? const Icon(
                                  Remix.user_line,
                                  color: appColor.black,
                                  size: 30,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    sharedPreferencedData.user_profileUrl
                                        .toString(),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          sharedPreferencedData.user_displayName.toString(),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: fontSize.subtitle_fs,
                              fontWeight: FontWeight.w600,
                              color: appColor.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "General",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: fontSize.body_fs,
                              fontWeight: FontWeight.w600,
                              color: appColor.silver.withOpacity(0.5),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 35,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Remix.mail_line,
                                color: appColor.silver.withOpacity(0.5),
                                size: 18,
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Email",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: fontSize.body_fs,
                                        fontWeight: FontWeight.w500,
                                        color: appColor.silver.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    sharedPreferencedData.user_email.toString(),
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: fontSize.subbody_fs,
                                        fontWeight: FontWeight.w500,
                                        color: appColor.silver.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 35,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Remix.bard_line,
                                color: appColor.silver.withOpacity(0.5),
                                size: 18,
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Subscription",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: fontSize.body_fs,
                                        fontWeight: FontWeight.w500,
                                        color: appColor.silver.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Free plan",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: fontSize.subbody_fs,
                                        fontWeight: FontWeight.w500,
                                        color: appColor.silver.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 35,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Remix.earth_line,
                                color: appColor.silver.withOpacity(0.5),
                                size: 18,
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Language",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: fontSize.body_fs,
                                        fontWeight: FontWeight.w500,
                                        color: appColor.silver.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "English(Default)",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: fontSize.subbody_fs,
                                        fontWeight: FontWeight.w500,
                                        color: appColor.silver.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          "About",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: fontSize.body_fs,
                              fontWeight: FontWeight.w600,
                              color: appColor.silver.withOpacity(0.5),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        InkWell(
                          overlayColor: WidgetStateProperty.all<Color>(
                            Colors.transparent,
                          ),
                          onTap: () {
                            Get.to(
                              () => helpScreen(),
                              transition: Transition.rightToLeft,
                              duration: Duration(milliseconds: 300),
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: 30,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Remix.question_line,
                                  color: appColor.silver.withOpacity(0.5),
                                  size: 18,
                                ),
                                SizedBox(width: 15),
                                Text(
                                  "Help",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: fontSize.body_fs,
                                      fontWeight: FontWeight.w500,
                                      color: appColor.silver.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Remix.arrow_right_s_line,
                                  color: appColor.silver.withOpacity(0.5),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 7),
                        InkWell(
                          overlayColor: WidgetStateProperty.all<Color>(
                            Colors.transparent,
                          ),
                          onTap: () {
                            Get.to(
                              () => privacyPolicyScreen(),
                              transition: Transition.rightToLeft,
                              duration: Duration(milliseconds: 300),
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: 30,
                            child: Row(
                              children: [
                                Icon(
                                  Remix.chat_private_line,
                                  color: appColor.silver.withOpacity(0.5),
                                  size: 18,
                                ),
                                SizedBox(width: 15),
                                Text(
                                  "Privacy Policy",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: fontSize.body_fs,
                                      fontWeight: FontWeight.w500,
                                      color: appColor.silver.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Remix.arrow_right_s_line,
                                  color: appColor.silver.withOpacity(0.5),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: SizedBox(
          width: double.infinity,
          child: TextButton(
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all<Size>(
                Size.fromHeight(55),
              ),
              backgroundColor: WidgetStateProperty.all<Color>(
                appColor.black,
              ),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            onPressed: () {
              clearUserInfo();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => welcomeScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: Row(
              children: [
                Icon(
                  Remix.logout_box_line,
                  color: appColor.white,
                  size: 18,
                ),
                Spacer(),
                Text(
                  "Sign out",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: fontSize.body_fs,
                      fontWeight: FontWeight.w500,
                      color: appColor.white,
                    ),
                  ),
                ),
                Spacer(),
                SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

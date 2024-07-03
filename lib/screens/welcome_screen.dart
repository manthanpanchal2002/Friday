import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friday_app/screens/chat_screen.dart';
import 'package:friday_app/screens/privacyPolicy_screen.dart';
import 'package:friday_app/utils/colors.dart';
import 'package:friday_app/utils/font_size.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class welcomeScreen extends StatefulWidget {
  @override
  State<welcomeScreen> createState() => _welcomeScreenState();
}

class _welcomeScreenState extends State<welcomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        user = event;
      });
    });
  }

  // Google SignIn Method
  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      user = userCredential.user;

      // Save user data to shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user_key', user!.uid);
      prefs.setString('displayName', user!.displayName.toString());
      prefs.setString('email', user!.email.toString());
      prefs.setString('photoUrl', user!.photoURL.toString());

      if (user?.uid != null) {
        // Login user
        Get.off(
          () => chatScreen(),
          transition: Transition.rightToLeft,
          duration: Duration(milliseconds: 300),
        );
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
                Container(
                  height: 100,
                  width: double.infinity,
                  child: Center(
                    child: Image.asset(
                      "assets/videos/FRIDAY welcome.gif",
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter Your Chat Space",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: fontSize.title_fs,
                            fontWeight: FontWeight.w700,
                            color: appColor.black,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Continue to sign in.",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: fontSize.subtitle_fs,
                              fontWeight: FontWeight.w500,
                              color: appColor.silver.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStateProperty.all<Color>(
                              Colors.transparent,
                            ),
                            minimumSize: WidgetStateProperty.all<Size>(
                              Size.fromHeight(45),
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                              appColor.silver.withOpacity(0.1),
                            ),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                          onPressed: _isLoading ? null : signInWithGoogle,
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      appColor.black),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Remix.google_fill,
                                      color: appColor.black,
                                      size: 15,
                                    ),
                                    SizedBox(width: 7),
                                    Text(
                                      "Continue with Google",
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: fontSize.body_fs,
                                          fontWeight: FontWeight.w500,
                                          color: appColor.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 7),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "By signing in, you are agree to our ",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: fontSize.body_fs,
                                  fontWeight: FontWeight.w500,
                                  color: appColor.silver.withOpacity(0.5),
                                ),
                              ),
                            ),
                            InkWell(
                              overlayColor: WidgetStateProperty.all<Color>(
                                Colors.transparent,
                              ),
                              onTap: () {
                                Get.to(
                                  () => privacyPolicyScreen(),
                                  transition: Transition.downToUp,
                                  duration: Duration(milliseconds: 300),
                                );
                              },
                              child: Text(
                                "Privacy Policy",
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: fontSize.body_fs,
                                    fontWeight: FontWeight.w500,
                                    color: appColor.black,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
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

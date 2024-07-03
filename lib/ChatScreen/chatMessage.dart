import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:friday_app/models/sharedPreferenced_data.dart';
import 'package:friday_app/utils/colors.dart';
import 'package:friday_app/utils/font_size.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class chartMessage extends StatefulWidget {
  const chartMessage(
      {super.key,
      required this.data,
      required this.sender,
      required this.promptForImage});

  final String data;
  final String sender;
  final String promptForImage;

  @override
  State<chartMessage> createState() => _chartMessageState();
}

class _chartMessageState extends State<chartMessage> {
  bool isCopy = false;
  bool isSpeech = false;

  FlutterTts flutterTts = FlutterTts();

  // Text to speech
  void initTTS() {
    flutterTts
        .setVoice({"gender": "female", "name": "karen", "locale": "en-AU"});
    flutterTts.setLanguage("en-AU");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeech = false;
      });
    });
  }

  // Start speech
  Future<void> textToSpeech() async {
    setState(() {
      isSpeech = true;
    });
    await flutterTts.speak(widget.data);
  }

  // Stop speech
  Future<void> stopSpeech() async {
    await flutterTts.stop();
    setState(() {
      isSpeech = false;
    });
  }

  // Get user details from shared preferences
  Future<void> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedPreferencedData.user_profileUrl = prefs.getString('photoUrl');
    if (mounted) {
      setState(() {});
    }
  }

  // Copy Text
  void _copyGeminiContent() {
    String geminiContent = widget.data;
    final content = ClipboardData(text: geminiContent);
    Clipboard.setData(content);

    setState(() {
      isCopy = true;
    });

    // After some delay set isCopy = false
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isCopy = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    initTTS();
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          widget.sender == 'error'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: appColor.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Remix.error_warning_line,
                                color: appColor.error,
                                size: 15,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                widget.data,
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: fontSize.subbody_fs,
                                    fontWeight: FontWeight.w500,
                                    color: appColor.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (widget.sender == 'user' || widget.sender == 'user-img')
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: Container(
                          height: 20,
                          width: 20,
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
                      ),
                    if (widget.sender == 'gemini')
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: sharedPreferencedData.user_profileUrl == null
                              ? const Icon(
                                  Remix.user_line,
                                  color: appColor.black,
                                  size: 30,
                                )
                              : Image.asset(
                                  "assets/images/FRIDAY representator Logo.png",
                                  height: 15,
                                ),
                        ),
                      ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: widget.sender == 'gemini'
                          ? Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: appColor.silver.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SelectableText(
                                    widget.data,
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: fontSize.body_fs,
                                        fontWeight: FontWeight.w500,
                                        color: appColor.black,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        overlayColor:
                                            WidgetStateProperty.all<Color>(
                                          Colors.transparent,
                                        ),
                                        onTap: () {
                                          _copyGeminiContent();
                                        },
                                        child: Icon(
                                          isCopy
                                              ? Remix.check_line
                                              : Remix.file_copy_line,
                                          color:
                                              appColor.silver.withOpacity(0.5),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      isSpeech
                                          ? InkWell(
                                              overlayColor: WidgetStateProperty
                                                  .all<Color>(
                                                Colors.transparent,
                                              ),
                                              onTap: () {
                                                stopSpeech();
                                              },
                                              child: Icon(
                                                Remix.stop_circle_line,
                                                color: appColor.silver
                                                    .withOpacity(0.5),
                                                size: 15,
                                              ),
                                            )
                                          : InkWell(
                                              overlayColor: WidgetStateProperty
                                                  .all<Color>(
                                                Colors.transparent,
                                              ),
                                              onTap: () {
                                                textToSpeech();
                                              },
                                              child: Icon(
                                                Remix.volume_up_line,
                                                color: appColor.silver
                                                    .withOpacity(0.5),
                                                size: 18,
                                              ),
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: appColor.silver.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              padding: const EdgeInsets.all(15),
                              child: widget.sender == 'user'
                                  ? SelectableText(
                                      widget.data,
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: fontSize.body_fs,
                                          fontWeight: FontWeight.w500,
                                          color: appColor.black,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InstaImageViewer(
                                          child: Image.file(
                                            File(widget.data),
                                            height: 200,
                                            width: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        SelectableText(
                                          widget.promptForImage,
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
                  ],
                ),
        ],
      ),
    );
  }
}

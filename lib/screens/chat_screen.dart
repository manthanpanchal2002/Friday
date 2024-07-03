import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:friday_app/ChatScreen/chatMessage.dart';
import 'package:friday_app/Credientials/api_key.dart';
import 'package:friday_app/models/sharedPreferenced_data.dart';
import 'package:friday_app/screens/subscription_screen.dart';
import 'package:friday_app/screens/userProfile_screen.dart';
import 'package:friday_app/utils/colors.dart';
import 'package:friday_app/utils/font_size.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class chatScreen extends StatefulWidget {
  const chatScreen({super.key});

  @override
  State<chatScreen> createState() => _chatScreenState();
}

// Show Greeting
String generateGreeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good morning,';
  } else if (hour < 17) {
    return 'Good afternoon,';
  } else {
    return 'Good evening,';
  }
}

class _chatScreenState extends State<chatScreen> {
  String greeting = generateGreeting();
  SpeechToText speechToText = SpeechToText();
  final TextEditingController _controller = TextEditingController();
  final List<chartMessage> _messages = [];
  bool _isLoading = false;
  bool _isText = false;
  bool _isImage = false;
  bool _isSpeech = false;
  String? imagePath;
  String? prompt;
  Uint8List? imageBytes;
  XFile? file;
  String lastWords = '';
  Timer? _micTimer;

  // Connect with Gemini
  final apiKey = Platform.environment[GEMINI_API_KEY];

  final model =
      GenerativeModel(model: 'gemini-1.5-pro', apiKey: GEMINI_API_KEY);

  // Get user details from shared preferences
  Future<void> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedPreferencedData.user_profileUrl = prefs.getString('photoUrl');
    if (mounted) {
      setState(() {});
    }
  }

  // Initilize Speech to text
  Future<void> initilizeSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  // Start a speech recognition session
  Future<void> startListening() async {
    await speechToText.listen(
      onResult: onSpeechResult,
      listenFor: Duration(milliseconds: 5000),
    );
    setState(() {
      _isSpeech = true;
      _startMicIconTimer();
    });
  }

  // Set timer
  void _startMicIconTimer() {
    _micTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        _isSpeech = false;
      });
    });
  }

  // Manually stop the active speech recognition session
  Future<void> stopListening() async {
    await speechToText.stop();
    if (_micTimer != null && _micTimer!.isActive) {
      _micTimer!.cancel();
    }
    setState(() {
      _isSpeech = false;
    });
  }

  // Save data to lasWords
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
    _controller.text = lastWords;

    if (result.finalResult) {
      _sendMessage();
    }
    setState(() {});
  }

  // Function to clean the response text
  String _cleanResponseText(String text) {
    return text.replaceAll('*', '');
  }

  // Send Message to Gemini
  Future<void> _sendMessage() async {
    // Pass message to model
    final content = Content.text(_controller.text);

    // Check if the text field is not empty and if it is not empty, add the message to the chat screen
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.insert(
            0,
            chartMessage(
              promptForImage: "",
              data: _controller.text,
              sender: "user",
            ));
        _controller.clear();
        _isLoading = true;
        _isText = false;
        _isSpeech = false;
      });

      // Gemini Response
      final response = await model.generateContent([content]);

      if (_isLoading) {
        // Add the response from Gemini to the chat screen
        setState(() {
          try {
            // Clean the response text
            String cleanedResponse =
                _cleanResponseText(response.text.toString());
            _messages.insert(
              0,
              chartMessage(
                promptForImage: "",
                data: cleanedResponse.toString(),
                sender: "gemini",
              ),
            );
            _isLoading = false;
          } catch (e) {
            print(e);
            _isLoading = false;
            _messages.insert(
              0,
              chartMessage(
                promptForImage: "",
                data: e.toString().replaceAll('GenerativeAIException: ', ''),
                sender: "error",
              ),
            );
          }
        });
      }
    }
  }

  // stop displaying gemini responses user clicks on stop button
  void stopGeminiResponses() {
    setState(() {
      _messages.insert(
        0,
        chartMessage(
          promptForImage: "",
          data: 'Responses have been stopped',
          sender: "error",
        ),
      );
    });
  }

  // Clear messages
  void clearMessages() {
    setState(() {
      _messages.clear();
      _isText = false;
      _isImage = false;
    });
  }

  void _selectImage() async {
    ImagePicker picker = ImagePicker();
    file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) {
      return;
    }

    imagePath = file!.path;

    imageBytes =
        (await File(file!.path.toString()).readAsBytes()) as Uint8List?;

    setState(() {
      _isImage = true;
    });
  }

  // Image picker function
  void _sendImage(String? prompt) async {
    // prompt = _controller.text;
    setState(() {
      _messages.insert(
          0,
          chartMessage(
            promptForImage: prompt.toString(),
            data: file!.path.toString(),
            sender: "user-img",
          ));
      _isLoading = true;
      _isImage = false;
      _isText = false;
      _controller.clear();
    });

    final content = [
      Content.multi([
        TextPart(prompt.toString()),
        DataPart('image/png', imageBytes as Uint8List),
      ])
    ];
    final response = await model.generateContent(content);

    // Add the response from Gemini to the chat screen
    setState(
      () {
        try {
          // Clean the response text
          String cleanedResponse = _cleanResponseText(response.text.toString());
          _messages.insert(
              0,
              chartMessage(
                promptForImage: "",
                data: cleanedResponse.toString(),
                sender: "gemini",
              ));
          _isLoading = false;
        } catch (e) {
          print(e);
          _isLoading = false;
          _messages.insert(
            0,
            chartMessage(
              promptForImage: "",
              data: 'An internal error has occurred',
              sender: "error",
            ),
          );
        }
      },
    );
  }

  // Show dialog when user is offline
  void showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: appColor.white,
          title: Text(
            "No Internet Connection",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: fontSize.subtitle_fs,
                fontWeight: FontWeight.w500,
                color: appColor.black,
              ),
            ),
          ),
          content: Text(
            "Please check your internet connection and try again",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: fontSize.body_fs,
                fontWeight: FontWeight.w500,
                color: appColor.black,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: fontSize.body_fs,
                    fontWeight: FontWeight.w500,
                    color: appColor.black,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                overlayColor: appColor.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    checkInternetConnection();
    initilizeSpeechToText();
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
  }

  // Check internet connection
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult.single == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: appColor.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        overlayColor: WidgetStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                        onTap: () {
                          Get.to(
                            () => userProfileScreen(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                        child: Container(
                          height: 25,
                          width: 25,
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
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        overlayColor: WidgetStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                        onTap: () {
                          clearMessages();
                        },
                        child: Icon(
                          Remix.chat_new_line,
                          color: appColor.silver.withOpacity(0.2),
                          size: 25,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 150,
                        height: 30,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    appColor.mainColor_1,
                                    appColor.mainColor_2
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(
                                  () => subscriptionScreen(),
                                  transition: Transition.rightToLeft,
                                  duration: const Duration(milliseconds: 300),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.white, // Inner container color
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/FRIDAY representator Logo.png',
                                          height: 25,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        ShaderMask(
                                          shaderCallback: (bounds) =>
                                              const LinearGradient(
                                            colors: [
                                              appColor.mainColor_1,
                                              appColor.mainColor_2
                                            ],
                                          ).createShader(bounds),
                                          child: Text(
                                            "Upgrade Plans",
                                            style: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  fontSize: fontSize.body_fs,
                                                  fontWeight: FontWeight.w500,
                                                  color: appColor.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),

            // Chat UI
            Flexible(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: fontSize.title_fs,
                                fontWeight: FontWeight.w700,
                                color: appColor.silver.withOpacity(0.2),
                              ),
                            ),
                          ),
                          Text(
                            "How can I help you?",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: fontSize.title_fs,
                                fontWeight: FontWeight.w700,
                                color: appColor.silver.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 15),
                      child: ListView.builder(
                        reverse: true,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _messages[index];
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).viewInsets.left + 20,
          right: MediaQuery.of(context).viewInsets.right + 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isLoading
                ? Padding(
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 8, right: 4, left: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "assets/videos/FRIDAY welcome.gif",
                              height: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "FRIDAY",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: fontSize.body_fs,
                                  fontWeight: FontWeight.w700,
                                  color: appColor.black,
                                ),
                              ),
                            ),
                            Text(
                              " is typing...",
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
                        const SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () {
                            stopGeminiResponses();
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          child: Icon(
                            Remix.stop_circle_line,
                            size: 20,
                            color: appColor.black,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      _isSpeech
                          ? InkWell(
                              overlayColor: WidgetStateProperty.all<Color>(
                                Colors.transparent,
                              ),
                              onTap: () {
                                setState(() {
                                  _isSpeech = false;
                                });
                                stopListening();
                              },
                              child: Icon(
                                Remix.close_circle_line,
                                size: 20,
                                color: appColor.black,
                              ),
                            )
                          : InkWell(
                              overlayColor: WidgetStateProperty.all<Color>(
                                Colors.transparent,
                              ),
                              onTap: () async {
                                if (await checkInternetConnection()) {
                                  setState(() {
                                    _isSpeech = true;
                                  });
                                  startListening();
                                } else {
                                  showNoInternetDialog();
                                }
                              },
                              child: Icon(
                                Remix.mic_2_line,
                                size: 20,
                                color: appColor.silver.withOpacity(0.5),
                              ),
                            ),
                      Spacer(),
                      _isSpeech
                          ? Container(
                              color: appColor.white,
                              width: MediaQuery.of(context).size.width * 0.80,
                              child: Image.asset(
                                'assets/videos/Frequency.gif',
                              ),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.80,
                              // height: 50,
                              decoration: BoxDecoration(
                                color: appColor.silver.withOpacity(0.1),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 18, bottom: 18),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight:
                                              80, // Maximum height for the TextField
                                        ),
                                        child: Scrollbar(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            reverse: true,
                                            child: TextField(
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                  fontSize: fontSize.body_fs,
                                                  fontWeight: FontWeight.w500,
                                                  color: appColor.black,
                                                ),
                                              ),
                                              controller: _controller,
                                              maxLines: null,
                                              onSubmitted: (value) {
                                                setState(() {
                                                  _isText = value.isNotEmpty;
                                                });
                                                _sendMessage();
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  _isText = value.isNotEmpty;
                                                });
                                              },
                                              decoration:
                                                  InputDecoration.collapsed(
                                                hintText: 'Enter prompt',
                                                hintStyle: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                    fontSize: fontSize.body_fs,
                                                    fontWeight: FontWeight.w500,
                                                    color: appColor.silver
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          overlayColor:
                                              WidgetStateProperty.all<Color>(
                                            Colors.transparent,
                                          ),
                                          onTap: () async {
                                            if (await checkInternetConnection()) {
                                              _selectImage();
                                            } else {
                                              showNoInternetDialog();
                                            }
                                          },
                                          child:
                                              // replace icon with selected image
                                              _isImage
                                                  ? Container(
                                                      height: 18,
                                                      width: 18,
                                                      child: ClipRRect(
                                                        child: Image.file(
                                                          File(imagePath
                                                              .toString()),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    )
                                                  : Icon(
                                                      Remix.image_add_line,
                                                      size: 18,
                                                      color: appColor.silver
                                                          .withOpacity(0.5),
                                                    ),
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        InkWell(
                                          overlayColor:
                                              WidgetStateProperty.all<Color>(
                                            Colors.transparent,
                                          ),
                                          onTap: () async {
                                            if (await checkInternetConnection()) {
                                              _isImage
                                                  ? _sendImage(_controller.text)
                                                  : _sendMessage();
                                            } else {
                                              showNoInternetDialog();
                                            }
                                          },
                                          child: Icon(
                                            _isText || _isImage
                                                ? Remix.send_plane_2_fill
                                                : Remix.send_plane_2_line,
                                            size: 18,
                                            color: _isText || _isImage
                                                ? appColor.black
                                                : appColor.silver
                                                    .withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 35,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: appColor.warning.withOpacity(0.1),
                borderRadius: const BorderRadius.all(
                  Radius.circular(7),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Remix.information_line,
                      size: 15,
                      color: appColor.warning,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "*FRIDAY",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: fontSize.subbody_fs,
                          fontWeight: FontWeight.w700,
                          color: appColor.warning,
                        ),
                      ),
                    ),
                    Text(
                      " may display inaccurate information.",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: fontSize.subbody_fs,
                          fontWeight: FontWeight.w500,
                          color: appColor.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

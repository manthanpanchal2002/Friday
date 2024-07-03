import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:friday_app/models/help_model.dart';
import 'package:friday_app/utils/colors.dart';
import 'package:friday_app/utils/font_size.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class helpScreen extends StatefulWidget {
  @override
  State<helpScreen> createState() => _helpScreenState();
}

class _helpScreenState extends State<helpScreen> {
  DatabaseReference dfRef = FirebaseDatabase.instance.ref();
  List<db_data_help> db_data_help_list = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    retrieve_help_data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            Get.back();
                          },
                          child: Icon(Remix.arrow_left_s_line),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Help",
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
              for (int i = 0; i < db_data_help_list.length; i++)
                i == 0
                    ? helpWidgetTitle(db_data_help_list[0])
                    : helpWidget(db_data_help_list[i]),
              SizedBox(
                height: 15,
              )
            ],
          ),
        ),
      ),
    );
  }

  // Fetch data from the database
  void retrieve_help_data() {
    setState(() {
      _isLoading = true;
    });
    dfRef.child('help_content').onChildAdded.listen(
      (data) {
        data_Help data_help = data_Help.fromJson(data.snapshot.value as Map);
        db_data_help_list.add(
          db_data_help(
            key: data.snapshot.key,
            data_help: data_help,
          ),
        );
        setState(
          () {
            _isLoading = false;
          },
        );
      },
    );
  }
}

// Display Title
Widget helpWidgetTitle(db_data_help db_data_help_list) {
  return Padding(
    padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 15),
    child: Text(
      db_data_help_list.data_help!.title.toString(),
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
            fontSize: fontSize.subtitle_fs,
            fontWeight: FontWeight.w600,
            color: appColor.black),
      ),
    ),
  );
}

// Display Content
Widget helpWidget(db_data_help db_data_help_list) {
  return Padding(
    padding: EdgeInsets.only(
      top: 15,
      left: 20,
      right: 20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          db_data_help_list.data_help!.que.toString(),
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                fontSize: fontSize.body_fs,
                fontWeight: FontWeight.w600,
                color: appColor.black),
          ),
        ),
        Text(
          db_data_help_list.data_help!.ans.toString(),
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                fontSize: fontSize.body_fs,
                fontWeight: FontWeight.w500,
                color: appColor.silver.withOpacity(0.5)),
          ),
        ),
      ],
    ),
  );
}

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:friday_app/models/subscription_model.dart';
import 'package:friday_app/utils/colors.dart';
import 'package:friday_app/utils/font_size.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class subscriptionScreen extends StatefulWidget {
  @override
  State<subscriptionScreen> createState() => _subscriptionScreenState();
}

class _subscriptionScreenState extends State<subscriptionScreen> {
  DatabaseReference dfRef = FirebaseDatabase.instance.ref();
  List<db_data_subscription> db_data_subscription_list = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    retrieve_subscription_data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 0xfffcfcfc
      backgroundColor: Color(0xfffcfcfc),
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
                          "Upgrade Plans",
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
                      color: appColor.black,
                    ),
              for (int i = 0; i < db_data_subscription_list.length; i++)
                Padding(
                  padding: i == 0
                      ? const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 0)
                      : const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 15),
                  child: Column(
                    children: [
                      i == 0
                          ? FirstCard(db_data_subscription_list[0])
                          : SecondCard(db_data_subscription_list[i]),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Fetch data from the database
  void retrieve_subscription_data() {
    setState(() {
      _isLoading = true;
    });
    dfRef.child('upgrade_plan_content').onChildAdded.listen(
      (data) {
        data_Subscription data_subscription =
            data_Subscription.fromJson(data.snapshot.value as Map);
        db_data_subscription_list.add(
          db_data_subscription(
            key: data.snapshot.key,
            data_subscription: data_subscription,
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

// First Price Card
Widget FirstCard(db_data_subscription db_data_subscription_list) {
  return Container(
    width: double.infinity,
    height: 470,
    decoration: BoxDecoration(
      color: appColor.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                db_data_subscription_list.data_subscription!.logo.toString(),
                height: 60,
              ),
              Text(
                db_data_subscription_list.data_subscription!.subtitle
                    .toString(),
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: fontSize.body_fs,
                    fontWeight: FontWeight.w500,
                    color: appColor.silver.withOpacity(0.5),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          height: 320,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: appColor.mainColor_1.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  db_data_subscription_list
                                      .data_subscription!.cost
                                      .toString(),
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: fontSize.subtitle_fs,
                                      fontWeight: FontWeight.w600,
                                      color: appColor.black,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "per month",
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
                            SizedBox(height: 15),
                            Column(
                              children: [
                                for (var services in db_data_subscription_list
                                    .data_subscription!.services) ...[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Remix.check_fill,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Text(
                                          services,
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: fontSize.body_fs,
                                              fontWeight: FontWeight.w500,
                                              color: appColor.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all<Color>(
                                Colors.white,
                              ),
                              minimumSize: WidgetStateProperty.all<Size>(
                                Size.fromHeight(50),
                              ),
                              backgroundColor: WidgetStateProperty.all<Color>(
                                appColor.white,
                              ),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              "Current Plan",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: fontSize.body_fs,
                                  fontWeight: FontWeight.w600,
                                  color: appColor.silver.withOpacity(0.5),
                                ),
                              ),
                            ),
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
      ],
    ),
  );
}

// Second Price Card
Widget SecondCard(db_data_subscription db_data_subscription_list) {
  return Container(
    width: double.infinity,
    height: 470,
    decoration: BoxDecoration(
      color: appColor.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                db_data_subscription_list.data_subscription!.logo.toString(),
                height: 60,
              ),
              Text(
                db_data_subscription_list.data_subscription!.subtitle
                    .toString(),
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: fontSize.body_fs,
                    fontWeight: FontWeight.w500,
                    color: appColor.silver.withOpacity(0.5),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          height: 320,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: appColor.mainColor_2.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  db_data_subscription_list
                                      .data_subscription!.cost
                                      .toString(),
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: fontSize.subtitle_fs,
                                      fontWeight: FontWeight.w600,
                                      color: appColor.black,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "per month",
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
                            SizedBox(height: 15),
                            Column(
                              children: [
                                for (var services in db_data_subscription_list
                                    .data_subscription!.services) ...[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Remix.check_fill,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Text(
                                          services,
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontSize: fontSize.body_fs,
                                              fontWeight: FontWeight.w500,
                                              color: appColor.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all<Color>(
                                Colors.white,
                              ),
                              minimumSize: WidgetStateProperty.all<Size>(
                                Size.fromHeight(50),
                              ),
                              backgroundColor: WidgetStateProperty.all<Color>(
                                appColor.white,
                              ),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              "Upgrade Plan",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: fontSize.body_fs,
                                  fontWeight: FontWeight.w600,
                                  color: appColor.black,
                                ),
                              ),
                            ),
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
      ],
    ),
  );
}

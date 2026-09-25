import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kalady_kiosk/color_pallatte.dart';
import 'package:kalady_kiosk/extension.dart';
import 'package:kalady_kiosk/fontpallate.dart';
import 'package:kalady_kiosk/provider/homeprovider.dart';
import 'package:kalady_kiosk/services/helpers.dart';
import 'package:kalady_kiosk/services/shared_preference_helper.dart';
import 'package:kalady_kiosk/view/loginscreen.dart';
import 'package:kalady_kiosk/view/selectedscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    getCounterID();
    super.initState();
  }

  getCounterID() async {
    String id = await SharedPreferenceHelper.getCounterID();
    if (id == '') {
      _showCounters();
    }
  }

  String? _chosenValue;
  String? selectedCounterID;
  void _showCounters() {
    Future.microtask(() {
      context.read<HomeProvider>().getCounter().then((value) {
        showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return PopScope(
                  canPop: false,
                  child: Consumer<HomeProvider>(
                    builder: (context, provider, _) {
                      return AlertDialog(
                        title: Text(
                          "Choose Counter",
                          style: Fontpalette.blackinter45400,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Please select a counter.",
                              style: Fontpalette.blackinter40400,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DropdownButton<String>(
                                hint: Text(
                                  'Select',
                                  style: Fontpalette.blackinter28400,
                                ),
                                value: _chosenValue,
                                underline: Container(),
                                items:
                                    provider.counterName.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: Fontpalette.blackinter30600,
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) async {
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  setState(() {
                                    _chosenValue = value;
                                    for (
                                      int i = 0;
                                      i < provider.counterName.length;
                                      i++
                                    ) {
                                      if (provider.counterName[i] ==
                                          _chosenValue) {
                                        selectedCounterID =
                                            provider.counterId[i];

                                        prefs.setString(
                                          "counterid",
                                          selectedCounterID.toString(),
                                        );
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: Text(
                                    "SAVE",
                                    style: Fontpalette.blackinter42700,
                                  ),
                                  onPressed: () async {
                                    if ((selectedCounterID != null)) {
                                      await SharedPreferenceHelper.saveCounterID(
                                        selectedCounterID ?? "",
                                      ).then((value) async {
                                        Navigator.of(context).pop();
                                      });
                                    } else {
                                      Helpers.successToast(
                                        "Should Select Counter",
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topCenter,
            end: AlignmentDirectional.bottomCenter,
            colors: [
              const Color.fromARGB(255, 243, 233, 98),
              const Color.fromARGB(255, 244, 245, 199), // Start color
              Colors.white,
              Colors.white, // End color
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 470.h,
              left: -330.w,
              child: Container(
                height: 202.h,
                width: 702.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/images/flwr.png"),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 470.h,
              right: -330.w,
              child: Container(
                height: 202.h,
                width: 702.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/images/flwr.png"),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      20.verticalSpace,
                      Row(
                        children: [
                          Container(
                            height: 69.h,
                            width: 69.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage(
                                  "assets/images/kalady_logo.jpg",
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text("Kalady Sri Adi Shankara\n Madom, Telangana",
                                  style: Fontpalette.appheading,)
                        ],
                      ),
                      10.verticalSpace,
                      Container(
                        height: 500.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 10.h),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6.r),
                            topRight: Radius.circular(6.r),
                            bottomLeft: Radius.circular(113.r),
                            bottomRight: Radius.circular(113.r),
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(
                              "assets/images/adishankaratemple.jpeg",
                            ),
                          ),
                        ),
                      ),
                      10.verticalSpace,
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(45.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                //old id 64 font size
                                Text(
                                  "Kalady Sri Adi Shankara Madom Telangana",
                                  style: Fontpalette.brown70700,
                                ),
                                Text(
                                  "Sri.Sri. Jagadguru Adi Shankaracharya MahaSamsthanam",
                                  style: Fontpalette.grey45600,
                                ),
                              ],
                            ).verticalPadding(30.h).horizontalPadding(40.w),
                          ],
                        ),
                      ),
                      60.verticalSpace,

                      Text(
                        "Choose your language",
                        style: Fontpalette.brown45600,
                      ),
                      15.verticalSpace,
                      Stack(
                        children: [
                          Positioned(
                            top: 42.h,
                            right: 0,
                            child: Transform(
                              alignment: Alignment.center,
                              transform:
                                  Matrix4.identity()..scale(
                                    -1.0,
                                    1.0,
                                    1.0,
                                  ), // Mirror horizontally
                              child: Container(
                                height: 50.h,
                                width: 220.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.contain,
                                    image: AssetImage(
                                      "assets/images/sideflwr.png",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 42.h,
                            left: 0,
                            child: Container(
                              height: 50.h,
                              width: 220.w,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: AssetImage(
                                    "assets/images/sideflwr.png",
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap:
                                          () => navigatescrren(
                                            page: LanguageSelectedScreen(
                                              lanid: 1,
                                            ),
                                            context: context,
                                          ),

                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: HexColor("#EC5002"),
                                          borderRadius: BorderRadius.circular(
                                            27.r,
                                          ),
                                          border: Border.all(
                                            color: HexColor("#F8A300"),
                                            width: 4.h,
                                          ),
                                        ),
                                        height: 60.h,
                                        child: Center(
                                          child: Text(
                                            "English",
                                            style: Fontpalette.white45500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  50.horizontalSpace,
                                  Expanded(
                                    child: InkWell(
                                      onTap:
                                          () => navigatescrren(
                                            page: LanguageSelectedScreen(
                                              lanid: 0,
                                            ),
                                            context: context,
                                          ),

                                      child: Container(
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          color: HexColor("#EC5002"),
                                          borderRadius: BorderRadius.circular(
                                            27.r,
                                          ),
                                          border: Border.all(
                                            color: HexColor("#F8A300"),
                                            width: 4.h,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "తెలుగు",
                                            style: Fontpalette.white45500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              7.verticalSpace,
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      HexColor("#EC5002"),
                                      Colors.white,
                                    ],
                                  ),
                                ),
                              ),
                              30.verticalSpace,
                            ],
                          ).horizontalPadding(200.w),
                        ],
                      ),
                    ],
                  ),
                  40.verticalSpace,
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          SharedPreferenceHelper.clearWholeData();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: HexColor("#EC5002"),
                            borderRadius: BorderRadius.circular(27.r),
                            border: Border.all(
                              color: HexColor("#F8A300"),
                              width: 4.h,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 40.w,
                              ),
                              10.horizontalSpace,
                              Text("Logout", style: Fontpalette.white45500),
                            ],
                          ),
                        ),
                      ),
                      15.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onLongPress: () {
                              SharedPreferenceHelper.clearWholeData();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Container(
                              height: 107.h,
                              width: 500.w,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: AssetImage(
                                    "assets/images/logowithname.png",
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                                  height: 107.h,
                                  width: 500.w,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: AssetImage(
                                        "assets/images/sbi.jpeg",
                                      ),
                                    ),
                                  ),
                          ),
                          Text(
                            "www.punnyamtemplesuite.com",
                            style: Fontpalette.brown30600,
                          ),
                        ],
                      ),
                      SizedBox(height: 40,)
                      // Center(
                      //   child: Container(
                      //           height: 107.h,
                      //           width: 500.w,
                      //           decoration: BoxDecoration(
                      //             image: DecorationImage(
                      //               fit: BoxFit.contain,
                      //               image: AssetImage(
                      //                 "assets/images/sbi.jpeg",
                      //               ),
                      //             ),
                      //           ),
                      //   ),
                      // ),
                    ],
                  ).horizontalPadding(100.w),
                ],
              ),
            ).horizontalPadding(90.w).topPadding(40.h).bottomPadding(5.h),
          ],
        ),
      ),
    );
  }
}

navigatescrren({BuildContext? context, required page}) {
  Navigator.of(context!).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

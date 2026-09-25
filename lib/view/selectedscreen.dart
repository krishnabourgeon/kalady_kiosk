// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:kalady_kiosk/color_pallatte.dart';
// // import 'package:kalady_kiosk/extension.dart';
// // import 'package:kalady_kiosk/fontpallate.dart';
// // import 'package:kalady_kiosk/provider/homeprovider.dart';
// // import 'package:kalady_kiosk/view/bookpooja.dart';
// // import 'package:kalady_kiosk/view/homepage.dart';
// // import 'package:provider/provider.dart';

// // class LanguageSelectedScreen extends StatefulWidget {
// //   const LanguageSelectedScreen({super.key, this.lanid});
// //   final int? lanid;
// //   @override
// //   State<LanguageSelectedScreen> createState() => _LanguageSelectedScreenState();
// // }

// // class _LanguageSelectedScreenState extends State<LanguageSelectedScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: AlignmentDirectional.topCenter,
// //             end: AlignmentDirectional.bottomCenter,
// //             colors: [
// //               const Color.fromARGB(255, 243, 233, 98),
// //               const Color.fromARGB(255, 244, 245, 199),
// //               Colors.white,
// //               Colors.white,
// //             ],
// //           ),
// //         ),
// //         child: Stack(
// //           children: [
// //             Positioned(
// //               top: -60.h,
// //               right: -250.w,
// //               child: Container(
// //                 height: 220.h,
// //                 width: 702.w,
// //                 decoration: BoxDecoration(
// //                   image: DecorationImage(
// //                     fit: BoxFit.fill,
// //                     image: AssetImage("assets/images/flwr.png"),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             Positioned(
// //               top: 470.h,
// //               left: -330.w,
// //               child: Container(
// //                 height: 202.h,
// //                 width: 702.w,
// //                 decoration: BoxDecoration(
// //                   image: DecorationImage(
// //                     fit: BoxFit.fill,
// //                     image: AssetImage("assets/images/flwr.png"),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             Positioned(
// //               top: 470.h,
// //               right: -330.w,
// //               child: Container(
// //                 height: 202.h,
// //                 width: 702.w,
// //                 decoration: BoxDecoration(
// //                   image: DecorationImage(
// //                     fit: BoxFit.fill,
// //                     image: AssetImage("assets/images/flwr.png"),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             Consumer<HomeProvider>(
// //               builder:
// //                   (context, home, child) => SingleChildScrollView(
// //                     child: Column(
// //                       children: [
// //                         Column(
// //                           children: [
// //                             20.verticalSpace,
// //                             Row(
// //                               children: [
// //                                 Container(
// //                                   height: 69.h,
// //                                   width: 69.h,
// //                                   decoration: BoxDecoration(
// //                                     shape: BoxShape.circle,
// //                                     color: Colors.white,
// //                                     boxShadow: [
// //                                       BoxShadow(
// //                                         color: Colors.black26,
// //                                         blurRadius: 6,
// //                                         offset: const Offset(0, 2),
// //                                       ),
// //                                     ],
// //                                     image: DecorationImage(
// //                                       fit: BoxFit.contain,
// //                                       image: AssetImage(
// //                                         "assets/images/kalady_logo.jpg",
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 SizedBox(width: 10),
// //                                 Text(
// //                                   "Kalady Sri Adi Shankara\n Madom, Telangana",
// //                                   style: Fontpalette.appheading,
// //                                 ),
// //                               ],
// //                             ),
// //                             10.verticalSpace,
// //                             Container(
// //                               height: 500.h,
// //                               decoration: BoxDecoration(
// //                                 color: Colors.red,
// //                                 border: Border.all(
// //                                   color: Colors.white,
// //                                   width: 10.h,
// //                                 ),
// //                                 borderRadius: BorderRadius.only(
// //                                   topLeft: Radius.circular(6.r),
// //                                   topRight: Radius.circular(6.r),
// //                                   bottomLeft: Radius.circular(113.r),
// //                                   bottomRight: Radius.circular(113.r),
// //                                 ),
// //                                 image: DecorationImage(
// //                                   fit: BoxFit.cover,
// //                                   image: AssetImage(
// //                                     "assets/images/adishankaratemple.jpeg",
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             10.verticalSpace,
// //                             Container(
// //                               decoration: BoxDecoration(
// //                                 color: Colors.white,
// //                                 borderRadius: BorderRadius.circular(45.r),
// //                               ),
// //                               child: Row(
// //                                 mainAxisAlignment: MainAxisAlignment.center,
// //                                 children: [
// //                                   Column(
// //                                     children: [
// //                                       Text(
// //                                         "Kalady Sri Adi Shankara Madom Telangana",
// //                                         style: Fontpalette.brown70700,
// //                                       ),
// //                                       Text(
// //                                         "Sri.Sri. Jagadguru Adi Shankaracharya MahaSamsthanam",
// //                                         style: Fontpalette.grey45600,
// //                                       ),
// //                                     ],
// //                                   ).verticalPadding(30.h),
// //                                 ],
// //                               ),
// //                             ),
// //                             60.verticalSpace,

// //                             Stack(
// //                               children: [
// //                                 Column(
// //                                   children: [
// //                                     Row(
// //                                       children: [
// //                                         Row(
// //                                           mainAxisAlignment:
// //                                               MainAxisAlignment.center,
// //                                           children: [
// //                                             InkWell(
// //                                               onTap: () {
// //                                                 home.clearStoredData();
// //                                                 home.clearGrossAmount();
// //                                                 navigatescrren(
// //                                                   context: context,
// //                                                   page: Bookpoojascreen(
// //                                                     lanid: widget.lanid,
// //                                                     isDonate: true,
// //                                                   ),
// //                                                 );
// //                                               },
// //                                               child: Container(
// //                                                 width: 600.w,
// //                                                 decoration: BoxDecoration(
// //                                                   color: HexColor("#EC5002"),
// //                                                   borderRadius:
// //                                                       BorderRadius.circular(
// //                                                         27.r,
// //                                                       ),
// //                                                   border: Border.all(
// //                                                     color: HexColor("#F8A300"),
// //                                                     width: 4.h,
// //                                                   ),
// //                                                 ),
// //                                                 height: 60.h,
// //                                                 child: Center(
// //                                                   child: Text(
// //                                                     widget.lanid == 1
// //                                                         ? "ANNADHANAM (donate)"
// //                                                         : "అన్నదానం (విరాళం ఇవ్వండి)",
// //                                                     style:
// //                                                         Fontpalette.white45500,
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                         //   ],
// //                                         // ),
// //                                         // 7.verticalSpace,
// //                                         // Container(
// //                                         //   height: 1,
// //                                         //   width: 600.w,
// //                                         //   decoration: BoxDecoration(
// //                                         //     gradient: LinearGradient(
// //                                         //       colors: [
// //                                         //         Colors.white,
// //                                         //         HexColor("#EC5002"),
// //                                         //         Colors.white,
// //                                         //       ],
// //                                         //     ),
// //                                         //   ),
// //                                         // ),
// //                                         SizedBox(width: 10.h),
// //                                         Row(
// //                                           mainAxisAlignment:
// //                                               MainAxisAlignment.center,
// //                                           children: [
// //                                             InkWell(
// //                                               onTap: () {
// //                                                 // home.clearStoredData();
// //                                                 // home.clearGrossAmount();
// //                                                 // navigatescrren(
// //                                                 //   context: context,
// //                                                 //   page: Bookpoojascreen(
// //                                                 //     lanid: widget.lanid,
// //                                                 //     isDonate: true,
// //                                                 //   ),
// //                                                 // );
// //                                               },
// //                                               child: Container(
// //                                                 decoration: BoxDecoration(
// //                                                   color: HexColor("#EC5002"),
// //                                                   borderRadius:
// //                                                       BorderRadius.circular(
// //                                                         27.r,
// //                                                       ),
// //                                                   border: Border.all(
// //                                                     color: HexColor("#F8A300"),
// //                                                     width: 4.h,
// //                                                   ),
// //                                                 ),
// //                                                 height: 60.h,
// //                                                 width: 600.w,
// //                                                 child: Center(
// //                                                   child: Text(
// //                                                     widget.lanid == 1
// //                                                         ? "ADWAITHA SANGAMAM"
// //                                                         : "అద్వైత సంగమం",
// //                                                     style:
// //                                                         Fontpalette.white45500,
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ],
// //                                     ),
// //                                     7.verticalSpace,
// //                                     Container(
// //                                       height: 1,
// //                                       width: 600.w,
// //                                       decoration: BoxDecoration(
// //                                         gradient: LinearGradient(
// //                                           colors: [
// //                                             Colors.white,
// //                                             HexColor("#EC5002"),
// //                                             Colors.white,
// //                                           ],
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     7.verticalSpace,

// //                                     Row(
// //                                       children: [
// //                                         Row(
// //                                           mainAxisAlignment:
// //                                               MainAxisAlignment.center,
// //                                           children: [
// //                                             InkWell(
// //                                               onTap: () {
// //                                                 home.clearStoredData();
// //                                                 home.clearGrossAmount();
// //                                                 navigatescrren(
// //                                                   context: context,
// //                                                   page: Bookpoojascreen(
// //                                                     lanid: widget.lanid,
// //                                                     isDonate: true,
// //                                                   ),
// //                                                 );
// //                                               },
// //                                               child: Container(
// //                                                 decoration: BoxDecoration(
// //                                                   color: HexColor("#EC5002"),
// //                                                   borderRadius:
// //                                                       BorderRadius.circular(
// //                                                         27.r,
// //                                                       ),
// //                                                   border: Border.all(
// //                                                     color: HexColor("#F8A300"),
// //                                                     width: 4.h,
// //                                                   ),
// //                                                 ),
// //                                                 height: 60.h,
// //                                                 width: 600.w,
// //                                                 child: Center(
// //                                                   child: Text(
// //                                                     widget.lanid == 1
// //                                                         ? "DONATION"
// //                                                         : "విరాళం",
// //                                                     style:
// //                                                         Fontpalette.white45500,
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                         //   ],
// //                                         // ),
// //                                         // 7.verticalSpace,
// //                                         SizedBox(width: 10.h),

// //                                         Row(
// //                                           mainAxisAlignment:
// //                                               MainAxisAlignment.center,
// //                                           children: [
// //                                             InkWell(
// //                                               onTap: () {
// //                                                 home.clearStoredData();
// //                                                 home.clearGrossAmount();
// //                                                 navigatescrren(
// //                                                   context: context,
// //                                                   page: Bookpoojascreen(
// //                                                     lanid: widget.lanid,
// //                                                     //isDonate: true,
// //                                                   ),
// //                                                 );
// //                                               },
// //                                               child: Container(
// //                                                 decoration: BoxDecoration(
// //                                                   color: HexColor("#EC5002"),
// //                                                   borderRadius:
// //                                                       BorderRadius.circular(
// //                                                         27.r,
// //                                                       ),
// //                                                   border: Border.all(
// //                                                     color: HexColor("#F8A300"),
// //                                                     width: 4.h,
// //                                                   ),
// //                                                 ),
// //                                                 height: 60.h,
// //                                                 width: 600.w,
// //                                                 child: Center(
// //                                                   child: Text(
// //                                                     widget.lanid == 1
// //                                                         ? "GOW SEVA"
// //                                                         : "గోసేవ",
// //                                                     style:
// //                                                         Fontpalette.white45500,
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ],
// //                                     ),
// //                                     7.verticalSpace,
// //                                     Container(
// //                                       height: 1,
// //                                       width: 600.w,
// //                                       decoration: BoxDecoration(
// //                                         gradient: LinearGradient(
// //                                           colors: [
// //                                             Colors.white,
// //                                             HexColor("#EC5002"),
// //                                             Colors.white,
// //                                           ],
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     7.verticalSpace,

// //                                     Row(
// //                                       children: [
// //                                         Row(
// //                                           mainAxisAlignment:
// //                                               MainAxisAlignment.center,
// //                                           children: [
// //                                             InkWell(
// //                                               onTap: () {
// //                                                 home.clearStoredData();
// //                                                 home.clearGrossAmount();
// //                                                 navigatescrren(
// //                                                   context: context,
// //                                                   page: Bookpoojascreen(
// //                                                     lanid: widget.lanid,
// //                                                     //isDonate: true,
// //                                                   ),
// //                                                 );
// //                                               },
// //                                               child: Container(
// //                                                 decoration: BoxDecoration(
// //                                                   color: HexColor("#EC5002"),
// //                                                   borderRadius:
// //                                                       BorderRadius.circular(
// //                                                         27.r,
// //                                                       ),
// //                                                   border: Border.all(
// //                                                     color: HexColor("#F8A300"),
// //                                                     width: 4.h,
// //                                                   ),
// //                                                 ),
// //                                                 height: 60.h,
// //                                                 width: 600.w,
// //                                                 child: Center(
// //                                                   child: Text(
// //                                                     widget.lanid == 1
// //                                                         ? "SEVAS"
// //                                                         : "సేవలు",
// //                                                     style:
// //                                                         Fontpalette.white45500,
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                         //   ],
// //                                         // ),
// //                                         // 7.verticalSpace,
// //                                         SizedBox(width: 10.h),

// //                                         Row(
// //                                           mainAxisAlignment:
// //                                               MainAxisAlignment.center,
// //                                           children: [
// //                                             InkWell(
// //                                               onTap: () {
// //                                                 home.clearStoredData();
// //                                                 home.clearGrossAmount();
// //                                                 navigatescrren(
// //                                                   context: context,
// //                                                   page: Bookpoojascreen(
// //                                                     lanid: widget.lanid,
// //                                                     isDonate: true,
// //                                                   ),
// //                                                 );
// //                                               },
// //                                               child: Container(
// //                                                 decoration: BoxDecoration(
// //                                                   color: HexColor("#EC5002"),
// //                                                   borderRadius:
// //                                                       BorderRadius.circular(
// //                                                         27.r,
// //                                                       ),
// //                                                   border: Border.all(
// //                                                     color: HexColor("#F8A300"),
// //                                                     width: 4.h,
// //                                                   ),
// //                                                 ),
// //                                                 height: 60.h,
// //                                                 width: 600.w,
// //                                                 child: Center(
// //                                                   child: Text(
// //                                                     widget.lanid == 1
// //                                                         ? "E - HUNDI"
// //                                                         : "ఈ-హుండీ",
// //                                                     style:
// //                                                         Fontpalette.white45500,
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ],
// //                                 ).horizontalPadding(200.w),
// //                               ],
// //                             ),
// //                           ],
// //                         ),
// //                         40.verticalSpace,
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Container(
// //                               height: 107.h,
// //                               width: 500.w,
// //                               decoration: BoxDecoration(
// //                                 image: DecorationImage(
// //                                   fit: BoxFit.contain,
// //                                   image: AssetImage(
// //                                     "assets/images/logowithname.png",
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             Text(
// //                               "www.punnyamtemplesuite.com",
// //                               style: Fontpalette.brown30600,
// //                             ),
// //                           ],
// //                         ).horizontalPadding(100.w),
// //                       ],
// //                     ),
// //                   ).horizontalPadding(90.w).topPadding(40.h).bottomPadding(5.h),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kalady_kiosk/color_pallatte.dart';
// import 'package:kalady_kiosk/extension.dart';
// import 'package:kalady_kiosk/fontpallate.dart';
// import 'package:kalady_kiosk/provider/homeprovider.dart';
// import 'package:kalady_kiosk/view/bookpooja.dart';
// import 'package:kalady_kiosk/view/homepage.dart';
// import 'package:kalady_kiosk/services/helpers.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LanguageSelectedScreen extends StatefulWidget {
//   const LanguageSelectedScreen({super.key, this.lanid});
//   final int? lanid;
//   @override
//   State<LanguageSelectedScreen> createState() => _LanguageSelectedScreenState();
// }

// class _LanguageSelectedScreenState extends State<LanguageSelectedScreen> {
//   late int _selectedLang;

//   @override
//   void initState() {
//     super.initState();
//     _selectedLang = widget.lanid ?? 1;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<HomeProvider>().getDeities();
//     });
//   }

//   Future<void> _openAdwaithaSangamam() async {
//     try {
//       await launchUrl(
//         Uri.parse("https://as.kaladyshankaramadomts.org/"),
//         mode: LaunchMode.externalApplication,
//       );
//     } catch (e) {
//       debugPrint('Unable to open website: $e');
//       Helpers.successToast("Unable to open website");
//     }
//   }

//   Widget _menuButton({required String label, required VoidCallback onTap}) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: HexColor("#EC5002"),
//           borderRadius: BorderRadius.circular(27.r),
//           border: Border.all(color: HexColor("#F8A300"), width: 4.h),
//         ),
//         height: 60.h,
//         width: 600.w,
//         child: Center(
//           child: Text(
//             label,
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: Fontpalette.white45500,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _menuDivider() {
//     return Container(
//       height: 1,
//       width: 600.w,
//       margin: EdgeInsets.symmetric(vertical: 7.h),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.white, HexColor("#EC5002"), Colors.white],
//         ),
//       ),
//     );
//   }

//   // Deity buttons from the getDeities API, two per row, with the
//   // Adwaitha Sangamam website link kept in the second slot.
//   Widget _buildMenu(HomeProvider home) {
//     final deities = home.deitiesResponse?.data;
//     if (deities == null) {
//       return Center(
//         child: CircularProgressIndicator(color: HexColor("#EC5002")),
//       ).verticalPadding(30.h);
//     }

//     final buttons = <Widget>[
//       for (final deity in deities)
//         _menuButton(
//           label:
//               _selectedLang == 1
//                   ? (deity.name ?? '').toUpperCase()
//                   : (deity.nameMal ?? deity.name ?? ''),
//           onTap: () {
//             home.clearStoredData();
//             home.clearGrossAmount();
//             navigatescrren(
//               context: context,
//               page: Bookpoojascreen(
//                 lanid: _selectedLang,
//                 deityId: deity.id,
//                 deityName: _selectedLang == 1 ? deity.name : deity.nameMal,
//               ),
//             );
//           },
//         ),
//     ];
//     buttons.insert(
//       buttons.isEmpty ? 0 : 1,
//       _menuButton(
//         label: _selectedLang == 1 ? "ADWAITHA SANGAMAM" : "అద్వైత సంగమం",
//         onTap: _openAdwaithaSangamam,
//       ),
//     );

//     final rows = <Widget>[];
//     for (var i = 0; i < buttons.length; i += 2) {
//       if (rows.isNotEmpty) rows.add(_menuDivider());
//       rows.add(
//         Row(
//           children: [
//             buttons[i],
//             if (i + 1 < buttons.length) ...[
//               SizedBox(width: 10.h),
//               buttons[i + 1],
//             ],
//           ],
//         ),
//       );
//     }
//     return Column(children: rows).horizontalPadding(200.w);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: AlignmentDirectional.topCenter,
//             end: AlignmentDirectional.bottomCenter,
//             colors: [
//               const Color.fromARGB(255, 243, 233, 98),
//               const Color.fromARGB(255, 244, 245, 199),
//               Colors.white,
//               Colors.white,
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             Positioned(
//               top: -60.h,
//               right: -250.w,
//               child: Container(
//                 height: 220.h,
//                 width: 702.w,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     fit: BoxFit.fill,
//                     image: AssetImage("assets/images/flwr.png"),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 470.h,
//               left: -330.w,
//               child: Container(
//                 height: 202.h,
//                 width: 702.w,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     fit: BoxFit.fill,
//                     image: AssetImage("assets/images/flwr.png"),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 470.h,
//               right: -330.w,
//               child: Container(
//                 height: 202.h,
//                 width: 702.w,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     fit: BoxFit.fill,
//                     image: AssetImage("assets/images/flwr.png"),
//                   ),
//                 ),
//               ),
//             ),
//             Consumer<HomeProvider>(
//               builder:
//                   (context, home, child) => SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         Column(
//                           children: [
//                             20.verticalSpace,
//                             Row(
//                               children: [
//                                 Container(
//                                   height: 69.h,
//                                   width: 69.h,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Colors.white,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black26,
//                                         blurRadius: 6,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                     image: DecorationImage(
//                                       fit: BoxFit.contain,
//                                       image: AssetImage(
//                                         "assets/images/kalady_logo.jpg",
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text(
//                                   "Kalady Sri Adi Shankara\n Madom, Telangana",
//                                   style: Fontpalette.appheading,
//                                 ),
//                                 SizedBox(width: 40),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Container(
//                                       padding: EdgeInsets.all(4.h),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(
//                                           30.r,
//                                         ),
//                                         border: Border.all(
//                                           color: HexColor("#F8A300"),
//                                           width: 3.h,
//                                         ),
//                                       ),
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           _LanguageTab(
//                                             label: "English",
//                                             selected: _selectedLang == 1,
//                                             onTap: () {
//                                               setState(() => _selectedLang = 1);
//                                             },
//                                           ),
//                                           _LanguageTab(
//                                             label: "తెలుగు",
//                                             selected: _selectedLang == 0,
//                                             onTap: () {
//                                               setState(() => _selectedLang = 0);
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             16.verticalSpace,
//                             // Language tab switcher
//                             // Row(
//                             //   mainAxisAlignment: MainAxisAlignment.center,
//                             //   children: [
//                             //     Container(
//                             //       padding: EdgeInsets.all(4.h),
//                             //       decoration: BoxDecoration(
//                             //         color: Colors.white,
//                             //         borderRadius: BorderRadius.circular(30.r),
//                             //         border: Border.all(
//                             //           color: HexColor("#F8A300"),
//                             //           width: 3.h,
//                             //         ),
//                             //       ),
//                             //       child: Row(
//                             //         mainAxisSize: MainAxisSize.min,
//                             //         children: [
//                             //           _LanguageTab(
//                             //             label: "English",
//                             //             selected: _selectedLang == 1,
//                             //             onTap: () {
//                             //               setState(() => _selectedLang = 1);
//                             //             },
//                             //           ),
//                             //           _LanguageTab(
//                             //             label: "తెలుగు",
//                             //             selected: _selectedLang == 0,
//                             //             onTap: () {
//                             //               setState(() => _selectedLang = 0);
//                             //             },
//                             //           ),
//                             //         ],
//                             //       ),
//                             //     ),
//                             //   ],
//                             // ),
//                             //10.verticalSpace,
//                             Container(
//                               height: 500.h,
//                               decoration: BoxDecoration(
//                                 color: Colors.red,
//                                 border: Border.all(
//                                   color: Colors.white,
//                                   width: 10.h,
//                                 ),
//                                 borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(6.r),
//                                   topRight: Radius.circular(6.r),
//                                   bottomLeft: Radius.circular(113.r),
//                                   bottomRight: Radius.circular(113.r),
//                                 ),
//                                 image: DecorationImage(
//                                   fit: BoxFit.cover,
//                                   image: AssetImage(
//                                     "assets/images/adishankaratemple.jpeg",
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             10.verticalSpace,
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(45.r),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Column(
//                                     children: [
//                                       Text(
//                                         "Kalady Sri Adi Shankara Madom Telangana",
//                                         style: Fontpalette.brown70700,
//                                       ),
//                                       Text(
//                                         "Sri.Sri. Jagadguru Adi Shankaracharya MahaSamsthanam",
//                                         style: Fontpalette.grey45600,
//                                       ),
//                                     ],
//                                   ).verticalPadding(30.h),
//                                 ],
//                               ),
//                             ),
//                             60.verticalSpace,

//                             _buildMenu(home),
//                           ],
//                         ),
//                         40.verticalSpace,
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               height: 107.h,
//                               width: 500.w,
//                               decoration: BoxDecoration(
//                                 image: DecorationImage(
//                                   fit: BoxFit.contain,
//                                   image: AssetImage(
//                                     "assets/images/logowithname.png",
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               "www.punnyamtemplesuite.com",
//                               style: Fontpalette.brown30600,
//                             ),
//                           ],
//                         ).horizontalPadding(100.w),
//                       ],
//                     ),
//                   ).horizontalPadding(90.w).topPadding(40.h).bottomPadding(5.h),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _LanguageTab extends StatelessWidget {
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;

//   const _LanguageTab({
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(26.r),
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
//         decoration: BoxDecoration(
//           color: selected ? HexColor("#EC5002") : Colors.transparent,
//           borderRadius: BorderRadius.circular(26.r),
//         ),
//         child: Text(
//           label,
//           style: selected ? Fontpalette.white45500 : Fontpalette.brown45600,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kalady_kiosk/color_pallatte.dart';
import 'package:kalady_kiosk/extension.dart';
import 'package:kalady_kiosk/fontpallate.dart';
import 'package:kalady_kiosk/provider/homeprovider.dart';
import 'package:kalady_kiosk/view/bookpooja.dart';
import 'package:kalady_kiosk/view/homepage.dart';
import 'package:kalady_kiosk/services/helpers.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LanguageSelectedScreen extends StatefulWidget {
  const LanguageSelectedScreen({super.key, this.lanid});
  final int? lanid;
  @override
  State<LanguageSelectedScreen> createState() => _LanguageSelectedScreenState();
}

class _LanguageSelectedScreenState extends State<LanguageSelectedScreen> {
  late int _selectedLang;

  @override
  void initState() {
    super.initState();
    _selectedLang = widget.lanid ?? 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().getDeities();
    });
  }

  Future<void> _openAdwaithaSangamam() async {
    try {
      await launchUrl(
        Uri.parse("https://as.kaladyshankaramadomts.org/"),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Unable to open website: $e');
      Helpers.successToast("Unable to open website");
    }
  }

  Widget _menuButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: HexColor("#EC5002"),
          borderRadius: BorderRadius.circular(27.r),
          border: Border.all(color: HexColor("#F8A300"), width: 4.h),
        ),
        height: 60.h,
        width: 600.w,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Fontpalette.white45500,
          ),
        ),
      ),
    );
  }

  Widget _menuDivider() {
    return Container(
      height: 1,
      width: 600.w,
      margin: EdgeInsets.symmetric(vertical: 7.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, HexColor("#EC5002"), Colors.white],
        ),
      ),
    );
  }

  // Separate full-width container, different colour from the deity buttons
  // Widget _adwaithaSangamamButton() {
  //   return InkWell(
  //     onTap: _openAdwaithaSangamam,
  //     borderRadius: BorderRadius.circular(27.r),
  //     child: Container(
  //       width: double.infinity,
  //       height: 70.h,
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [HexColor("#7B1E1E"), HexColor("#A52A2A")],
  //         ),
  //         borderRadius: BorderRadius.circular(27.r),
  //         border: Border.all(color: HexColor("#F8A300"), width: 4.h),
  //         boxShadow: const [
  //           BoxShadow(
  //             color: Colors.black26,
  //             blurRadius: 6,
  //             offset: Offset(0, 3),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(Icons.open_in_new, color: Colors.white, size: 28.h),
  //           SizedBox(width: 14.w),
  //           Text(
  //             _selectedLang == 1 ? "ADWAITHA SANGAMAM" : "అద్వైత సంగమం",
  //             textAlign: TextAlign.center,
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //             style: Fontpalette.white45500,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  //   Widget _adwaithaSangamamButton() {
  //   return InkWell(
  //     onTap: _openAdwaithaSangamam,
  //     borderRadius: BorderRadius.circular(27.r),
  //     child: Container(
  //       width: double.infinity,
  //       height: 110.h,
  //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [HexColor("#7B1E1E"), HexColor("#A52A2A")],
  //         ),
  //         borderRadius: BorderRadius.circular(27.r),
  //         border: Border.all(color: HexColor("#F8A300"), width: 4.h),
  //         boxShadow: const [
  //           BoxShadow(
  //             color: Colors.black26,
  //             blurRadius: 6,
  //             offset: Offset(0, 3),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Container(
  //             height: 90.h,
  //             width: 90.h,
  //             padding: EdgeInsets.all(4.h),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(20.r),
  //               border: Border.all(color: HexColor("#F8A300"), width: 2.h),
  //             ),
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(14.r),
  //               child: Image.asset(
  //                 "assets/images/logo.jpeg",
  //                 fit: BoxFit.contain,
  //               ),
  //             ),
  //           ),
  //           SizedBox(width: 20.w),
  //           Text(
  //             _selectedLang == 1 ? "ADWAITHA SANGAMAM" : "అద్వైత సంగమం",
  //             textAlign: TextAlign.center,
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //             style: Fontpalette.white45500,
  //           ),
  //           SizedBox(width: 14.w),
  //           Icon(Icons.open_in_new, color: Colors.white, size: 28.h),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  //   Widget _adwaithaSangamamButton() {
  //   final Color yellow = HexColor("#E6F21C");
  //   final Color green = HexColor("#1B5E20");

  //   return InkWell(
  //     onTap: _openAdwaithaSangamam,
  //     //borderRadius: BorderRadius.circular(27.r),
  //     child: Container(
  //       width: 260.w,
  //       height: 100.h,
  //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //           colors: [yellow, HexColor("#B5DB0A")],
  //         ),
  //         borderRadius: BorderRadius.circular(27.r),
  //         border: Border.all(color: green, width: 4.h),
  //         boxShadow: const [
  //           BoxShadow(
  //             color: Colors.black38,
  //             blurRadius: 8,
  //             offset: Offset(0, 3),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           SizedBox(
  //             height: 70.h,
  //             width: 90.h,
  //             child: Image.asset(
  //               "assets/images/logo.jpeg",
  //               fit: BoxFit.contain,
  //               color: yellow,
  //               colorBlendMode: BlendMode.multiply,
  //             ),
  //           ),
  //           SizedBox(width: 30.w),
  //           Text(
  //             _selectedLang == 1 ? "ADWAITHA SANGAMAM" : "అద్వైత సంగమం",
  //             textAlign: TextAlign.center,
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //             style: Fontpalette.white45500.copyWith(color: green),
  //           ),
  //           SizedBox(width: 14.w),
  //           Icon(Icons.open_in_new, color: green, size: 28.h),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // // Deity buttons from the getDeities API, two per row,
  // // followed by the separate Adwaitha Sangamam container.
  // Widget _buildMenu(HomeProvider home) {
  //   final deities = home.deitiesResponse?.data;

  //   final List<Widget> content = [];

  //   if (deities == null) {
  //     content.add(
  //       Center(
  //         child: CircularProgressIndicator(color: HexColor("#EC5002")),
  //       ).verticalPadding(30.h),
  //     );
  //   } else {
  //     final buttons = <Widget>[
  //       for (final deity in deities)
  //         _menuButton(
  //           label:
  //               _selectedLang == 1
  //                   ? (deity.name ?? '').toUpperCase()
  //                   : (deity.nameMal ?? deity.name ?? ''),
  //           onTap: () {
  //             home.clearStoredData();
  //             home.clearGrossAmount();
  //             navigatescrren(
  //               context: context,
  //               page: Bookpoojascreen(
  //                 lanid: _selectedLang,
  //                 deityId: deity.id,
  //                 deityName: _selectedLang == 1 ? deity.name : deity.nameMal,
  //                 isEHundi: HomeProvider.isEHundiDeity(deity.name),
  //                 rateEditable: [
  //                   '1',
  //                   'true',
  //                 ].contains(deity.rateeditable?.toString()),
  //               ),
  //             );
  //           },
  //         ),
  //     ];

  //     for (var i = 0; i < buttons.length; i += 2) {
  //       if (content.isNotEmpty) content.add(_menuDivider());
  //       content.add(
  //         Row(
  //           children: [
  //             buttons[i],
  //             if (i + 1 < buttons.length) ...[
  //               SizedBox(width: 10.h),
  //               buttons[i + 1],
  //             ],
  //           ],
  //         ),
  //       );
  //     }
  //   }

  //   content.add(24.verticalSpace);
  //   content.add(_adwaithaSangamamButton());

  //   return Column(children: content).horizontalPadding(200.w);
  // }




  Widget _adwaithaSangamamButton() {
  final Color yellow = HexColor("#E6F21C");
  final Color green = HexColor("#1B5E20");

  return Center(
    child: InkWell(
      onTap: _openAdwaithaSangamam,
      child: Container(
        // Sized to its content: a fixed 260.w was too narrow and overflowed.
        height: 100.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [yellow, HexColor("#B5DB0A")],
          ),
          borderRadius: BorderRadius.circular(27.r),
          border: Border.all(color: green, width: 4.h),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 70.h,
              width: 90.h,
              child: Image.asset(
                "assets/images/logo.jpeg",
                fit: BoxFit.contain,
                color: yellow,
                colorBlendMode: BlendMode.multiply,
              ),
            ),
            SizedBox(width: 30.w),
            Flexible(
              child: Text(
                _selectedLang == 1 ? "ADWAITHA SANGAMAM" : "అద్వైత సంగమం",
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Fontpalette.white45500.copyWith(color: green),
              ),
            ),
            SizedBox(width: 14.w),
            Icon(Icons.open_in_new, color: green, size: 28.h),
          ],
        ),
      ),
    ),
  );
}

Widget _buildMenu(HomeProvider home) {
  final deities = home.deitiesResponse?.data;

  final List<Widget> content = [];

  if (deities == null) {
    content.add(
      Center(
        child: CircularProgressIndicator(color: HexColor("#EC5002")),
      ).verticalPadding(30.h),
    );
  } else {
    final buttons = <Widget>[
      for (final deity in deities)
        _menuButton(
          label:
              _selectedLang == 1
                  ? (deity.name ?? '').toUpperCase()
                  : (deity.nameMal ?? deity.name ?? ''),
          onTap: () {
            home.clearStoredData();
            home.clearGrossAmount();
            navigatescrren(
              context: context,
              page: Bookpoojascreen(
                lanid: _selectedLang,
                deityId: deity.id,
                deityName: _selectedLang == 1 ? deity.name : deity.nameMal,
                isEHundi: HomeProvider.isEHundiDeity(deity.name),
                rateEditable: [
                  '1',
                  'true',
                ].contains(deity.rateeditable?.toString()),
              ),
            );
          },
        ),
    ];

    for (var i = 0; i < buttons.length; i += 2) {
      if (content.isNotEmpty) content.add(_menuDivider());
      content.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buttons[i],
            if (i + 1 < buttons.length) ...[
              SizedBox(width: 10.w),
              buttons[i + 1],
            ],
          ],
        ),
      );
    }
  }

  content.add(24.verticalSpace);
  content.add(_adwaithaSangamamButton());

  return Column(children: content).horizontalPadding(200.w);
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
              const Color.fromARGB(255, 244, 245, 199),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60.h,
              right: -250.w,
              child: Container(
                height: 220.h,
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
            Consumer<HomeProvider>(
              builder:
                  (context, home, child) => SingleChildScrollView(
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
                                SizedBox(width: 10),
                                Text(
                                  "Kalady Sri Adi Shankara\n Madom, Telangana",
                                  style: Fontpalette.appheading,
                                ),
                                SizedBox(width: 40),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(4.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          30.r,
                                        ),
                                        border: Border.all(
                                          color: HexColor("#F8A300"),
                                          width: 3.h,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _LanguageTab(
                                            label: "English",
                                            selected: _selectedLang == 1,
                                            onTap: () {
                                              setState(() => _selectedLang = 1);
                                            },
                                          ),
                                          _LanguageTab(
                                            label: "తెలుగు",
                                            selected: _selectedLang == 0,
                                            onTap: () {
                                              setState(() => _selectedLang = 0);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            16.verticalSpace,
                            Container(
                              height: 500.h,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 10.h,
                                ),
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
                                      Text(
                                        "Kalady Sri Adi Shankara Madom Telangana",
                                        style: Fontpalette.brown70700,
                                      ),
                                      Text(
                                        "Sri.Sri. Jagadguru Adi Shankaracharya MahaSamsthanam",
                                        style: Fontpalette.grey45600,
                                      ),
                                    ],
                                  ).verticalPadding(30.h),
                                ],
                              ),
                            ),
                            60.verticalSpace,

                            _buildMenu(home),
                          ],
                        ),
                        40.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
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
                        ).horizontalPadding(100.w),
                      ],
                    ),
                  ).horizontalPadding(90.w).topPadding(40.h).bottomPadding(5.h),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? HexColor("#EC5002") : Colors.transparent,
          borderRadius: BorderRadius.circular(26.r),
        ),
        child: Text(
          label,
          style: selected ? Fontpalette.white45500 : Fontpalette.brown45600,
        ),
      ),
    );
  }
}

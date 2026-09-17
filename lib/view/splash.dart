// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:kalady_kiosk/extension.dart';
// import 'package:kalady_kiosk/fontpallate.dart';
// import 'package:kalady_kiosk/provider/homeprovider.dart';
// import 'package:kalady_kiosk/services/app_config.dart';
// import 'package:kalady_kiosk/services/helpers.dart';
// import 'package:kalady_kiosk/services/shared_preference_helper.dart';
// import 'package:kalady_kiosk/view/homepage.dart';
// import 'package:kalady_kiosk/view/loginscreen.dart';
// import 'package:provider/provider.dart';

// class Splash extends StatefulWidget {
//   const Splash({super.key});

//   @override
//   State<Splash> createState() => _SplashState();
// }

// class _SplashState extends State<Splash> {
//   @override
//   void initState() {
//     checkLogged();
//     super.initState();
//   }

//   checkLogged() async {
//     await SharedPreferenceHelper.getToken();
//     Future.delayed(const Duration(seconds: 2), () => navToScreen());
//   }

//   navToScreen() async {
//     final home = context.read<HomeProvider>();

//     home.updateSelectedDate();
//     if ((AppConfig.accessToken ?? '').isNotEmpty) {
//       await home.getDeities();

//       await home.getStars();
//       await home.getPoojas(
//         deityId: home.deitiesResponse?.data![0].id.toString(),
//       );
//       if (!mounted) return;
//       home.getPaymentModes(
//         onFailure:
//             () => Helpers.successToast(
//               'Error occurred while fetching payment modes ....!',
//             ),
//       );

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const MyHomePage()),
//         (route) => false,
//       );
//     } else {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(45.r),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,

//                 children: [
//                   //old id 64 font size
//                   Text(
//                     "Kalady Sri Adi Shankara Madom Telangana",
//                     style: Fontpalette.brown65700,
//                   ),
//                   Text(
//                     "Sri.Sri. Jagadguru Adi Shankaracharya MahaSamsthanam",
//                     style: Fontpalette.grey45600,
//                   ),
//                 ],
//               ).verticalPadding(30.h).horizontalPadding(40.w),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kalady_kiosk/extension.dart';
import 'package:kalady_kiosk/fontpallate.dart';
import 'package:kalady_kiosk/provider/homeprovider.dart';
import 'package:kalady_kiosk/services/app_config.dart';
import 'package:kalady_kiosk/services/helpers.dart';
import 'package:kalady_kiosk/services/shared_preference_helper.dart';
import 'package:kalady_kiosk/view/homepage.dart';
import 'package:kalady_kiosk/view/loginscreen.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    checkLogged();
    super.initState();
  }

  checkLogged() async {
    await SharedPreferenceHelper.getToken();
    Future.delayed(const Duration(seconds: 2), () => navToScreen());
  }

  navToScreen() async {
    final home = context.read<HomeProvider>();

    home.updateSelectedDate();
    if ((AppConfig.accessToken ?? '').isNotEmpty) {
      await home.getDeities();

      await home.getStars();
      await home.getPoojas(
        deityId: home.deitiesResponse?.data![0].id.toString(),
      );
      if (!mounted) return;
      home.getPaymentModes(
        onFailure:
            () => Helpers.successToast(
              'Error occurred while fetching payment modes ....!',
            ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(45.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/kalady_logo.jpg',
                    height: 160.h,
                    width: 160.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 16.h),
                  //old id 64 font size
                  Text(
                    "Kalady Sri Adi Shankara Madom Telangana",
                    style: Fontpalette.brown65700,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Sri.Sri. Jagadguru Adi Shankaracharya MahaSamsthanam",
                    style: Fontpalette.grey45600,
                    textAlign: TextAlign.center,
                  ),
                ],
              ).verticalPadding(30.h).horizontalPadding(40.w),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:farm_app/AccountScreens/VerifyOTP.dart';
import 'package:farm_app/DashBoardScreen.dart';
import 'package:farm_app/FarmOwnerScreen/OwnerHome/OwnerHome.dart';
import 'package:farm_app/HelperClasses/AppHelper.dart';
import 'package:farm_app/Models/SignUp.dart';
import 'package:farm_app/OneFarmScreen/BookingDates.dart';
import 'package:farm_app/OneFarmScreen/OneFarmInfo.dart';
import 'package:farm_app/OneFarmScreen/PaymentScreen.dart';
import 'package:farm_app/OneFarmScreen/ThanksScreen.dart';
import 'package:farm_app/OneFarmScreen/UploadReceiptScreen.dart';
import 'package:farm_app/SideMenuScreen/MyBookings.dart';
import 'package:farm_app/SideMenuScreen/OrderDetailsScreen.dart';
import 'package:farm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TempSplash extends StatefulWidget {
  @override
  _TempSplashState createState() => _TempSplashState();
}

class _TempSplashState extends State<TempSplash> {
  
  @override
  void initState() {

    print("I am called");
    super.initState();
    Firebase.initializeApp().whenComplete(() async {
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.light, //navigation bar icon
    ));


    FlutterStatusbarcolor.setStatusBarColor(AppColors.statusBarColor); //this change the status bar color to white
    FlutterStatusbarcolor.setNavigationBarColor(AppColors.statusBarColor); //this sets the navigation bar color to green
    return ScreenUtilInit(
        designSize: Size(360, 691),
        allowFontScaling: false,

        builder: ()=>MaterialApp(
            routes: {
              '/login'          : (context)  => LoginScreen(),
              "/dashboard"      : (context)  => DashboardScreen(),
              "/verifyCode"     : (context)  => VerifyOTP(),
              "/booking"        : (context)  => BookingDates(),
              "/payment"        : (context)  => PaymentScreen(),
              "/thanks"         : (context)  => ThanksScreen(),
              "/myBooking"      : (context)  => MyBookingScreen(),
              "/details"        : (context)  => OrderDetailsScreen(),
              "/receipt"        : (context)  => UploadReceiptScreen()
            },
            home: Scaffold(
              body: TempImage(),
            )
        )
    );

  }

}
String bearerToken = "";
bool called = false;
class TempImage extends StatefulWidget {
  @override
  _TempImageState createState() => _TempImageState();
}

class _TempImageState extends State<TempImage> {

  @override
  Widget build(BuildContext context) {
    getData(context);
    return Center(
      child: Image.asset(AppImages.coloredLogo, width: 250, height: 110,),
    );
  }

  void getData(BuildContext context) async {
    if (!called){
      called = true;
      SharedPreferences pref = await SharedPreferences.getInstance();
      String json = pref.getString('userData');

        if (json == null) {

          Navigator.pushNamed(context, '/login');
        }
        else{
          LoginUser user = LoginUser.fromJson(json);
          bearerToken = user.result.token;
          print(bearerToken);
          // if (user.result.roleId == 3){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => DashboardScreen(),), (route) => false,);
          // }
          // else{
          //   Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(builder: (BuildContext context) => OwnerHomeScreen(),), (route) => false,);
          // }
        }



    }
  }
}


import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:device_info/device_info.dart';
import 'package:farm_app/API_Calls/APICalls.dart';
import 'package:farm_app/AccountScreens/TempSplash.dart';
import 'package:farm_app/DashBoardScreen.dart';
import 'package:farm_app/FarmOwnerScreen/OwnerHome/OwnerHome.dart';
import 'package:farm_app/HelperClasses/AppHelper.dart';
import 'package:farm_app/Models/SignUp.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get_version/get_version.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(TempSplash());
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress)
          return false;
        else
          return false;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: LoginFrom()
      ),
    );

  }
}



class LoginFrom extends StatefulWidget {
  @override
  _LoginFromState createState() => _LoginFromState();
}

class _LoginFromState extends State<LoginFrom> {


  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String countryCode = "+92";





  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool imageTaken       = false;
  String appVersion     = "";
  String udid           = "";
  String menufecturer   = "";
  String model          = "";
  String osVersion      = "";
  String signupSource   = "";
  String firebaseToken;


  @override
  void initState() {
    super.initState();
    getAppInfo();

    Firebase.initializeApp().whenComplete(() async {
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");

      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      firebaseToken = token;
      print(firebaseToken);
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Colors.white,
        body: _createMainView()
    );
  }


  Widget _createMainView(){

    return Stack(
        children: [
          _createHeaderImage(),
          _createLogoImage(),
       ],
    );
  }



  
  
  Widget _createLogoImage(){
    return Column(

      children: [
        Container(
          height: 199.0.h,
          child: Center(child: Image.asset(AppImages.logo, width: 94.5.w, height: 88.4.h,),)
        ),
        _emailPasswordForm()

      ],
    );
  }

  Widget _createHeaderImage(){
    return Image.asset(AppImages.headerImage, width: 360.0.w, height: 270.h, fit: BoxFit.cover);
  }


  Widget _emailPasswordForm(){
    return Container(

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(30),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome!", style: TextStyles.titleLabel(),),
          SizedBox(height: 10.0.h,),
          Text("Email Id", style: TextStyles.formTitleStyle(),),
          Row(
            children: [
              Container(
                  height: 40.0.h,
                  width: 100,
                  child: FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: (){
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true, // optional. Shows phone code before the country name.
                          onSelect: (Country country) {
                            countryCode = "+${country.phoneCode}";
                            setState(() {

                            });
                          },
                        );

                      },
                      child: Row(
                        children: [
                          Expanded(child: Container(
                            child: Center(child: Text(countryCode, style: TextStyles.formTitleStyle(),)),
                          )),
                          Image.asset(AppImages.downArrow, width: 15,),
                          SizedBox(width: 10,)

                        ],
                      )
                  )
              ),
              SizedBox(width: 10.w,),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 10),
                  height: 40.0.h,
                  child: TextField(

                    keyboardType: TextInputType.phone,
                    controller: _phoneNumberController,
                    style: TextStyles.formTitleStyle(),
                    cursorColor: AppColors.textBlack,
                    decoration: InputDecoration(
                        suffixText: " ",
                        hintText: "Enter Phone",
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        prefixText: "  ",
                        contentPadding: EdgeInsets.only(bottom: 10.0.h)

                    ),
                  ),
                ),
              ),
            ],
          ),

          Container(width: double.infinity, height: 1, color: AppColors.textBlack,),
          SizedBox(height: 10.0.h,),
          Text("Password", style: TextStyles.formTitleStyle(),),
          TextField(
            controller: passwordController,
            style: TextStyles.formTitleStyle(),
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter Password",
              border: InputBorder.none,
            ),
          ),
          Container(width: double.infinity, height: 1, color: AppColors.textBlack,),
          // Forgot Password
          Align(alignment: Alignment.centerRight,

          child: Container(
            padding: EdgeInsets.all(2),
            child: FlatButton(
              padding: EdgeInsets.all(0.0),
              onPressed: (){

              },
              child: Text("Forgot Password?", style: TextStyle(fontSize: 11.sp, fontFamily: AppFonts.regular, color: AppColors.forgotBtnColor),),
            ),
          )
          ),

          SizedBox(height: 10.0.h,),
          FlatButton(
            onPressed: (){
              login();
            },
            child: Container(
                height: 35.0.w,
                width: double.infinity,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.forgotBtnColor,
                        blurRadius: 2.0, // soften the shadow
                        spreadRadius: 0.02, //extend the shadow
                        offset: Offset(
                          0.5, // Move to right 10  horizontally
                          0.5, // Move to bottom 10 Vertically
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(17.5.w),
                    gradient: UIHelper.gradient()
                ),
                child: Center(
                  child: Text("Log In", style: TextStyles.buttonLabel(),),
                )

            ),
          ),
          SizedBox(height: 4.0.h,),
          Align(
            alignment: Alignment.center,
            child: FlatButton(
              padding: EdgeInsets.all(0.0),
              onPressed: (){
                 Navigator.pushNamed(context, '/verifyCode',);
              },
              child: Text("Don't have account? Sign Up", style: TextStyle(fontFamily: AppFonts.regular, fontSize: 14.0.sp, color: AppColors.textBlack),),

            ),
          )

        ],
      ),

    );
  }


  void getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion =  packageInfo.version;
    udid = await FlutterUdid.udid;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      menufecturer = androidInfo.manufacturer;
      model = androidInfo.model;
      osVersion = await GetVersion.platformVersion;
      signupSource = "Android";
    }
    else{
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      menufecturer = "apple";
      model = iosInfo.name;
      osVersion =  iosInfo.systemVersion;
      signupSource = "iOS";
    }

  }


  // void getData()async {
  //   UserLogin user = UserLogin(email: "system@viiontech.com", password: "1234", manufacturer: "iOS", model: "iPHone", platform: "iOS", app_version: "1.25");
  //   Map map = user.toMap();
  //
  //   API_Data data = await NetworkCalls.postWebCall("https://bel.viion.net/api/login", map);
  //   if (data.done){
  //     print(data.responseString);
  //   }
  //   else{
  //     print(data.errorMsg);
  //   }
  // }

  void login() async {
    String phone  = _phoneNumberController.text;
    String pass   = passwordController.text;
    if (phone.length < 10){
      UIHelper.showErrorAlert(context, "Please enter valid phone number",);

      return;
    } else if (pass.isEmpty){
      UIHelper.showErrorAlert(context, "Please enter password");
    }
    else{
        // calling APi
      UIHelper.apiCallingAlert(context);
      LoginRequest request = LoginRequest(phone: phone, password: pass, signupSource: "iOS", appVersion: appVersion, manufacturer: menufecturer, model: model, serial: udid, uuid: udid, version: osVersion, token: firebaseToken);
      Map map = request.toMap();
      String url = BASE_URL + "login";
      API_Data result = await NetworkCalls.postWebCall(url, map);
      UIHelper.hideApiCallingAlert(context);
      if (result.done){
        try {
            LoginUser user = LoginUser.fromJson(result.responseString);
            if (user.status == 1){
              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.setString('userData', result.responseString);
                LoginUser user = LoginUser.fromJson(result.responseString);
                bearerToken = user.result.token;
              if (user.result.roleId == 3){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => DashboardScreen(),), (route) => false,);
              }
              else{
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => OwnerHomeScreen(),), (route) => false,);
              }


            }
            else{
              UIHelper.showErrorAlert(context, user.message);
            }

        }catch (exp){
          UIHelper.showErrorAlert(context, "Please try later...");
        }
      }
      else{
        UIHelper.showErrorAlert(context, result.errorMsg);
      }


    }
  }


  myFunction(){
    print("HAHAHHHA");
  }

}








import 'package:farm_app/API_Calls/APICalls.dart';
import 'package:farm_app/Models/SignUp.dart';
import 'package:get_version/get_version.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:farm_app/HelperClasses/AppHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/SignUp.dart';


class CreateAccount extends StatefulWidget {

  final String phone;
  final String role;
  final bool isEdit;
  final LoginUser user;
  CreateAccount(this.phone, this.role, this.isEdit, {this.user});
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CreateAccountScreen(phone: widget.phone, role: widget.role, isEdit: widget.isEdit)
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  final String phone;
  final String role;
  final bool isEdit;
  final LoginUser user;
  CreateAccountScreen({this.phone, this.role, this.isEdit, this.user});
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {


  TextEditingController userNameController          = TextEditingController();
  TextEditingController userPhoneController         = TextEditingController();
  TextEditingController userAddressController       = TextEditingController();
  TextEditingController userEmailController         = TextEditingController();
  TextEditingController userCnicController          = TextEditingController();
  TextEditingController passwordController          = TextEditingController();
  TextEditingController confirmPasswordController   = TextEditingController();
  final FirebaseMessaging _firebaseMessaging        = FirebaseMessaging();

  File _image;
  bool imageTaken = false;
  String firebaseToken ;
  String appVersion = "";
  String udid = "";
  String menufecturer = "";
  String model = "";
  String osVersion = "";
  String signupSource = "";

  var cnicFormat = new MaskTextInputFormatter(mask: '#####-#######-#', filter: { "#": RegExp(r'[0-9]') });


  @override
  void initState() {
    super.initState();
    getAppInfo();
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
    });
  }




  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
          children: [
            UIHelper.createHeaderImage(),
            UIHelper.createLogoImage(),
            createAccountForm(context)
          ],
        ),
    );
  }

  Widget createAccountForm(context){
    return Column(
      children: [
        SizedBox(height: 199.0.h,),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(26.0),
            width: MediaQuery.of(context).size.width,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Text("Join us", style: TextStyles.titleLabel(),),
                  Container(
                    height: 105.h,
                    child: getUserImage(),
                  ),
                  SizedBox(height: 20.h,),
                  Text("Full Name*", style: TextStyles.formTitleStyle(),),
                  TextField(
                    controller: userNameController,
                    style: TextStyles.formTitleStyle(),
                    decoration: InputDecoration(
                      hintText: "Enter Username",
                      border: InputBorder.none,
                    ),
                  ),
                  Container(width: double.infinity, height: 1, color: AppColors.textBlack,),

                  SizedBox(height: 20.h,),
                  Text("Email Id", style: TextStyles.formTitleStyle(),),
                  TextField(
                    controller: userEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyles.formTitleStyle(),
                    decoration: InputDecoration(
                      hintText: "Enter Email",
                      border: InputBorder.none,
                    ),
                  ),
                  Container(width: double.infinity, height: 1, color: AppColors.textBlack,),

                  SizedBox(height: 20.h,),
                  Text("Phone Number *", style: TextStyles.formTitleStyle(),),
                  TextField(
                    enabled: false,
                    controller: userPhoneController..text = widget.phone,
                    style: TextStyles.formTitleStyle(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter Username",
                      border: InputBorder.none,

                    ),
                  ),
                  Container(width: double.infinity, height: 1, color: AppColors.textBlack,),

                  SizedBox(height: 20.h,),
                  Text("CNIC *", style: TextStyles.formTitleStyle(),),
                  TextField(
                    controller: userCnicController,
                    inputFormatters: [cnicFormat],
                    keyboardType: TextInputType.number,
                    style: TextStyles.formTitleStyle(),
                    decoration: InputDecoration(
                      hintText: "1111-1111111-1",
                      border: InputBorder.none,
                    ),
                  ),
                  Container(width: double.infinity, height: 1, color: AppColors.textBlack,),

                  SizedBox(height: 20.h,),

                  Text("Address *", style: TextStyles.formTitleStyle(),),
                  TextField(
                    controller: userAddressController,
                    style: TextStyles.formTitleStyle(),
                    decoration: InputDecoration(
                      hintText:  "Enter Address",
                      border: InputBorder.none,
                    ),
                  ),
                  Container(width: double.infinity, height: 1, color: AppColors.textBlack,),


                  SizedBox(height: 20.h,),
                  Text("Password *", style: TextStyles.formTitleStyle(),),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: TextStyles.formTitleStyle(),
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      border: InputBorder.none,
                    ),
                  ),
                  Container(width: double.infinity, height: 1, color: AppColors.textBlack,),

                  SizedBox(height: 20.h,),
                  Text("Confirm Password *", style: TextStyles.formTitleStyle(),),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    style: TextStyles.formTitleStyle(),
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border: InputBorder.none,
                    ),
                  ),
                  Container(width: double.infinity, height: 1, color: AppColors.textBlack,),

                  SizedBox(height: 30.0.h,),
                  FlatButton(
                    onPressed: (){
                        signUp();
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
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomLeft,
                                colors: [AppColors.gradientStart, AppColors.gradientEnd])
                        ),
                        child: Center(
                          child: Text("Sign Up", style: TextStyles.buttonLabel(),),
                        )

                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: FlatButton(
                      padding: EdgeInsets.all(0.0),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text("Don't have account? Log In", style: TextStyle(fontFamily: AppFonts.regular, fontSize: 14.0.sp, color: AppColors.textBlack),),

                    ),
                  )



                ],
              ),
            )

          ),
        )
      ],
    );
  }


  Future<void> signUp() async {

    String name             = userNameController.text;
    String phone            = userPhoneController.text;
    String address          = userAddressController.text;
    String email            = userEmailController.text;
    String cnic             = userCnicController.text;
    String password         = passwordController.text;
    String confirmPassword  = confirmPasswordController.text;

    if (!imageTaken){
      UIHelper.showErrorAlert(context, "Please choose image");
      return;
    } else if (name.isEmpty) {
      UIHelper.showErrorAlert(context, "Please enter Name");
      return;
    } else if (phone.isEmpty) {
      UIHelper.showErrorAlert(context, "Please enter your phone number");
      return;
    } else if (address.isEmpty) {
      UIHelper.showErrorAlert(context, "Please enter address");
      return;
    } else if (checkEmail(email)) {
      UIHelper.showErrorAlert(context, "Please enter a valid email");
      return;
    } else if (cnic.length < 15) {
      UIHelper.showErrorAlert(context, "Please enter a valid CNIC number");
      return;
    } else if (password.isEmpty) {
      UIHelper.showErrorAlert(context, "Please enter password");
      return;
    } else if (confirmPassword.isEmpty) {
      UIHelper.showErrorAlert(context, "Please enter confirm password");
      return;
    } else if (password != confirmPassword) {
      UIHelper.showErrorAlert(context, "Password and Confirm password do not match");
      return;
    } else {
      UIHelper.apiCallingAlert(context);

      SignUpModel user = SignUpModel(name: name, phone: widget.phone, address: address, email: email,
        cnic: cnic, roleId: widget.role, password: password, confirmPassword: confirmPassword,
        signupSource: "ios", manufacturer: menufecturer, model: model, appVersion: appVersion, serial: udid, uuid: udid, version: osVersion, token: firebaseToken);

      Map map = user.toMap();
      String url = BASE_URL + "signup";
      API_Data result = await  NetworkCalls.uploadFile(url, map, _image.path);
      UIHelper.hideApiCallingAlert(context);
      if (result.done){
        try {
          LoginUser data = LoginUser.fromJson(result.responseString);
          if (data.status == 1)
          {
            if (data.result.isVerified == 1){
              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.setString('userData', result.responseString);
              Navigator.pushNamed(context, '/dashboard');
            }
            else{
              UIHelper.showSuccessAlertWithAction(context, data.message, backToLogin);
            }
          }
          else{
            UIHelper.showErrorAlert(context, data.message);
          }


        } catch (exp){
          print("Execption is $exp");
          UIHelper.showErrorAlert(context, "Please Try later");
        }

      }
      else{
        UIHelper.showErrorAlert(context, result.errorMsg);
      }

    }

  }

  bool checkEmail(String email){
    if (email.length == 0){
      return false;
    } else if (!DataHelper.isEmail(email))  {
     return true;
    }
    else{
      return false;
    }
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


  Widget getUserImage(){
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Expanded(child: FlatButton(
            onPressed: (){
              showPicker(context);
            },

            child: Container(
              height: 86.h,
              width: 86.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(43.h),
                child: Container(
                  height: 86.h,
                  width: 86.h,
                  decoration: new BoxDecoration(
                    color: Colors.purple,
                    gradient: new LinearGradient(
                      colors: [Colors.red, Colors.cyan],
                    ),
                  ),
                  child: CircleAvatar(
                  radius: 55,
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.file(
                      _image,
                      width: 86.h,
                      height: 86.h,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50)),
                    width: 86.h,
                    height: 86.h,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                ),
              ),
            ),
          )),
          Text("Add Image", style: TextStyles.regular14Label(),)
        ],
      ),
    );
  }


  void showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }



  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    _image = image;
    if (image != null){
      imageTaken = true;
    }
    setState(() {

    });
  }

  _imgFromGallery() async {
    File image = await  ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    _image = image;
    if (image != null){
      imageTaken = true;
    }
    setState(() {

    });
  }


  backToLogin(){
    //'/login'
    Navigator.popUntil(context, ModalRoute.withName('/login'));
  }




}


import 'dart:async';

import 'package:farm_app/API_Calls/APICalls.dart';
import 'package:farm_app/AccountScreens/RoleSelection.dart';
import 'package:farm_app/AccountScreens/TimerInfo.dart';
import 'package:farm_app/Alerts/CallingAlert.dart';
import 'package:farm_app/HelperClasses/AppHelper.dart';
import 'package:farm_app/Models/SignUp.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';


// ignore: must_be_immutable
class VerifyOTP extends StatefulWidget {

  @override
  _VerifyOTPState createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: ChangeNotifierProvider(
        create: (_) => TimerInfo(),
        child: OTPScreen()
    ),
    );
  }
}

class OTPScreen extends StatefulWidget {

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {


  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  String _verificationId;
  String buttonLabel    = "SEND CODE";
  String OTPstatus      = "";
  Timer timer;
  bool isDisabled       = true;
  var countryCode       = "+92";
  String number         = "";
  bool codeEnabled      = false;


  @override
  void dispose() {
    timer.cancel();
    super.dispose();
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
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Column(
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
                      Align(alignment: Alignment.center, child: Text("Phone Verification", style: TextStyles.titleLabel(),),),
                      SizedBox(height: 8.0.h,),
                      Align(alignment: Alignment.center, child: Text("Enter your phone number below to receive OTP.", style: TextStyles.regularLabel(),),),
                      SizedBox(height: 8.0.h),

                      Text("Phone", style: TextStyles.formTitleStyle(),),
                      SizedBox(height: 5.0.h),
                      Row(
                        children: [
                          Container(

                            height: 40.0.h,
                            width: 100,
                            decoration: BoxDecoration(
                                border: Border.all(color:AppColors.textFiledBorder, width: 2.0),
                                borderRadius: BorderRadius.circular(5)
                            ),
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
                              decoration: BoxDecoration(
                                  border: Border.all(color:AppColors.textFiledBorder, width: 2.0),
                                  borderRadius: BorderRadius.circular(5)
                              ),
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
                      SizedBox(height: 20.0.h),

                      Text("Code", style: TextStyles.formTitleStyle(),),
                      SizedBox(height: 15.0.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              height: 40.2.h,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.textFiledBorder, width: 2),
                                borderRadius: BorderRadius.circular(10)

                              ),
                              child: Center(
                                child: TextField(
                                  enabled: codeEnabled,
                                controller: _smsController,
                                  onChanged: (text){
                                      if (text.length == 6){
                                        verifyCode();
                                      }
                                  },
                                    textAlignVertical: TextAlignVertical.center,
                                    textAlign: TextAlign.center,
                                  style: TextStyles.formTitleStyle(),
                                  maxLength: 6,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Enter codee here",
                                    counterText: "",
                                    contentPadding: EdgeInsets.only(bottom: 10.h),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.0.h),
                      FlatButton(
                        onPressed: (){
                          FocusScope.of(context).unfocus();
                          verifyPhone();
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
                                borderRadius: BorderRadius.circular(5),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomLeft,
                                    colors: [AppColors.gradientStart, AppColors.gradientEnd])
                            ),
                            child: Center(
                              child: Text(buttonLabel, style: TextStyles.buttonLabel(),),
                            )

                        ),
                      ),

                      Align(
                        alignment: Alignment.center,
                        child: FlatButton(
                          padding: EdgeInsets.all(0.0),
                          onPressed: (){
                            if (isDisabled){

                            }
                            else{
                              verifyPhone();
                            }
                          },
                          child: Text("Resend Code", style: TextStyle(fontFamily: AppFonts.regular, fontSize: 16.0.sp, color: AppColors.darkBlack)),

                        ),
                      ),

                      Align(
                        alignment: Alignment.center,
                        child: FlatButton(
                          padding: EdgeInsets.all(0.0),
                          onPressed: (){
                            Navigator.pushNamed(context, "/oneFarm",);
                          },
                          child: Consumer<TimerInfo>(
                            builder: (context, data, child){
                              int seconds = data.getSeconds();
                              if (seconds == 0){
                                isDisabled = false;
                                timer.cancel();
                              }
                              return Text("Resend code after 00:$seconds");
                          }

                          ),

                        ),
                      )
                    ],
                  ),
                )

            ),
          )
        ],
      ),
    );
  }

//  "+923164940471",




  void verifyPhone() async {
      if (buttonLabel == "SEND CODE") {
        number = _phoneNumberController.text;
        if (number[0] == "0") {
          number = "${number.substring(1)}";
        }
        number = countryCode + number;
        if (number.length < 10) {
          UIHelper.showErrorAlert(context, "Please enter a valid phone number");
        }
        else {
          showDialog(
              context: context, barrierDismissible: false, builder: (context) {
            return ApiCallingAlert();
          });

          String url = BASE_URL + "phone-verify";
          PhoneAuth phone = PhoneAuth();
          phone.phone = number;
          Map map = phone.toMap();
          API_Data result = await NetworkCalls.postWebCall(url, map);
          print(result.responseString);
          Navigator.of(context, rootNavigator: true).pop('dialog');
          if (result.done) {
            PhoneAuthResponse response = PhoneAuthResponse.fromJson(
                result.responseString);
            if (response.status == 1) {
              sendOTP(context, number);
            }
            else {
              UIHelper.showErrorAlert(context, response.message);
            }
          }
          else {
            UIHelper.showErrorAlert(context, result.errorMsg);
          }
        }
      }
      else{
        verifyCode();
      }

  }




  Future<void> sendOTP(context, String number) async {
    var firebaseAuth = FirebaseAuth.instance;
    firebaseAuth.verifyPhoneNumber(
      phoneNumber: number,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        startTimer(context);
      },
      verificationFailed: (FirebaseAuthException v) {
        String st = v.toString();

        UIHelper.showErrorAlert(context, st);
      },
      codeSent: (String verificationId, int resendToken) {

        codeEnabled = true;
        buttonLabel = "VERIFY CODE";
        _verificationId = verificationId;
        startTimer(context);
        setState(() {

        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {

      },
    );
  }

  Future<void> verifyCode() async {

    UIHelper.apiCallingAlert(context);
    FirebaseAuth auth = FirebaseAuth.instance;
    String smsCode = _smsController.text;

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: smsCode);

    // Sign the user in (or link) with the credential
    await auth.signInWithCredential(phoneAuthCredential).then((value) {
      UIHelper.hideApiCallingAlert(context);
      if (value.user != null) {
          OTPstatus = 'Authentication successful';
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => SelectUserType(number)
          ));
        }
      else
        {
          OTPstatus = 'Invalid code/invalid authentication';
        }
    }).catchError((error) {
      OTPstatus = 'Could not verify with code';
    });
    
    

  }

  void startTimer(BuildContext context) {


    var timerInfo = Provider.of<TimerInfo>(context, listen: false);
    timerInfo.setSecods();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      timerInfo.decreaseTime();
    });
  }
}


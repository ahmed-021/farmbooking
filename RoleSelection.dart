import 'package:farm_app/AccountScreens/CreateAccount.dart';
import 'package:farm_app/HelperClasses/AppHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class SelectUserType extends StatefulWidget {
  String phone;
  SelectUserType(this.phone);
  @override
  _SelectUserTypeState createState() => _SelectUserTypeState();
}

class _SelectUserTypeState extends State<SelectUserType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RoleSelection(widget.phone),
    );
  }
}

class RoleSelection extends StatefulWidget {
  String phone;
  RoleSelection(this.phone);
  @override
  _RoleSelectionState createState() => _RoleSelectionState();
}

class _RoleSelectionState extends State<RoleSelection> {

  bool user = false;
  bool owner = false;
  List<BoxShadow> ownerShadow = List<BoxShadow>();
  List<BoxShadow> userShadow = List<BoxShadow>();



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
                      Align(alignment: Alignment.centerLeft, child: Text("Continue as a", style: TextStyles.titleLabel(),),),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: (){
                              user = false;
                              owner = true;
                              setOwner();
                            },
                            child: Container(
                              height: 111.h,
                              width: 121.w,
                              decoration: BoxDecoration(
                                color: AppColors.ownerBackgounrd,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: ownerShadow
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(AppImages.farmOwner, width: 48.h, height: 48.h,),
                                  Text("Farm Owner", style: TextStyles.medium14Black(),)
                                ],
                              ),
                            ),
                          ),
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: (){
                              user = true;
                              owner = false;
                              setUser();

                            },
                            child: Container(
                              height: 111.h,
                              width: 121.w,
                              decoration: BoxDecoration(
                                  color: AppColors.userBackground,
                                  borderRadius: BorderRadius.circular(10),
                                boxShadow: userShadow

                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(AppImages.farmUser, width: 48.h, height: 48.h,),
                                  Text("User", style: TextStyles.medium14Black(),)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                      FlatButton(
                        onPressed: (){
                          procedNext();
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
                              child: Text("Continue", style: TextStyles.buttonLabel(),),
                            )

                        ),
                      ),


                    ],
                  ),
                )

            ),
          )
        ],
      ),
    );
  }

  void setOwner(){
    userShadow = List<BoxShadow>();
    if (owner){
      ownerShadow = [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 5,
          blurRadius: 5,
          offset: Offset(0, 4), // changes position of shadow
      ),
    ];
      setState(() {

      });
    }
    else{
      ownerShadow = List<BoxShadow>();
    }

  }


  void setUser(){
    ownerShadow = List<BoxShadow>();

    if (user){
      userShadow = [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 5,
          blurRadius: 5,
          offset: Offset(0, 4), // changes position of shadow
        ),
      ];
      setState(() {

      });
    }
    else{
      userShadow = List<BoxShadow>();
    }
  }
  void procedNext(){
    if (owner == false && user == false){
      UIHelper.showErrorAlert(context, "Please select Type");
    }
    else{
      String role;
      if (user){
        role = "3";
      }
      else if (owner) {
        role = "2";
      }
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => CreateAccount(widget.phone, role, false)
      ));
    }
  }


}




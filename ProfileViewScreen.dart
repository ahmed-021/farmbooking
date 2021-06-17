import 'package:farm_app/AccountScreens/EditProfile.dart';
import 'package:farm_app/HelperClasses/AppHelper.dart';
import 'package:farm_app/Models/SignUp.dart';
import 'package:farm_app/SideMenuScreen/SideMenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileViewScreen extends StatefulWidget {
  final LoginUser user;
  ProfileViewScreen({this.user});
  @override
  _ProfileViewScreenState createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
        drawer: Drawer(
          child: SideMenuScreen(),
        ),
        body: SafeArea(
              child: Container(
              color: AppColors.backgroundView,
              child: Column(
                children: [
                  UIHelper.menuBar("Profile", context, openMenu),
                  Expanded(child: Container(
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    width: double.infinity,
                    child: profileColumn(),
                  )
                  )
                ],
              )


          )
        )
    );
  }

  openMenu(context){
    _drawerKey.currentState.openDrawer();
  }

  Container profileColumn(){
    return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30,),
            Container(
              child: Column(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                   //  child: Image.network(widget.user.result.picture, height: 100, width: 100, fit: BoxFit.cover,)
                  ),
                  SizedBox(height: 15,),
                  Text(widget.user.result.name, style: TextStyles.medium16Black(),),
                  SizedBox(height: 10,),
                  Text(widget.user.result.address, style: TextStyles.regular14Light(),),
                  SizedBox(height: 15,),
                  Divider()
                ],
              ),
            ),

            Text("Address", style: TextStyles.medium16Black(),),
            SizedBox(height: 8,),
            Text(widget.user.result.address, style: TextStyles.regular14Light(), maxLines: 100,),
            SizedBox(height: 8,),
            Divider(),

            Text("Phone", style: TextStyles.medium16Black(),),
            SizedBox(height: 8,),
            Text(widget.user.result.phone, style: TextStyles.regular14Light(), maxLines: 100,),
            SizedBox(height: 8,),
            Divider(),

            Text("Email", style: TextStyles.medium16Black(),),
            SizedBox(height: 8,),
            Text(widget.user.result.email, style: TextStyles.regular14Light(), maxLines: 100,),
            SizedBox(height: 8,),
            Divider(),

            Text("CNIC", style: TextStyles.medium16Black(),),
            SizedBox(height: 8,),
            Text(widget.user.result.cnic, style: TextStyles.regular14Light(), maxLines: 100,),
            SizedBox(height: 8,),
            Divider(),


            SizedBox(height: 40,),
            Center(
              child: FlatButton(onPressed: (){

                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => EditProfileScreen()
                    )
                );
              }, child: Container(
                width: 230.w,
                height: 35.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: UIHelper.gradient()
                ),
                child: Center(child: Text("Update Profile", style: TextStyles.medium14White(),)),
              )
              ),
            ),

          ],
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:farm_app/Alerts/CallingAlert.dart';
import 'package:farm_app/Alerts/ErrorAlert.dart';
import 'package:farm_app/Alerts/FilterScreen.dart';
import 'package:farm_app/DB_Helper/DB_Helper.dart';
import 'package:farm_app/HelperClasses/AppHelper.dart';
import 'package:farm_app/MapScreen.dart';
import 'package:farm_app/Models/FarmsModels.dart';
import 'package:farm_app/OneFarmScreen/OneFarmInfo.dart';
import 'package:farm_app/SideMenuScreen/SideMenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'package:progress_dialog/progress_dialog.dart';


class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:  () async {
      if (Navigator.of(context).userGestureInProgress)
        return false;
      else
        return false;
    },
      child: DashboardForm(),
    );
  }
}




class DashboardForm extends StatefulWidget {
  @override
  _DashboardFormState createState() => _DashboardFormState();
}

class _DashboardFormState extends State<DashboardForm> {

  bool searchVisible = true;
  bool mapVisible = false;
  bool callingAPI = true;
  Completer<GoogleMapController> _controller = Completer();
  int popularCurrentPageNumber = 1;
  int popularTotalPages = 0;
  String popularNextPageUrl;

  String promotedFarmsNextUrl;
  int promotedCurrentPage = 1;
  int promotedTotalPages = 0;
  bool promotedNextPageCalled = false;




  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.47579, 74.34257),
    zoom: 16,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  ScrollController _scrollController;
  ScrollController _horizontalScrollController;



  WholeFarmsResponse data;
  List<PopularFarm> _allPopularFarms = List<PopularFarm>();
  List<PromotedFarm> _allPromotedFarms = List<PromotedFarm>();
  ProgressDialog pr;
  bool fetchingData = true;
  bool popularNextPageCalled = false;

  @override
  void initState() {
    // TODO: implement initState

    setOfflineData();

    getData();
    pr = ProgressDialog(context);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _horizontalScrollController  = ScrollController();
    _horizontalScrollController.addListener(_horizontalScroll);


    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      drawer: Drawer(
        child: SideMenuScreen(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            UIHelper.menuBar("Dashboard", context, openMenu),
            _createSearchView(),
            fetchingData ? Expanded(
              child: Container(
                  child:
              Container(
                width: double.infinity,
                height: 100,
                child: Row(

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(width: 20,),
                    Text("Please Wait...")

                  ],
                ),

              )
              ),
            ) : _list()
          ],
        ),
      ),
    );
  }


  Widget _list() {
    if (data != null) {
      if (data.done) {
        if (!popularNextPageCalled && !promotedNextPageCalled){
          _allPopularFarms.clear();
          _allPromotedFarms.clear();
          popularTotalPages = data.popular.totalPages;
          data.popular.allPopular.forEach((element) {
            _allPopularFarms.add(element);
          });

          data.promoted.allFarms.forEach((element) {
            _allPromotedFarms.add(element);
          });
          popularNextPageUrl = data.popular.nextPage;

          promotedFarmsNextUrl = data.promoted.nextPage;
          promotedTotalPages = data.promoted.totalPages;
        }


        return Expanded(
          child: RefreshIndicator(
            onRefresh: getData,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  SizedBox(height: 20.h,),
                  Visibility(
                    visible: !mapVisible,
                    child: SingleChildScrollView(
                      child: _screenOptions(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      else {
        return Expanded(child: ErrorAlert(data.errorMsg));
      }
    }
    else{
      if (!fetchingData){
        return Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(height: 20.h,),
                Visibility(
                  visible: !mapVisible,
                  child: SingleChildScrollView(
                    child: _screenOptions(),
                  ),
                ),
              ],
            ),
          ),
        );
      }else{
        return Expanded(child: ErrorAlert("Could not fetch farms Data, please try later"));
      }
    }
  }



  openMenu(context){
    _drawerKey.currentState.openDrawer();
  }


  Widget _screenOptions(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        NotificationListener<ScrollUpdateNotification>(
          child:  _sponseredFarms(),
          onNotification: (notification) {
            if (notification.metrics.pixels == notification.metrics.maxScrollExtent){
              loadMorePromotedFarms();
            }
           return true;
          },
        ),



        SizedBox(height: 20.h,),
        Container(
          padding: EdgeInsets.only(left: 20),
          child: Text("Popular Farmhouses", style: TextStyles.semi20Black(),),
        ),
        popularFamrsList()


      ],
    );
  }



  Widget popularFamrsList(){
    return ListView.builder(

      itemCount: _allPopularFarms.length,
      primary: false,
      shrinkWrap: true,
      itemBuilder: (context, index){
        return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OneFarmInfoScreen(_allPromotedFarms[index].id, _allPromotedFarms[index].name)),
              );
            },
            child: popularList(_allPopularFarms[index], index));
      },
    );
  }


  Container _createSearchView(){
    return Container(
      color: Colors.white,
      height: 50.0.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          Row(
            children: [
              Container(
                width: 50,
                child: FlatButton(
                  padding: EdgeInsets.all(0),
                    onPressed: (){
                      showDialog( context: context, builder: (_) => FilterScreen());

                },
                    child: Image.asset(AppImages.filter, height: 18, width: 18,) ),
              ),
              Container(
                width: 50,
                child: Image.asset(AppImages.icon_search, height: 30.0.h, width: 30.h,),
              ),
            ],
          ),
          Expanded(
            child: Visibility(
              visible: searchVisible,
              child: TextField(
                onChanged: (text){
                  filter(text);
                },
                style: TextStyles.regular14Label(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search',
                ),
              ),

            ),
          ),
          FlatButton(
            onPressed: (){
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen(_allPopularFarms, _allPromotedFarms)));
                });
            },
            child: Row(
              children: [
                Text("Show Map", style: TextStyles.blueLabel(),),
                SizedBox(width: 10,),
                Image.asset(AppImages.icon_showMap, width: 24.h, height: 24.h,)
              ],
            ),
          )
        ],
      ),
    );
  }

  Container _sponseredFarms(){
    return Container(
      height: 150.0.h,

      padding: EdgeInsets.only(left: 15, right: 15),
      child: ListView.separated(
        controller: _horizontalScrollController,
        separatorBuilder: (context, index){
          return SizedBox(width: 15.0.w,);
        },
        scrollDirection: Axis.horizontal,
        itemCount: _allPromotedFarms.length,
        itemBuilder: (context, index){
          return ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              child: Stack(
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover, height: 150.h, width : 200.0.w,
                    imageUrl: _allPromotedFarms[index].image,
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        Center(child: SizedBox(width:10, height:10,child: CircularProgressIndicator(value: downloadProgress.progress),),),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  Image.network(_allPromotedFarms[index].image, fit: BoxFit.cover, height: 150.h, width : 200.0.w),
                   Image.asset(AppImages.farm, fit: BoxFit.cover, height: 150.h, width : 200.0.w,),
                  Container(
                    width: 200.0.w,
                    height: 150.h,
                    decoration: BoxDecoration(
                      gradient: UIHelper.farmGradient()
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            width: 180.0.w,
                            child: Text(_allPromotedFarms[index].name , style: TextStyles.farmTitle(),)),
                        Container(
                          height: 30,
                          width: 180.0.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Text(_allPromotedFarms[index].cityName, style: TextStyles.medium14White(),),),
                              Row(
                                children: [
                                  Image.asset(AppImages.star, height: 12.0.h, width: 12.h,),
                                  SizedBox(width: 10.h,),
                                  Text("${_allPromotedFarms[index].rating}", style: TextStyles.regularLabel14White(),),
                                ],
                              )

                            ],
                          ),
                        ),
                        SizedBox(height: 10.0.h,)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Container popularList(PopularFarm farm, int index){
    return Container(
      padding: EdgeInsets.only(left: 5),
      height: 100.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  width: 100.0.w, height: 100.0.h, fit: BoxFit.cover,
                  imageUrl: farm.image,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(child: SizedBox(width:20, height:20,child: CircularProgressIndicator(value: downloadProgress.progress),),),
                  errorWidget: (context, url, error) => Icon(Icons.error),

                ),


            ),
          ),
          SizedBox(width: 10,),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(farm.name + "$index", style: TextStyles.medium16Black(),),
                Text(farm.cityName, style: TextStyles.regular14Label(),),
                Text("Starting from: ${farm.startPrice ?? 0.0}", style: TextStyles.regularLabel(),)
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Image.asset(AppImages.star, width: 15, height: 15,),
                SizedBox(width: 5,),
                Text("${farm.rating}", style: TextStyles.regular14Light(),)
              ],
            ),
          )


        ],
      ),
    );
  }






  Expanded _createMap(){
    return Expanded(
      child: Container(
        child: GoogleMap(
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            if (_controller.isCompleted){

            }
            else{
              _controller.complete(controller);
            }

          },
        ),
      ),
    );
  }


  void filter(String text){
    _allPopularFarms.clear();
    if (text.length > 0){
      data.popular.allPopular.forEach((element) {
        if (element.cityName.toUpperCase().startsWith(text.toUpperCase())){
          _allPopularFarms.add(element);
        }

      });
    }
    else{
      data.popular.allPopular.forEach((element) {
          _allPopularFarms.add(element);
      });
    }
    setState(() {

    });
  }


  void setOfflineData() async {
    _allPopularFarms = await database.getAllPopularFarms();
    _allPromotedFarms = await database.getAllPromotedFarms();
    setState(() {
      fetchingData = false;

    });
  }
  Future getData() async {
    promotedNextPageCalled = false;
    popularNextPageCalled = false;
    popularCurrentPageNumber = 1;
    promotedCurrentPage = 1;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        this.data = await AllFarmsList().getFarmsList();
        pr.hide();
        setState(() {

        });

      }
    } on SocketException catch (_) {
      pr.hide();
      setState(() {

      });
    }




  }

  _scrollListener() {

    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //    message = "reach the bottom";

      loadMoreData();

    }
    if (_scrollController.offset <= _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {

      //  message = "reach the top";

    }


  }


  _horizontalScroll() {

    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //    message = "reach the bottom";

      loadMoreData();

    }
    if (_scrollController.offset <= _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {

      //  message = "reach the top";

    }


  }


  void loadMoreData() async {
    if (popularCurrentPageNumber < popularTotalPages) {
      popularCurrentPageNumber++;
      UIHelper.apiCallingAlert(context);
      NextPageResponse response = await PopularFarmsNextPageResponse()
          .getNextPage(popularNextPageUrl);
      if (response.success) {
        popularNextPageUrl = response.nextPageUrl;
        _allPopularFarms.clear();
        List<PopularFarm> dbRecord = await database.getAllPopularFarms();
        dbRecord.forEach((element) {
          _allPopularFarms.add(element);
        });
        popularNextPageCalled = true;
        UIHelper.hideApiCallingAlert(context);
        setState(() {

        });
      }
      else {
        UIHelper.showErrorAlert(context, response.errorMsg);
      }
    }
  }


  void loadMorePromotedFarms() async {
    if (promotedCurrentPage < promotedTotalPages) {
      promotedCurrentPage++;
      UIHelper.apiCallingAlert(context);
      NextPageResponse response = await PopularFarmsNextPageResponse()
          .getPromotedNextPage(promotedFarmsNextUrl);
      if (response.success) {
        promotedFarmsNextUrl = response.nextPageUrl;
        _allPromotedFarms.clear();
        List<PromotedFarm> dbRecord = await database.getAllPromotedFarms();
        dbRecord.forEach((element) {
          _allPromotedFarms.add(element);
        });
        promotedNextPageCalled = true;
        UIHelper.hideApiCallingAlert(context);
        setState(() {

        });
      }
      else {
        UIHelper.showErrorAlert(context, response.errorMsg);
      }
    }
  }
}











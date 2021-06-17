import 'dart:ffi';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farm_app/OneFarmScreen/OneFarmInfo.dart';
import 'package:http_parser/http_parser.dart';
import 'package:farm_app/DB_Helper/DB_Helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'HelperClasses/AppHelper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final List<PopularFarm> _allPopularFarms;
  final List<PromotedFarm> _allPromotedFarms;

  MapScreen(this._allPopularFarms, this._allPromotedFarms);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  Position _currentPosition;
  String _currentAddress;
  BitmapDescriptor icon;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final LatLng _center = const LatLng(45.521563, -122.677433);

  Set<Marker> markers = Set<Marker>();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    _getCurrentLocation();
    BitmapDescriptor.fromAssetImage(ImageConfiguration(), AppImages.mapPin)
        .then((value) => icon = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: AppColors.backgroundView,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIHelper.navBar(
                  "All Far6tumttyums ${widget._allPromotedFarms.length}", context),
              Expanded(
                child: GoogleMap(
                  markers: markers,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 16.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        LatLng latlng = LatLng(position.latitude, position.longitude);
        mapController.moveCamera(CameraUpdate.newLatLng(latlng));
        setMarkers();
      });
      //_getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  void setMarkers() async {
    widget._allPopularFarms.forEach((element) {
      markers.add(Marker(
          onTap: () {
            showInfoFromBottom(element);
          },
          markerId: MarkerId("${element.id}"),
          position: LatLng(
              double.parse(element.latitude), double.parse(element.longitude)),
          icon: icon));
    });

    setState(() {});
  }

  void showInfoFromBottom(PopularFarm farm) {

    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OneFarmInfoScreen(farm.id, farm.name)),
              );
            },
            child: Container(
              height: 200,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 5),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      height: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 150,
                            padding: EdgeInsets.all(5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                width: 100.0,
                                height: 100.0,
                                fit: BoxFit.cover,
                                imageUrl: farm.image,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),

                              //Image.network(farm.image, width: 100.0.w, height: 100.0.h, fit: BoxFit.cover,)
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  farm.name,
                                  style: TextStyles.medium16Black(),
                                ),
                                Text(
                                  farm.cityName,
                                  style: TextStyles.regular14Label(),
                                ),
                                Text(
                                  "Starting from: ${farm.startPrice ?? 0.0}",
                                  style: TextStyles.regularLabel(),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Image.asset(
                                  AppImages.star,
                                  width: 15,
                                  height: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "${farm.rating}",
                                  style: TextStyles.regular14Light(),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

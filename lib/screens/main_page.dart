import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:rider/components/default_button.dart';
import 'package:rider/components/progress_dialog.dart';
import 'package:rider/constants/constants.dart';
import 'package:rider/global_variables.dart';
import 'package:rider/brand_colors.dart';
import 'package:rider/components/brand_divider.dart';
import 'package:rider/provider/app_data.dart';
import 'package:rider/screens/search_page.dart';
import 'package:rider/utils/request_helper_methods.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainPage';
  MainPage({this.appValue});
  final FirebaseApp appValue;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{
  Completer<GoogleMapController> _controllerMap = Completer();
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  double rideDetailsHeight = 0;

  double mapBottomPading = 0;
  double searchSheetHeight = 300;
  bool isLoading = true;
  bool isDetailOpen = false;
  GoogleMapController googleMap;
  Position currentPosition;

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  CameraPosition _kGooglePlex = CameraPosition(
    target: kDefaultCamera,
    zoom: 15.00,
  );

  @override
  void initState() {
    super.initState();
  }

  void setCurrentLocation() async {
    final Geolocator geoLocator = Geolocator()..forceAndroidLocationManager;
    final Position position = await geoLocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    googleMap.animateCamera(CameraUpdate.newCameraPosition(cp));

    String address =
        await HelperMethods.findCordinateAddress(position, context);
    debugPrint(address);
  }

  Future<void> getCurrentDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destionation =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickupLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destionationLatLng =
        LatLng(destionation.latitude, destionation.longitude);
    showDialog(
        context: context,
        builder: (context) => ProgressDialog(status: 'Please wait...'),
        barrierDismissible: false);
    var currentDetails = await HelperMethods.getDirectionDetails(
        pickupLatLng, destionationLatLng);
    Navigator.pop(context);
    debugPrint(currentDetails.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(currentDetails.encodedPoints);

    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng points) {
        polylineCoordinates.add(LatLng(points.latitude, points.longitude));
      });
    }

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('id'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylines.add(polyline);
    });

    LatLngBounds bounds; //bounds
    if (pickupLatLng.latitude > destionationLatLng.latitude &&
        pickupLatLng.longitude > destionationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destionationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destionationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest:
              LatLng(pickupLatLng.latitude, destionationLatLng.longitude),
          northeast:
              LatLng(destionationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destionationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest:
              LatLng(destionationLatLng.latitude, pickupLatLng.longitude),
          northeast:
              LatLng(pickupLatLng.latitude, destionationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destionationLatLng);
    }

    googleMap.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
        markerId: MarkerId('pickup'),
        position: pickupLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow:
            InfoWindow(title: pickup.placeName, snippet: 'My Location'));

    Marker destinationMarker = Marker(
        markerId: MarkerId('destination'),
        position: destionationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: destionation.placeName, snippet: 'Destination'));

    _markers.clear();
    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });
  }

  void showDetailsSheet() async{
    await getCurrentDirection();
    setState(() {
      rideDetailsHeight = 220;
      searchSheetHeight = 0;
      isDetailOpen = true;
    });
  }

  void hideDetailsSheet(){

    CameraPosition cp = new CameraPosition(target: LatLng(Provider.of<AppData>(context, listen: false).pickupAddress.latitude, Provider.of<AppData>(context, listen: false).pickupAddress.longitude), zoom: 14);
    googleMap.animateCamera(CameraUpdate.newCameraPosition(cp));

    setState(() {
      searchSheetHeight = 300;
      isDetailOpen      = false;
      rideDetailsHeight = 0;
      _markers.clear();
      polylines.clear();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: searchSheetHeight),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: false,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            polylines: polylines,
            markers: _markers,
            circles: _circles,
            onMapCreated: (GoogleMapController controller) {
              _controllerMap.complete(controller);
              googleMap = controller;
              setCurrentLocation();
            },
          ),
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                !isDetailOpen? _scaffoldState.currentState.openDrawer() : hideDetailsSheet();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7))
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: (isDetailOpen ? Icon(Icons.arrow_back, color: Colors.black,) : Icon(
                    Icons.menu,
                    color: Colors.black,
                  ))
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.easeIn,
                duration: Duration(milliseconds: 150),
                child: Container(
                  height: searchSheetHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7))
                      ]),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text('Nice to see you!', style: TextStyle(fontSize: 10)),
                        Text('Where are you going?',
                            style:
                                TextStyle(fontSize: 18, fontFamily: 'Brand-Bold')),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async {
                            var response = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchPage(),
                                ));
                            if (response == 'getDestination') {
                              showDetailsSheet();
                            }
                          },
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: Colors.blueAccent),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Search destination')
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5.0,
                                      spreadRadius: 0.5,
                                      offset: Offset(0.7, 0.7))
                                ]),
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Row(
                          children: [
                            Icon(
                              OMIcons.home,
                              color: BrandColors.colorDimText,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Add Home'),
                                SizedBox(height: 3),
                                Text(
                                  'Your redencial adress',
                                  style: TextStyle(
                                      color: BrandColors.colorDimText,
                                      fontSize: 11),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        BrandDivider(),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Icon(
                              OMIcons.workOutline,
                              color: BrandColors.colorDimText,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Add Work'),
                                SizedBox(height: 3),
                                Text(
                                  'Your work adress',
                                  style: TextStyle(
                                      color: BrandColors.colorDimText,
                                      fontSize: 11),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              duration: Duration(milliseconds: 250),
              vsync: this,
              curve: Curves.ease,
              child: Container(
                width: double.infinity,
                height: rideDetailsHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7))
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Image.asset('images/taxi.png', height: 60,),
                              SizedBox(width: 5,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('GUber X', style: TextStyle(fontFamily: 'Brand-Bold'),),
                                  SizedBox(height: 5,),
                                  Text('140km'),
                                ],

                              ),
                              Expanded(child: Container()),
                              Text('R\$ 14', style: TextStyle(fontFamily: 'Brand-Bold'),),
                            ],
                          ),
                        ),
                        color: BrandColors.colorAccent1,
                      ),
                      SizedBox(height: 5,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Row(
                            children: [
                              Icon(OMIcons.creditCard, color: BrandColors.colorDimText,),
                              SizedBox(width: 5,),
                              Text('Credit Card', style: TextStyle(color: BrandColors.colorDimText, fontFamily: 'Brand-Bold'),),
                              Icon(Icons.arrow_drop_down, color: BrandColors.colorDimText)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5,),
                      DefaultButton(valueName: 'REQUEST CAR', callback: (){}, customHeight: 50, customWidth: 300,)
                    ],
                  ),
                ),

              ),
            ),
          ),
        ],
      ),
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Container(
                color: Colors.white,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'images/user_icon.png',
                        height: 60,
                        width: 60,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('João Vitor',
                              style: TextStyle(
                                  fontFamily: 'Brand-Bold', fontSize: 20)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('View Profile')
                        ],
                      )
                    ],
                  ),
                ),
                height: 160,
              ),
              BrandDivider(),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text(
                  'Free Rides!',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(OMIcons.creditCard),
                title: Text(
                  'Payments',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(OMIcons.history),
                title: Text(
                  'Ride History',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Text(
                  'Support',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(OMIcons.info),
                title: Text(
                  'About',
                  style: kDrawerItemStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

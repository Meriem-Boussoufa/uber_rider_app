import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uber_rider_app/assistants/assistant_methods.dart';
import 'package:uber_rider_app/widgets/divider.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  static const CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 14.4746);

  Position? currentPosition;
  var geoLocator = Geolocator();

  double bottomPaddingOfMap = 0;

  void locatePosition() async {
    // Check if permission is granted
    var permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      try {
        // Attempt to get current position
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        currentPosition = position;
        LatLng latLatPosition = LatLng(position.latitude, position.longitude);
        CameraPosition cameraPosition =
            CameraPosition(target: latLatPosition, zoom: 14);
        newGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        String address =
            await AssistantMethods.searchCoordinateAddress(position);
        log("This is your Address :: $address");
      } catch (e) {
        Fluttertoast.showToast(msg: "Error getting location: $e");
      }
    } else {
      // Handle case where permission is denied
      Fluttertoast.showToast(msg: "Location permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlue,
        title: const Text("Main Screen", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      drawer: Container(
        color: Colors.white,
        width: 255,
        child: Drawer(
          child: ListView(
            children: [
              SizedBox(
                height: 165,
                child: DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/user_icon.png",
                          height: 65,
                          width: 65,
                        ),
                        const SizedBox(width: 16.0),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Profile Name",
                              style: TextStyle(
                                  fontSize: 16, fontFamily: "Brand-Bold"),
                            ),
                            SizedBox(height: 6.0),
                            Text("Visit Profile"),
                          ],
                        )
                      ],
                    )),
              ),
              const DividerWidget(),
              const SizedBox(height: 12.0),
              const ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "About",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            setState(() {
              bottomPaddingOfMap = 300.0;
            });
            locatePosition();
          },
        ),
        Positioned(
          top: 45,
          left: 22,
          child: GestureDetector(
            onTap: () {
              scaffoldKey.currentState!.openDrawer();
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ]),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.0,
                child: Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: Container(
            height: 320,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 16.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6.0),
                  const Text(
                    'Hi there,',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  const Text(
                    'Where to ?',
                    style: TextStyle(fontSize: 12.0, fontFamily: "Brand-Bold"),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 6.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: 10.0),
                          Text("Search Drop Off")
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  const Row(
                    children: [
                      Icon(
                        Icons.home,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Add Home"),
                          SizedBox(height: 4.0),
                          Text(
                            "Your living home address",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 12.0,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  const DividerWidget(),
                  const SizedBox(height: 16.0),
                  const Row(
                    children: [
                      Icon(
                        Icons.work,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Add Work"),
                          SizedBox(height: 4.0),
                          Text(
                            "Your office address",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 12.0,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

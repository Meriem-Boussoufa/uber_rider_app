import 'dart:async';
import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider_app/assistants/assistant_methods.dart';
import 'package:uber_rider_app/data_handler/app_data.dart';
import 'package:uber_rider_app/models/direction_details.dart';
import 'package:uber_rider_app/screens/search_screen.dart';
import 'package:uber_rider_app/widgets/divider.dart';
import 'package:uber_rider_app/widgets/progress_dialog.dart';

import '../models/address.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  bool drawerOpen = true;

  DirectionDetails? tripDirectionDetails;

  List<LatLng> plineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markers = {};
  Set<Circle> circles = {};

  double rideDetailsContainer = 0;
  double requestRidecontainerHeight = 0;
  double searchContainerHeight = 300.0;
  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300;
      rideDetailsContainer = 0;
      bottomPaddingOfMap = 230;
      polylineSet.clear();
      markers.clear();
      circles.clear();
      plineCoordinates.clear();
    });
    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainer = 240;
      bottomPaddingOfMap = 230;
      drawerOpen = false;
    });
  }

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
            // ignore: use_build_context_synchronously
            await AssistantMethods.searchCoordinateAddress(position, context);
        log("This is your Address :: $address");
      } catch (e) {
        Fluttertoast.showToast(msg: "Error getting location: $e");
      }
    } else {
      // Handle case where permission is denied
      Fluttertoast.showToast(msg: "Location permission denied");
    }
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRidecontainerHeight = 250;
      rideDetailsContainer = 0;
    });
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
          circles: circles,
          markers: markers,
          polylines: polylineSet,
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
          top: 38,
          left: 22,
          child: GestureDetector(
            onTap: () {
              if (drawerOpen) {
                scaffoldKey.currentState!.openDrawer();
              } else {
                resetApp();
              }
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
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.0,
                child: Icon((drawerOpen) ? Icons.menu : Icons.close,
                    color: Colors.black),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: AnimatedSize(
            curve: Curves.bounceIn,
            duration: const Duration(milliseconds: 160),
            child: Container(
              height: searchContainerHeight,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                      style:
                          TextStyle(fontSize: 16.0, fontFamily: "Brand-Bold"),
                    ),
                    const SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () async {
                        var res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchScreen()));
                        if (res == "obtainDirection") {
                          displayRideDetailsContainer();
                        }
                      },
                      child: Container(
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
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.home,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Provider.of<AppData>(context).pickUpLocation !=
                                    null
                                ? Provider.of<AppData>(context)
                                    .pickUpLocation!
                                    .placeName
                                    .toString()
                                : "Add Home"),
                            const SizedBox(height: 4.0),
                            const Text(
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
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: AnimatedSize(
            curve: Curves.bounceIn,
            duration: const Duration(milliseconds: 160),
            child: Container(
              height: rideDetailsContainer,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 17),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.tealAccent[100],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(children: [
                          Image.asset(
                            "assets/images/taxi.png",
                            height: 70,
                            width: 80,
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Car",
                                style: TextStyle(
                                    fontSize: 18.0, fontFamily: "Brand-Bold"),
                              ),
                              Text(
                                ((tripDirectionDetails != null)
                                    ? tripDirectionDetails!.distanceText
                                        .toString()
                                    : ''),
                                style: const TextStyle(
                                    fontSize: 16.0, color: Colors.grey),
                              ),
                            ],
                          ),
                          Expanded(child: Container()),
                          Text(
                            ((tripDirectionDetails != null)
                                ? '\$${AssistantMethods.calculateFares(tripDirectionDetails!)}'
                                : ''),
                            style: const TextStyle(fontFamily: "Brand-Bold"),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.moneyCheckAlt,
                              size: 18, color: Colors.black54),
                          SizedBox(width: 16),
                          Text("Cash"),
                          SizedBox(width: 6),
                          Icon(Icons.keyboard_arrow_down,
                              color: Colors.black54, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (states) => Colors.blue),
                          ),
                          onPressed: () {},
                          child: const Padding(
                            padding: EdgeInsets.all(17),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Request",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(FontAwesomeIcons.taxi,
                                      color: Colors.white, size: 26),
                                ]),
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7))
                ]),
            height: requestRidecontainerHeight,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedTextKit(
                      animatedTexts: [
                        ColorizeAnimatedText(
                          'Requesting a Ride',
                          textStyle: const TextStyle(
                              fontSize: 55, fontFamily: "Signatra"),
                          textAlign: TextAlign.center,
                          colors: [
                            Colors.pink,
                            Colors.green,
                            Colors.purple,
                            Colors.blue,
                            Colors.yellow,
                            Colors.red,
                          ],
                        ),
                        ColorizeAnimatedText(
                          'Please wait ...',
                          textStyle: const TextStyle(
                              fontSize: 55, fontFamily: "Signatra"),
                          textAlign: TextAlign.center,
                          colors: [
                            Colors.pink,
                            Colors.green,
                            Colors.purple,
                            Colors.blue,
                            Colors.yellow,
                            Colors.red,
                          ],
                        ),
                        ColorizeAnimatedText(
                          'Finding a Driver ...',
                          textStyle: const TextStyle(
                              fontSize: 55, fontFamily: "Signatra"),
                          textAlign: TextAlign.center,
                          colors: [
                            Colors.pink,
                            Colors.green,
                            Colors.purple,
                            Colors.blue,
                            Colors.yellow,
                            Colors.red,
                          ],
                        ),
                      ],
                      isRepeatingAnimation: true,
                      onTap: () {
                        log("Tap Event");
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          width: 2.0,
                          color: Colors.grey,
                        )),
                    child: const Icon(
                      Icons.close,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Cancel Ride",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> getPlaceDirection() async {
    Address? initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    Address? finalPos =
        Provider.of<AppData>(context, listen: false).dropOffLocation;
    log(initialPos!.longtitude.toString());
    log(initialPos.latitude.toString());
    log(finalPos!.longtitude.toString());
    log(finalPos.latitude.toString());
    if (initialPos.longtitude != null && finalPos.latitude != null) {
      log("The initialPos and the FinalPos are not null");
      var pickUpLatLng =
          LatLng(initialPos.latitude ?? 0.0, initialPos.longtitude ?? 0.0);
      var dropOffLatLng =
          LatLng(finalPos.latitude ?? 0.0, finalPos.longtitude ?? 0.0);
      log(pickUpLatLng.toString());
      log(dropOffLatLng.toString());
      showDialog(
          context: context,
          builder: (BuildContext context) => ProgressDialog(
                message: "Please wait ...",
              ));
      var details = await AssistantMethods.obtainPlaceDirectionDetails(
          pickUpLatLng, dropOffLatLng);
      setState(() {
        tripDirectionDetails = details;
      });
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      log("This is Encoded points :: ");
      log(details!.encodedPoints.toString());
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodePolyLinePointsResult =
          polylinePoints.decodePolyline(details.encodedPoints!);
      //plineCoordinates.clear();
      if (decodePolyLinePointsResult.isNotEmpty) {
        for (var pointLatLng in decodePolyLinePointsResult) {
          plineCoordinates
              .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        }
      }
      //polylineSet.clear();
      setState(() {
        Polyline polyline = Polyline(
          polylineId: const PolylineId("PolylineID"),
          color: Colors.pink,
          jointType: JointType.round,
          points: plineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        polylineSet.add(polyline);
      });
      LatLngBounds latlngBounds;
      if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
          pickUpLatLng.longitude > dropOffLatLng.longitude) {
        log("Here");
        latlngBounds =
            LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
      } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
        latlngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
        );
      } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
        latlngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
        );
      } else {
        latlngBounds =
            LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
      }

      newGoogleMapController!
          .animateCamera(CameraUpdate.newLatLngBounds(latlngBounds, 70));

      Marker pickUpLocMarker = Marker(
        markerId: const MarkerId("pickUpId"),
        position: pickUpLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow:
            InfoWindow(title: initialPos.placeName, snippet: "My Location"),
      );
      Marker dropOffLocMarker = Marker(
        markerId: const MarkerId("dropOffId"),
        position: dropOffLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
      );
      setState(() {
        markers.add(pickUpLocMarker);
        markers.add(dropOffLocMarker);
      });
      Circle pickUpLocCircle = Circle(
        circleId: const CircleId("pickUpId"),
        fillColor: Colors.blueAccent,
        center: pickUpLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent,
      );
      Circle dropOffLocCircle = Circle(
        circleId: const CircleId("dropOffId"),
        fillColor: Colors.deepPurple,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.deepPurple,
      );
      setState(() {
        circles.add(pickUpLocCircle);
        circles.add(dropOffLocCircle);
      });
    } else {
      log("The initialPos and the FinalPos are null");
      // Handle the case when either initialPos or finalPos is null
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:juno/assistants/assistant_methods.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 13,
  );

  LatLng?
      pickLocation; // Thisis the location not used for userPosition but for the cmera position
//   //Location location = Location();
  String? _address;

//   double searchLocationContainerheight = 200;
//   double waitingResponseFromDriverContainerHeight = 0;
//   double assignedDriverInfoContainerHeight = 0;
  Position? userCurrentPosition;
//   // var geolocation = GeoLocatoer;

// //  LocationPermission? _locationPermission;
//   double bottomPaddingOfMap = 0;

  // List<LatLng> pLineCordinatesList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

//   String _userName = "";
//   String _userEmail = "";

//   bool openNavigationDrawer = true;
//   bool activeDriverNearbyKeysLoaded = false;

//   BitmapDescriptor? activeNearbyIcon;

  void locateUserPosition() async {
    // this method locats our posiotn and puts in center of map and also reverse geocode thename of place

    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;
    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition newCameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 13,
    );
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));

    // rEVERSE gEOcodeing
    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicalCordinates_Position(
            userCurrentPosition!, context);
    print('Our Address : $humanReadableAddress');
  }

  // method to fetch the info from cordinates at which the pin is i.e center of map[Camera positon target is alway at center]
  void getLocationFromLatLng() async {
    try {
      _address = await AssistantMethods.searchAddressForGeographicalCordinates_LatLng(pickLocation!, context);
    } catch (e) {
      print(e);
    }
  }

  void checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
          msg: "Error Occured : Location services are disabled.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Error Occured : Location permissions are denied.",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              "Error Occured : Location permissions are permanently denied, we cannot request permissions.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled:
                  true, // Show the small dot for current location
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _googleMapController.complete(controller);

                newGoogleMapController = controller;

                setState(() {});

                // Fetching user curent locaiotn to show taht
                locateUserPosition();
              },
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
              onCameraMove: (CameraPosition? newCameraPosition) {
                if (pickLocation != newCameraPosition!.target) {
                  setState(() {
                    pickLocation = newCameraPosition.target;
                  });
                }
              },
              onCameraIdle: () {
                // This is the scenario that pickup location is diff form current location
                getLocationFromLatLng();
              },
            ),
            // Dislaying a locaiotn pin in center of screen to represent the pickup location of user
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: Image.asset(
                  "lib/assets/icons/location_pin.png",
                  height: 50,
                  width: 50,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _address ?? "Set your Pickup Location",
                          style: Theme.of(context).textTheme.bodyMedium,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:juno/Info_Handler/app_info.dart';
import 'package:juno/assistants/assistant_methods.dart';
import 'package:juno/models/directions.dart';

class PrecisePickupLocationScreen extends StatefulWidget {
  const PrecisePickupLocationScreen({super.key});

  @override
  State<PrecisePickupLocationScreen> createState() =>
      _PrecisePickupLocationScreenState();
}

class _PrecisePickupLocationScreenState
    extends State<PrecisePickupLocationScreen> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;
  AppInfoController appInfoController = Get.find();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 18,
  );

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  LatLng?
      pickLocation; // Thisis the location not used for userPosition but for the cmera position
  //Location location = Location();
  String? _address;

  double bottomPaddingOfMap = 0;
  Position? userCurrentPosition;

  void locateUserPosition() async {
    // this method locats our posiotn and puts in center of map and also reverse geocode thename of place

    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;
    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition newCameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 18,
    );
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));

    // rEVERSE gEOcodeing
    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicalCordinates_Position(
            userCurrentPosition!, context);
  }

  //method to fetch the info from cordinates at which the pin is i.e center of map[Camera positon target is alway at center]
  void getLocationFromLatLng() async {
    try {
      String loc =
          await AssistantMethods.searchAddressForGeographicalCordinates_LatLng(
              pickLocation!, context);
      setState(() {
        Directions userPickupLocation = Directions();
        userPickupLocation.locationLatitude = pickLocation!.latitude;
        userPickupLocation.locationLongitude = pickLocation!.longitude;
        userPickupLocation.locationName = loc;
        _address = loc;

        appInfoController.updatePickupLocationAddress(userPickupLocation);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(
              top: 30,
              bottom: bottomPaddingOfMap,
            ),
            mapType: MapType.normal,
            myLocationEnabled: true, // Show the small dot for current location
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController.complete(controller);
      
              newGoogleMapController = controller;
      
              setState(() {
                bottomPaddingOfMap = 100;
              });
      
              // Fetching user curent locaiotn to show taht
              locateUserPosition();
            },
            initialCameraPosition: _kGooglePlex,
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
          // Positioned(
          //   top: 40,
          //   left: 20,
          //   right: 20,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       border: Border.all(
          //         color: Colors.black,
          //       ),
          //       color: Colors.white,
          //     ),
          //     padding: EdgeInsets.all(
          //       20,
          //     ),
          //     child: Obx(() {
          //       final pickUpLocation = appInfoController.userPickUpLocation.value;
          //       String displayedLocation =
          //           pickUpLocation?.locationName ?? "Not Getting Address";
      
          //       if (displayedLocation != "Not Getting Address" &&
          //           displayedLocation.length > 33) {
          //         displayedLocation = displayedLocation.substring(0, 33) + "...";
          //       }
      
          //       return Text(
          //         displayedLocation, // Add ellipsis after 25 characters
          //         style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          //               overflow: TextOverflow
          //                   .ellipsis, // Enable ellipsis for overflowing text
          //             ),
          //         softWrap: true, // Allow wrapping to next line if needed
          //       );
          //     }),
          //   ),
          // ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style,
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  "Get Current Location",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

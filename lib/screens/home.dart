import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:juno/Info_Handler/app_info.dart';
import 'package:juno/assistants/assistant_methods.dart';
import 'package:juno/global.dart';
import 'package:juno/models/directions.dart';
import 'package:juno/widgets/progress_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;

  AppInfoController appInfoController = Get.find();

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

  List<LatLng> pLineCordinatesList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String _userName = "";
  String _userEmail = "";

  bool openNavigationDrawer = true;
//   bool activeDriverNearbyKeysLoaded = false;

//   BitmapDescriptor? activeNearbyIcon;

  Future<void> drawPolylineFromOriginToDestination(bool isDarkTheme) async {
    var originPosition = appInfoController.userPickUpLocation;
    var destinationPosition = appInfoController.userDropoffLocation;
    var originLatlng = LatLng(originPosition.value!.locationLatitude!,
        originPosition.value!.locationLongitude!);
    var destnationLatlng = LatLng(destinationPosition.value!.locationLatitude!,
        destinationPosition.value!.locationLongitude!);
    Get.dialog(const ProgressDialog(
      task: "b",
    ));

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatlng, destnationLatlng);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Get.back();

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    pLineCordinatesList.clear();

    if (decodePolylinePointsResultList.isNotEmpty) {
      decodePolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId("PolylineID"),
        color: isDarkTheme ? Colors.green : Colors.blue,
        jointType: JointType.round,
        points: pLineCordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatlng.latitude > destnationLatlng.latitude &&
        originLatlng.longitude > destnationLatlng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destnationLatlng, northeast: originLatlng);
    } else if (originLatlng.longitude > destnationLatlng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatlng.latitude, destnationLatlng.longitude),
        northeast: LatLng(destnationLatlng.latitude, originLatlng.longitude),
      );
    } else if (originLatlng.latitude > destnationLatlng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destnationLatlng.latitude, originLatlng.longitude),
        northeast: LatLng(originLatlng.latitude, destnationLatlng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: originLatlng,
        northeast: destnationLatlng,
      );
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: MarkerId("origin_id"),
      infoWindow: InfoWindow(title: originPosition.value!.locationName,snippet: "Origin",),
      position: originLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destination_id"),
      infoWindow: InfoWindow(title: destinationPosition.value!.locationName,snippet: "Destination",),
      position: destnationLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId("origin_id"),
      center: originLatlng,
      radius: 12,
      strokeWidth: 3,
      fillColor: Colors.green,
      strokeColor: Colors.white,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destination_id"),
      center: destnationLatlng,
      radius: 12,
      strokeWidth: 3,
      fillColor: Colors.red,
      strokeColor: Colors.white,
    );


    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }

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

    _userName = userModelCurrentInfo!.name!;
    _userEmail = userModelCurrentInfo!.email!;
  }

  // method to fetch the info from cordinates at which the pin is i.e center of map[Camera positon target is alway at center]
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
    bool isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

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

            // Search UI
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 13),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkTheme
                        ? Colors.grey.shade300
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkTheme
                          ? Colors.grey.shade900
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: isDarkTheme
                                    ? Colors.amber.shade400
                                    : Colors.blue,
                                size: 32,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "From",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Obx(() {
                                    final pickUpLocation = appInfoController
                                        .userPickUpLocation.value;
                                    String displayedLocation =
                                        pickUpLocation?.locationName ??
                                            "Not Getting Address";

                                    if (displayedLocation !=
                                            "Not Getting Address" &&
                                        displayedLocation.length > 33) {
                                      displayedLocation =
                                          displayedLocation.substring(0, 33) +
                                              "...";
                                    }

                                    return Text(
                                      displayedLocation, // Add ellipsis after 25 characters
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            overflow: TextOverflow
                                                .ellipsis, // Enable ellipsis for overflowing text
                                          ),
                                      softWrap:
                                          true, // Allow wrapping to next line if needed
                                    );
                                  }),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Divider(
                          height: 1,
                          thickness: 2,
                          color:
                              isDarkTheme ? Colors.amber.shade400 : Colors.blue,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () async {
                            // Go to search places screen
                            String responseFromSearchScreen =
                                await Get.toNamed("/searchPlaces");
                            if (responseFromSearchScreen == "obtainedDropoff") {
                              openNavigationDrawer = false;
                            }

                            drawPolylineFromOriginToDestination(isDarkTheme);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: isDarkTheme
                                      ? Colors.amber.shade400
                                      : Colors.blue,
                                  size: 32,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "To",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    Obx(() {
                                      final dropoffLocation = appInfoController
                                          .userDropoffLocation.value;
                                      String displayedLocation =
                                          dropoffLocation?.locationName ??
                                              "Where To!";
                                      if (displayedLocation != "Where To!" &&
                                          displayedLocation.length > 36) {
                                        displayedLocation =
                                            displayedLocation.substring(0, 36) +
                                                "...";
                                      }

                                      return Text(
                                        displayedLocation,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              overflow: TextOverflow
                                                  .ellipsis, // Enable ellipsis for overflowing text
                                            ),
                                        softWrap:
                                            true, // Allow wrapping to next line if needed
                                      );
                                    }),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

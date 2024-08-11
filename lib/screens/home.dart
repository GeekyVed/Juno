import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:juno/Info_Handler/app_info.dart';
import 'package:juno/assistants/assistant_methods.dart';
import 'package:juno/assistants/geofire_assistants.dart';
import 'package:juno/global.dart';
import 'package:juno/models/active_nearby_available_drivers.dart';
import 'package:juno/screens/drawer.dart';
import 'package:juno/widgets/home_fare_picker.dart';
import 'package:juno/widgets/payfare_dialog.dart';
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

  double searchLocationContainerheight = 200;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  double searchingForDriverContainerHeight = 0;

  Position? userCurrentPosition;
//   // var geolocation = GeoLocatoer;

// //  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;
  double suggestedRideContainerHeight = 0;

  String selectedVehicleType = "";

  List<LatLng> pLineCordinatesList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String _userName = "";
  String _userEmail = "";

  bool openNavigationDrawer = true;
  bool activeDriverNearbyKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  DatabaseReference? referenceRideRequest;

  String driverRideStatus = "Driver is coming";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  String userRideRequestStatus = "";

  List<ActiveNearbyAvailableDrivers> onlineNearbyAwailableDriversList = [];

  bool requestPositionInfo = true;

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

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
      infoWindow: InfoWindow(
        title: originPosition.value!.locationName,
        snippet: "Origin",
      ),
      position: originLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destination_id"),
      infoWindow: InfoWindow(
        title: destinationPosition.value!.locationName,
        snippet: "Destination",
      ),
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

    initializeGeofireListener();
  }

  void initializeGeofireListener() {
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];
        switch (callBack) {
          // When driver becomes active/online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDrivers =
                ActiveNearbyAvailableDrivers(
              locationLatitude: map['latitude'],
              locationLongitude: map['longitude'],
              driverId: map['key'],
            );
            GeofireAssistants.activeNearbyAvailableDriversList
                .add(activeNearbyAvailableDrivers);
            if (activeDriverNearbyKeysLoaded == true) {
              displayActiveDriversOnUserMap();
            }
            break;

          // When any driver becomes unactive or offline
          case Geofire.onKeyExited:
            GeofireAssistants.deleteOfflineDriversFromList(map['key']);
            displayActiveDriversOnUserMap();
            break;

          // whenever driver moves : update driver location
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDrivers =
                ActiveNearbyAvailableDrivers(
              locationLatitude: map['latitude'],
              locationLongitude: map['longitude'],
              driverId: map['key'],
            );
            GeofireAssistants.updateActiveNearbyAvailableDriverLocation(
                activeNearbyAvailableDrivers);
            displayActiveDriversOnUserMap();
            break;

          // Display those active drivers on user map
          case Geofire.onGeoQueryReady:
            activeDriverNearbyKeysLoaded = true;
            displayActiveDriversOnUserMap();
            break;
        }
      }
      setState(() {});
    });
  }

  createActiveNearbyDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context,
              size: Size(
                0.02,
                0.02,
              ));
      BitmapDescriptor.asset(imageConfiguration, "lib/assets/images/car.jpg")
          .then((val) {
        activeNearbyIcon = val;
      });
    }
  }

  void displayActiveDriversOnUserMap() {
    setState(() {
      markerSet.clear();
      circleSet.clear();

      Set<Marker> driverMarkerSet = Set();
      for (ActiveNearbyAvailableDrivers eachDriver
          in GeofireAssistants.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition =
            LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driverMarkerSet.add(marker);
      }

      setState(() {
        markerSet = driverMarkerSet;
      });
    });
  }

  // method to fetch the info from cordinates at which the pin is i.e center of map[Camera positon target is alway at center]
  // void getLocationFromLatLng() async {
  //   try {
  //     String loc =
  //         await AssistantMethods.searchAddressForGeographicalCordinates_LatLng(
  //             pickLocation!, context);
  //     setState(() {
  //       Directions userPickupLocation = Directions();
  //       userPickupLocation.locationLatitude = pickLocation!.latitude;
  //       userPickupLocation.locationLongitude = pickLocation!.longitude;
  //       userPickupLocation.locationName = loc;
  //       _address = loc;

  //       appInfoController.updatePickupLocationAddress(userPickupLocation);
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

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

  void showSuggestedRidesContainer() {
    setState(() {
      suggestedRideContainerHeight = 460;
      bottomPaddingOfMap = 400;
    });
  }

  saveRideRequestInfomation(String selectedVehicle) {
    selectedVehicleType = selectedVehicle;
    // Save the ride request information
    referenceRideRequest =
        firebaseDatabase.ref().child("All Ride Requests").push();

    var originLocation = appInfoController.userPickUpLocation.value;
    var destinationLocation = appInfoController.userDropoffLocation.value;

    Map originLocationMap = {
      // key : value
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      // key : value
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
    };

    referenceRideRequest!.set(userInformationMap);

    tripRideRequestInfoStreamSubscription =
        referenceRideRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }
      if ((eventSnap.snapshot.value as Map)["car_details"] != null) {
        setState(() {
          driverCarDetails =
              (eventSnap.snapshot.value as Map)["car_details"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["driverName"] != null) {
        setState(() {
          driverName =
              (eventSnap.snapshot.value as Map)["driverName"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["driverPhone"] != null) {
        setState(() {
          driverPhone =
              (eventSnap.snapshot.value as Map)["driverPhone"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["status"] != null) {
        setState(() {
          userRideRequestStatus =
              (eventSnap.snapshot.value as Map)["status"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["driverLocation"] != null) {
        double driverCurrentPositionLat = double.parse(
            (eventSnap.snapshot.value as Map)["driverLocation"]["latitude"]
                .toString());
        double driverCurrentPositionLng = double.parse(
            (eventSnap.snapshot.value as Map)["driverLocation"]["longitude"]
                .toString());

        LatLng driverCurrentPositionLatLng =
            LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

        // Status accepted
        if (userRideRequestStatus == "accepted") {
          updateArrivalTimetToUserPickupLocation(driverCurrentPositionLatLng);
        }
        // Status arrived
        if (userRideRequestStatus == "arrived") {
          setState(() {
            driverRideStatus = "Driver has arrived";
          });
        }
        // Status ontrip
        if (userRideRequestStatus == "ontrip") {
          updateReachingTimetToUserDropoffLocation(driverCurrentPositionLatLng);
        }
        // Status ended
        if (userRideRequestStatus == "ended") {
          if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
            double fareAmount = double.parse(
                (eventSnap.snapshot.value as Map)["fareAmount"].toString());

            var response =
                await Get.dialog(PayfareDialog(fareAmount: fareAmount));

            if (response == "Cash Paid") {
              // User can rate the driver now
              if ((eventSnap.snapshot.value as Map)["driverId"] != null) {
                String assignedDriverId =
                    (eventSnap.snapshot.value as Map)["driverId"].toString();
                Get.toNamed("/rate_driver");

                referenceRideRequest!.onDisconnect();
                tripRideRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }
      }
    });

    onlineNearbyAwailableDriversList =
        GeofireAssistants.activeNearbyAvailableDriversList;
    print(onlineNearbyAwailableDriversList);
    searchNearbyOnlineDrivers(selectedVehicleType);
  }

  searchNearbyOnlineDrivers(String selectedVehicleType) async {
    if (onlineNearbyAwailableDriversList.isEmpty) {

      // cancel/ delte the ride request informatrion
      referenceRideRequest!.remove();

      setState(() {
        polylineSet.clear();
        markerSet.clear();
        circleSet.clear();
        pLineCordinatesList.clear();
      });

      Fluttertoast.showToast(
        msg: "No Online nearby drivers available!",
        backgroundColor: Colors.red,
        fontSize: 16,
      );
      Fluttertoast.showToast(
        msg: "Search again\nRestarting app...",
        backgroundColor: Colors.red,
        fontSize: 16,
      );

      Future.delayed(
          const Duration(
            milliseconds: 4000,
          ), () {
        referenceRideRequest!.remove();
        Get.offAndToNamed("/home");
      });

      return;
    }

    await retreiveOnlineDriversInformation(onlineNearbyAwailableDriversList);
    for (int i = 0; i < driversList.length; i++) {
      if (driversList[i]["car_details"]["selectedCarType"] == selectedVehicleType) {
        AssistantMethods.sendNotificationToDriverNow(
            driversList[i]["token"], referenceRideRequest!.key!, context);
      }
    }

    Fluttertoast.showToast(
      msg: "Notification Sent Succesfully!",
      backgroundColor: Colors.green,
      fontSize: 16,
    );

    showSearchingForDriversContainer();

    await firebaseDatabase
        .ref()
        .child("All Ride Requests")
        .child(referenceRideRequest!.key!)
        .child("driverId")
        .onValue
        .listen((eventRideRequestSnapshot) {
      print("Event Snapshot : ${eventRideRequestSnapshot.snapshot.value}");
      if (eventRideRequestSnapshot.snapshot.value != null) {
        if (eventRideRequestSnapshot.snapshot.value != "waiting") {
          showUiForAssignedDriverInfo();
        }
      }
    });
  }

  showUiForAssignedDriverInfo() {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerheight = 0;
      assignedDriverInfoContainerHeight = 200;
      suggestedRideContainerHeight = 0;
      bottomPaddingOfMap = 200;
    });
  }

  void showSearchingForDriversContainer() {
    setState(() {
      searchingForDriverContainerHeight = 250;
    });
  }

  retreiveOnlineDriversInformation(List onlineNearbyDriversList) async {
    driversList.clear();
    DatabaseReference ref = firebaseDatabase.ref().child("drivers");

    for (int i = 0; i < onlineNearbyDriversList.length; i++) {
      await ref
          .child(onlineNearbyDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;

        driversList.add(driverKeyInfo);
      });
    }
  }

  updateArrivalTimetToUserPickupLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userPickupPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userPickupPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus = "Driver is coming: " +
            directionDetailsInfo.duration_text.toString();
      });
      requestPositionInfo = true;
    }
  }

  updateReachingTimetToUserDropoffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;
      var dropoffLocation = appInfoController.userDropoffLocation.value;

      var userDestinationPosition = LatLng(dropoffLocation!.locationLatitude!,
          dropoffLocation.locationLongitude!);

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              driverCurrentPositionLatLng, userDestinationPosition);

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus = "Going towards destination: " +
            directionDetailsInfo.duration_text.toString();
      });
      requestPositionInfo = true;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLocationPermission();
    // Undo in case of error @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    locateUserPosition();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    createActiveNearbyDriverIconMarker();
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        key: _scaffoldState,
        drawer: const DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(
                top: 30,
                bottom: bottomPaddingOfMap,
              ),

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
              // onCameraMove: (CameraPosition? newCameraPosition) {
              //   if (pickLocation != newCameraPosition!.target) {
              //     setState(() {
              //       pickLocation = newCameraPosition.target;
              //     });
              //   }
              // },
              // onCameraIdle: () {
              //   // This is the scenario that pickup location is diff form current location
              //   getLocationFromLatLng();
              // },
            ),
            // Dislaying a locaiotn pin in center of screen to represent the pickup location of user
            // Align(
            //   alignment: Alignment.center,
            //   child: Padding(
            //     padding: const EdgeInsets.only(bottom: 35.0),
            //     child: Image.asset(
            //       "lib/assets/icons/location_pin.png",
            //       height: 50,
            //       width: 50,
            //     ),
            //   ),
            // ),

            // Custom Hamburger icon
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                child: GestureDetector(
                  onTap: () {
                    _scaffoldState.currentState!.openDrawer();
                  },
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    child: Icon(
                      Icons.menu,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              ),
            ),

            // Locaiton UI
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
                      mainAxisSize: MainAxisSize.min,
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
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: GoogleFonts.quicksand(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                  minimumSize: const Size(double.infinity, 53),
                                ),
                                onPressed: () {
                                  Get.toNamed('/precisePickupLocation');
                                },
                                child: Text(
                                  "Change Pick Up",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        fontSize: 17,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 13,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: GoogleFonts.quicksand(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                  minimumSize: const Size(double.infinity, 53),
                                ),
                                onPressed: () {
                                  if (appInfoController.userDropoffLocation
                                          .value?.locationName !=
                                      null) {
                                    showSuggestedRidesContainer();
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Please select destination location!",
                                      backgroundColor: Colors.red,
                                      fontSize: 16,
                                    );
                                  }
                                },
                                child: Text(
                                  "Show Fare",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        fontSize: 17,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // UI for suggested rides
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeFarePicker(
                suggestedRideContainerHeight: suggestedRideContainerHeight,
                saveRideRequestInfomation: saveRideRequestInfomation,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: searchingForDriverContainerHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface, 
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      LinearProgressIndicator(
                        color: Colors.blue, // Edit color here
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Searching for a driver...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.red, // Edit color here
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          iconSize: 25,
                          onPressed: () {
                            setState(() {
                              searchingForDriverContainerHeight = 0;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            // Add your onPressed action here
                          },
                          child: Text('Cancel',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.red,
                                  )),
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

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:juno/Info_Handler/app_info.dart';
import 'package:juno/assistants/request_assistant.dart';
import 'package:juno/global.dart';
import 'package:juno/models/direction_details_info.dart';
import 'package:juno/models/directions.dart';
import 'package:juno/models/user_model.dart';
import 'package:juno/rates.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;

    DatabaseReference ref =
        firebaseDatabase.ref().child("users").child(currentUser!.uid);
    ref.once().then((snap) {
      if (snap.snapshot.value != null) {
        DataSnapshot snapshot = snap.snapshot;
        userModelCurrentInfo = UserModel.fromSnapshot(snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicalCordinates_Position(
      Position position, context) async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";
    String humanReadableAddress = "";
    var responseData = await RequestAssistant.recieveRequest(apiUrl);

    if (responseData != null) {
      humanReadableAddress = responseData["results"][0]["formatted_address"];

      Directions userPickupLocation = Directions();
      userPickupLocation.locationLatitude = position.latitude;
      userPickupLocation.locationLongitude = position.longitude;
      userPickupLocation.locationName = humanReadableAddress;

      AppInfoController appInfoController = Get.find();
      appInfoController.updatePickupLocationAddress(userPickupLocation);
    } else {
      return "Error Fetching Address";
    }
    return humanReadableAddress;
  }

  static Future<String> searchAddressForGeographicalCordinates_LatLng(
      LatLng position, context) async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";
    String humanReadableAddress = "";
    var responseData = await RequestAssistant.recieveRequest(apiUrl);

    if (responseData != null) {
      humanReadableAddress = responseData["results"][0]["formatted_address"];

      Directions userPickupLocation = Directions();
      userPickupLocation.locationLatitude = position.latitude;
      userPickupLocation.locationLongitude = position.longitude;
      userPickupLocation.locationName = humanReadableAddress;
    } else {
      return "Error Fetching Address";
    }
    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng originPosition, LatLng destinationPosition) async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    String apiURLOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}"
        "&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$apiKey";

    var responseDirectionApi = await RequestAssistant.recieveRequest(
        apiURLOriginToDestinationDirectionDetails);

    if (responseDirectionApi != null) {
      DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
      directionDetailsInfo.e_points =
          responseDirectionApi['routes'][0]['overview_polyline']['points'];
      directionDetailsInfo.distance_text =
          responseDirectionApi['routes'][0]['legs'][0]['distance']['text'];
      directionDetailsInfo.distance_value =
          responseDirectionApi['routes'][0]['legs'][0]['distance']['value'];
      directionDetailsInfo.duration_text =
          responseDirectionApi['routes'][0]['legs'][0]['duration']['text'];
      directionDetailsInfo.duration_value =
          responseDirectionApi['routes'][0]['legs'][0]['duration']['value'];

      return directionDetailsInfo;
    } else {
      return null;
    }
  }

  static double calculateFareAmounFromoriginToDestination(
    DirectionDetailsInfo directionDetailsInfo,
    VehicleType vehicleType,
  ) {
    // Calculate distance-based fare
    double distanceFare =
        (directionDetailsInfo.distance_value! / 1000) * RideRates.perKmRate;

    // Calculate time-based fare
    double timeFare =
        (directionDetailsInfo.duration_value! / 60) * RideRates.perMinuteRate;

    // Choose the higher of distance-based or time-based fare
    double variableFare = distanceFare > timeFare ? distanceFare : timeFare;

    // Add base fare
    double subtotal = RideRates.baseFare + variableFare;

    // Apply surge multiplier
    double surgeMultiplier;
    switch (vehicleType) {
      case VehicleType.car:
        surgeMultiplier = RideRates.carSurgeMultiplier;
        break;
      case VehicleType.bike:
        surgeMultiplier = RideRates.bikeSurgeMultiplier;
        break;
      case VehicleType.auto:
        surgeMultiplier = RideRates.autoSurgeMultiplier;
        break;
    }

    double totalFare = subtotal * surgeMultiplier;

    // Ensure the fare is not less than the minimum fare
    totalFare =
        totalFare < RideRates.minimumFare ? RideRates.minimumFare : totalFare;

    return double.parse(totalFare.toStringAsFixed(1));
  }

  static sendNotificationToDriverNow(
      String deviceRegistrationToken, String userRideRequestid, context) async {
    try {
      String destinationAddress = userDropoffAddress;
      final String serverKey = await getAccessToken(); // Your FCM server key
      const String fcmEndpoint =
          'https://fcm.googleapis.com/v1/projects/juno-5600e/messages:send';

      Map<String, String> headerNotification = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      };

      Map bodyNotification = {
        "body": "Destination Address: \n$destinationAddress.",
        "title": "New Trip Request"
      };

      Map dataMap = {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "rideRequestId": userRideRequestid,
      };

      Map<String, dynamic> officialNotificationFormat = {
        'message': {
          'token': deviceRegistrationToken,
          'notification': bodyNotification,
          'data': dataMap,
          'android': {
            'priority': 'high',
          },
          'apns': {
            'payload': {
              'aps': {
                'contentAvailable':
                    true, // This helps with background data delivery
              },
            },
            'headers': {
              'apns-priority': '10', // High priority for iOS
            },
          },
        },
      };

      final http.Response response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: headerNotification,
        body: jsonEncode(officialNotificationFormat),
      );
      if (response.statusCode == 200) {
        print('FCM message sent successfully');
      } else {
        print('Failed to send FCM message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error Sending FCM Notif...Catch bolck $e');
    }
  }

  /// Converts the 'JUNO_SERVICE_JSON' environment variable into a Map.
  /// Returns `null` if the environment variable is not found or is invalid JSON.
  static Map<String, dynamic>? getJunoServiceMap() {
    // Retrieve the JSON string from the environment variables
    String? jsonString = dotenv.env['JUNO_SERVICE_JSON'];

    // Decode the JSON string into a map if it's not null
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding JUNO_SERVICE_JSON: $e');
        return null;
      }
    } else {
      print('JUNO_SERVICE_JSON is not found in the environment variables.');
      return null;
    }
  }

  static Future<String> getAccessToken() async {
    // Your client ID and client secret obtained from Google Cloud Console
    final serviceAccountJson = getJunoServiceMap();

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Obtain the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    // Close the HTTP client
    client.close();

    // Return the access token
    return credentials.accessToken.data;
  }
}

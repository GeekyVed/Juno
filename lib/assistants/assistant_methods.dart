import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:juno/assistants/request_assistant.dart';
import 'package:juno/global.dart';
import 'package:juno/models/directions.dart';
import 'package:juno/models/user_model.dart';

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    currentUser = await firebaseAuth.currentUser;

    DatabaseReference ref =
        firebaseDatabase.ref().child("users").child(currentUser!.uid);
    ref.once().then((snap) {
      if (snap.snapshot.value != null) {
        DataSnapshot snapshot = snap.snapshot;
        userModelCurrentinfo = UserModel.fromSnapshot(snapshot);
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
}

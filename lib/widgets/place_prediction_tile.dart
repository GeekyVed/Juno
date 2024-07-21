import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juno/Info_Handler/app_info.dart';
import 'package:juno/assistants/request_assistant.dart';
import 'package:juno/global.dart';
import 'package:juno/models/directions.dart';
import 'package:juno/models/predicted_places.dart';
import 'package:juno/widgets/progress_dialog.dart';

class PlacePredictionTile extends StatefulWidget {
  const PlacePredictionTile({required this.predictedPlaces, super.key});

  final PredictedPlaces predictedPlaces;

  @override
  State<PlacePredictionTile> createState() => _PlacePredictionTileState();
}

class _PlacePredictionTileState extends State<PlacePredictionTile> {
  @override
  AppInfoController appInfoController = Get.find();

  void getPlacesDirectionDetails(String placeId, context) async {
    Get.dialog(
      const ProgressDialog(task: "a",),
    );

    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

    String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
    String placeDirectionDetailUrl = '$baseUrl?place_id=$placeId&key=$apiKey';

    try {
      var responseApi =
          await RequestAssistant.recieveRequest(placeDirectionDetailUrl);
      Directions userDropoffLocation = Directions();
      userDropoffLocation.locationLatitude =
          responseApi['result']['geometry']['location']['lat'];
      userDropoffLocation.locationLongitude =
          responseApi['result']['geometry']['location']['lng'];
      userDropoffLocation.locationName = responseApi['result']['name'];
      userDropoffLocation.locationId = placeId;

      appInfoController.updateDropoffLocationAddress(userDropoffLocation);
      setState(() {
        userDropoffAddress = userDropoffLocation.locationName!;
      });
    } catch (error) {
      return;
    }

    // Closing the dialog box
    Get.back();

    // Closing the search box
    Get.back(result: "obtainedDropoff");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 23, 14, 0),
      child: ElevatedButton(
        onPressed: () {
          getPlacesDirectionDetails(widget.predictedPlaces.place_id!, context);
        },
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.quicksand(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              18,
            ),
          ),
          minimumSize: const Size(double.infinity, 60),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 14,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.add_location,
                color: Colors.blue,
                size: 34,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.predictedPlaces.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    widget.predictedPlaces.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}

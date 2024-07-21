import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:juno/assistants/request_assistant.dart';
import 'package:juno/models/predicted_places.dart';
import 'package:juno/widgets/place_prediction_tile.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> predictedPlacesList = [];

  void findPlaceAutocompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
      String baseUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String urlAutocompleteSearch =
          '$baseUrl?input=$inputText&key=$apiKey&components=country:in';
      try {
        var responseAutoCompleteSearch =
            await RequestAssistant.recieveRequest(urlAutocompleteSearch);
        var placePrediction = responseAutoCompleteSearch['predictions'];

        var placePredictionList = (placePrediction as List)
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();
        setState(() {
          predictedPlacesList = placePredictionList;
        });
      } catch (e) {
        throw "Error Occured : $e";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
          title: Text(
            "Search & Set Dropoff",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onInverseSurface,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    blurRadius: 9,
                    spreadRadius: 0.5,
                    offset: Offset(0.1, 0.1),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(17, 0, 17, 6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.adjust_sharp,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(
                              8,
                            ),
                            child: TextField(
                              onChanged: (value) {
                                findPlaceAutocompleteSearch(value);
                              },
                              style: Theme.of(context).textTheme.labelMedium,
                              decoration: InputDecoration(
                                label: const Text(
                                  "Search Location Here...",
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                                labelStyle:
                                    Theme.of(context).textTheme.labelMedium,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    18,
                                  ),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
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
            // Display Predicted Places
            if (predictedPlacesList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: predictedPlacesList.length,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return PlacePredictionTile(
                        predictedPlaces: predictedPlacesList[index]);
                  },
                  
                ),
              ),
          ],
        ),
      ),
    );
  }
}

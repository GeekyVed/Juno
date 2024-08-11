import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:juno/Info_Handler/app_info.dart';
import 'package:juno/assistants/assistant_methods.dart';
import 'package:juno/global.dart';
import 'package:juno/rates.dart';

class HomeFarePicker extends StatefulWidget {
  HomeFarePicker({
    super.key,
    required this.suggestedRideContainerHeight,
    required this.saveRideRequestInfomation,
  });

  final double suggestedRideContainerHeight;
  final Function(String) saveRideRequestInfomation;

  @override
  State<HomeFarePicker> createState() => _HomeFarePickerState();
}

class _HomeFarePickerState extends State<HomeFarePicker> {
  AppInfoController appInfoController = Get.find();

  String selectedVehicleType = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.suggestedRideContainerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      color: Colors.green),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Obx(() {
                  final pickUpLocation =
                      appInfoController.userPickUpLocation.value;
                  String displayedLocation =
                      pickUpLocation?.locationName ?? "Not Getting Address";

                  if (displayedLocation != "Not Getting Address" &&
                      displayedLocation.length > 37) {
                    displayedLocation =
                        displayedLocation.substring(0, 37) + "...";
                  }

                  return Text(
                    displayedLocation, // Add ellipsis after 25 characters
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          overflow: TextOverflow
                              .ellipsis, // Enable ellipsis for overflowing text
                        ),
                    softWrap: true, // Allow wrapping to next line if needed
                  );
                }),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Obx(() {
                  final dropoffLocation =
                      appInfoController.userDropoffLocation.value;
                  String displayedLocation =
                      dropoffLocation?.locationName ?? "Where To!";
                  if (displayedLocation != "Where To!" &&
                      displayedLocation.length > 37) {
                    displayedLocation =
                        displayedLocation.substring(0, 37) + "...";
                  }

                  return Text(
                    displayedLocation,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          overflow: TextOverflow
                              .ellipsis, // Enable ellipsis for overflowing text
                        ),
                    softWrap: true, // Allow wrapping to next line if needed
                  );
                }),
              ],
            ),
            SizedBox(
              height: 18,
            ),
            Text(
              "SUGGESTED RIDES",
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  overflow: TextOverflow
                      .ellipsis, // Enable ellipsis for overflowing text
                  fontSize: 19),
              softWrap: true,
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVehicleType = "Car";
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: selectedVehicleType == "Car"
                            ? Theme.of(context).colorScheme.onTertiary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(21.0),
                      child: Column(
                        children: [
                          Image.asset(
                            "lib/assets/images/car_fare.png",
                            scale: 2,
                            height: 35,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Car",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    fontWeight: selectedVehicleType == "Car"
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: selectedVehicleType == "Car"
                                        ? Theme.of(context)
                                            .colorScheme
                                            .inverseSurface
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                              tripDirectionDetailsInfo != null
                                  ? "₹ ${AssistantMethods.calculateFareAmounFromoriginToDestination(
                                      tripDirectionDetailsInfo!,
                                      VehicleType.car,
                                    )}"
                                  : "null",
                              style: Theme.of(context).textTheme.labelMedium!)
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVehicleType = "Bike";
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: selectedVehicleType == "Bike"
                            ? Theme.of(context).colorScheme.onTertiary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(21.0),
                      child: Column(
                        children: [
                          Image.asset(
                            "lib/assets/images/bike_fare.png",
                            scale: 2,
                            height: 47,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Bike",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    fontWeight: selectedVehicleType == "Bike"
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: selectedVehicleType == "Bike"
                                        ? Theme.of(context)
                                            .colorScheme
                                            .inverseSurface
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                              tripDirectionDetailsInfo != null
                                  ? "₹ ${AssistantMethods.calculateFareAmounFromoriginToDestination(
                                      tripDirectionDetailsInfo!,
                                      VehicleType.bike,
                                    )}"
                                  : "null",
                              style: Theme.of(context).textTheme.labelMedium!)
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVehicleType = "Auto";
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: selectedVehicleType == "Auto"
                            ? Theme.of(context).colorScheme.onTertiary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(21.0),
                      child: Column(
                        children: [
                          Image.asset(
                            "lib/assets/images/auto_fare.png",
                            scale: 2,
                            height: 47,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Auto",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    fontWeight: selectedVehicleType == "Auto"
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: selectedVehicleType == "Auto"
                                        ? Theme.of(context)
                                            .colorScheme
                                            .inverseSurface
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                              tripDirectionDetailsInfo != null
                                  ? "₹ ${AssistantMethods.calculateFareAmounFromoriginToDestination(
                                      tripDirectionDetailsInfo!,
                                      VehicleType.auto,
                                    )}"
                                  : "null",
                              style: Theme.of(context).textTheme.labelMedium!)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed: () {
                if (selectedVehicleType != "") {
                  widget.saveRideRequestInfomation(selectedVehicleType);
                } else {
                  Fluttertoast.showToast(
                    msg: "Please select a vehicle from\nsuggested vehicles!",
                    backgroundColor: Colors.red,
                    fontSize: 16,
                  );
                }
              },
              child: Text(
                "Request a ride",
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

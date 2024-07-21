import 'package:get/get.dart';
import 'package:juno/models/directions.dart';

class AppInfoController extends GetxController {
  Rx<Directions?> userPickUpLocation = Rx<Directions?>(null);
  Rx<Directions?> userDropoffLocation = Rx<Directions?>(null);
  RxInt countTotalTrips = 0.obs;
  // RxList<String> historyTripsKeyList = <String>[].obs;
  // RxList<TripsHistoryModel> alTripsHistoryInformationList = <TripsHistoryModel>[].obs;

  void updatePickupLocationAddress(Directions userPickupAddress) {
    userPickUpLocation.value = userPickupAddress;
  }

  void updateDropoffLocationAddress(Directions dropoffAddress) {
    userDropoffLocation.value = dropoffAddress;
  }
}
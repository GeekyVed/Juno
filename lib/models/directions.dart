class Directions {
  String? humanReadableAddress;
  String? locationName;
  String? locationId;
  double? locationLatitude;
  double? locationLongitude;

  Directions({
    this.humanReadableAddress,
    this.locationName,
    this.locationId,
    this.locationLatitude,
    this.locationLongitude,
  });

  void printDetails() {
    print('Human Readable Address: $humanReadableAddress');
    print('Location Name: $locationName');
    print('Location ID: $locationId');
    print('Location Latitude: $locationLatitude');
    print('Location Longitude: $locationLongitude');
  }
}

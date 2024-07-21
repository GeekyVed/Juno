class PredictedPlaces {
  String? place_id;
  String? main_text;
  String? secondary_text;

  PredictedPlaces({
    this.place_id,
    this.main_text,
    this.secondary_text,
  });

  PredictedPlaces.fromJson(Map<String, dynamic> data) {
    place_id = data['place_id'];
    main_text = data['structured_formatting']['main_text'];
    secondary_text = data['structured_formatting']['secondary_text'];
  }
}

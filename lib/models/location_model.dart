class LocationModel {
  String address;
  double latitude;
  double longitude;
  int reportNumber;
  List<String> crimeImages;

  LocationModel({
    this.address,
    this.latitude,
    this.longitude,
    this.reportNumber,
    this.crimeImages,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        address: json["address"] == null ? null : json["address"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
        reportNumber:
            json["report_number"] == null ? null : json["report_number"],
        crimeImages: json["crime_images"] == null
            ? null
            : List<String>.from(json["crime_images"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "address": address == null ? null : address,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
        "report_number": reportNumber == null ? null : reportNumber,
        "crime_images": crimeImages == null
            ? null
            : List<dynamic>.from(crimeImages.map((x) => x)),
      };
}

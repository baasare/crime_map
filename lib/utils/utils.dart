import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

List<String> _places = [];
var uuid = new Uuid();
String _sessionToken = uuid.v4();

String capitalize(String string) {
  if (string == null) {
    throw ArgumentError("string: $string");
  }

  if (string.isEmpty) {
    return string;
  }

  return string[0].toUpperCase() + string.substring(1);
}

int hexColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return int.parse(hexColor, radix: 16);
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
      .buffer
      .asUint8List();
}

Future<List> getLocations({String input}) async {
  String baseURL =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  String request =
      '$baseURL?input=$input&key=${FlutterConfig.get('GOOGLE_MAPS_API_KEY')}&components=country:gh&sessiontoken=$_sessionToken';

  var httpResponse = await http.get(Uri.parse(request));

  final httpBody = json.decode(httpResponse.body);
  final httpPredictions = httpBody['predictions'];

  _places.clear();

  for (var i = 0; i < httpPredictions.length; i++) {
    String name = httpPredictions[i]['description'];
    _places.add(name);
  }
  return _places;
}

Future<LatLng> getLocationFormAddress(String address) async {
  String baseURL = 'https://maps.googleapis.com/maps/api/geocode/json';

  String request =
      '$baseURL?address=$address&key=${FlutterConfig.get('GOOGLE_MAPS_API_KEY')}';

  var httpResponse = await http.get(Uri.parse(request));
  final httpBody = json.decode(httpResponse.body);
  final httpResults = httpBody['results'];
  final httpGeometry = httpResults[0]['geometry'];
  final httpLocation = httpGeometry['location'];

  LatLng position = LatLng(httpLocation["lat"], httpLocation["lng"]);

  return position;
}

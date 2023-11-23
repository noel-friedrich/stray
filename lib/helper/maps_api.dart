import 'dart:convert';

import '../constants/api_keys.dart';
import 'coin_generator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GoogleMapsApi {
  static String nearestRoadUrl =
      "https://roads.googleapis.com/v1/nearestRoads?key=";

  static Future<List<Position?>> getNearestRoadPositions(
      List<Position> positions) async {
    if (positions.length > 100) {
      throw Exception("Cannot process more than 100 at a time");
    }

    String url = nearestRoadUrl;
    url += "$secretGoogleMapsApiKey&points=";
    for (Position pos in positions) {
      url += "${pos.latitude},${pos.longitude}|";
    }
    url = url.substring(0, url.length - 1);

    List<Position?> results = [];
    for (int i = 0; i < positions.length; i++) {
      results.add(null);
    }

    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> answerMap = jsonDecode(response.body);
      if (answerMap.containsKey("snappedPoints")) {
        List<dynamic> points = answerMap["snappedPoints"];
        for (Map<String, dynamic> point in points) {
          Map<String, dynamic> location = point["location"];
          double latitude = location["latitude"];
          double longitude = location["longitude"];
          Position pos = CoinGenerator.positionFromLatLon(latitude, longitude);
          int originalIndex = point["originalIndex"];
          results[originalIndex] = pos;
        }
      }
    }

    return results;
  }

  static Future<Position?> getNearestRoadPosition(Position pos) async {
    String url = nearestRoadUrl;
    url += "$secretGoogleMapsApiKey&points=${pos.latitude},${pos.longitude}";
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> answerMap = jsonDecode(response.body);
      if (answerMap.containsKey("snappedPoints")) {
        List<dynamic> points = answerMap["snappedPoints"];
        if (points.isNotEmpty) {
          Map<String, dynamic> firstPoint = points[0];
          Map<String, dynamic> location = firstPoint["location"];
          double latitude = location["latitude"];
          double longitude = location["longitude"];
          return CoinGenerator.positionFromLatLon(latitude, longitude);
        }
      }
    }

    return null;
  }
}

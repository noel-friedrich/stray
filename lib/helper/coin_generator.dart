import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'maps_api.dart';
import '../database/database.dart';

class CoinGenerator {
  static int meterToReward(double meters) {
    return (meters / 10).ceil();
  }

  static Position positionFromLatLon(double lat, double lon) {
    return Position(
        longitude: lon,
        latitude: lat,
        timestamp: DateTime(0),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0);
  }

  static String positionToString(Position p) {
    return "${p.latitude},${p.longitude}";
  }

  static Position positionFromString(String s) {
    List<String> parts = s.split(",");
    double lat = double.parse(parts[0]);
    double lon = double.parse(parts[1]);
    return positionFromLatLon(lat, lon);
  }

  static double distanceBetween(Position a, Position b) {
    return Geolocator.distanceBetween(
        a.latitude, a.longitude, b.latitude, b.longitude);
  }

  static Position _generateCoinPosAttempt(
      Position userPosition, double distanceKm) {
    Random rng = Random();
    double randomAngle = rng.nextDouble() * pi * 2;
    double directionX = cos(randomAngle) *
        2; // * 2 is necessary as longitudes have half the range
    double directionY = sin(randomAngle);
    double stepSize = 0.0001;

    Position newPosition =
        positionFromLatLon(userPosition.latitude, userPosition.longitude);

    double randomOffset = rng.nextDouble() * 250 - 100;

    while (distanceBetween(newPosition, userPosition) <
        (distanceKm * 1000 + randomOffset)) {
      newPosition = positionFromLatLon(
        newPosition.latitude + directionY * stepSize,
        newPosition.longitude + directionX * stepSize,
      );
    }

    return newPosition;
  }

  static int maxGenerationAttempts = 10;

  static _generateCoinPosBatch(userPosition, distanceKm) {
    List<Position> points = [];
    for (int i = 0; i < 100; i++) {
      points.add(_generateCoinPosAttempt(userPosition, distanceKm));
    }
    return points;
  }

  static Future<Position?> generateCoinPos(
      Position userPosition, double distanceKm) async {
    for (int i = 0; i < maxGenerationAttempts; i++) {
      List<Position> candidates =
          _generateCoinPosBatch(userPosition, distanceKm);

      if (Database.getSetting("unsafe_coins").booleanValue &&
          candidates.isNotEmpty) {
        return candidates[0];
      }

      List<Position?> nearestStreetPositions =
          await GoogleMapsApi.getNearestRoadPositions(candidates);

      for (Position? position in nearestStreetPositions) {
        if (position != null) {
          print("Successfully generated new Coin-Position: $position");
          return position;
        }
      }

      print(
          "Attempt at generating Coin Position failed (tried ${candidates.length} points)");
    }

    return null;
  }
}

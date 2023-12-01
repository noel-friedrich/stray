import 'dart:async';
import 'dart:math';

import 'package:Stray/database/database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../helper/geo.dart';

class MapRadiusWidget extends StatefulWidget {
  const MapRadiusWidget({Key? key, required this.radius}) : super(key: key);

  final double radius;

  @override
  State<MapRadiusWidget> createState() => _MapRadiusWidgetState();
}

class _MapRadiusWidgetState extends State<MapRadiusWidget> {
  static const String mapStyle =
      '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]';

  GoogleMapController? _mapController;
  Timer? refreshTimer;

  LatLng? userLocation;

  double currCircleRadius = 3000;

  bool foundLocation() {
    return userLocation != null;
  }

  Future<void> loadPosition() async {
    try {
      Position pos = await Geo.getPos();
      setState(() {
        userLocation = latLngFromPosition(pos);
      });
    } catch (e) {
      // ignore
    }
  }

  double calculateZoomLevel() {
    return 1.4761111111111109e+001 +
        -1.5966666666666601e-003 * currCircleRadius +
        1.4888888888888757e-007 * pow(currCircleRadius, 2);
  }

  Future<void> updateRadius() async {
    if (widget.radius == currCircleRadius) {
      return;
    }

    setState(() {
      currCircleRadius = widget.radius;
    });

    _mapController?.moveCamera(CameraUpdate.newLatLng(userLocation!));
    _mapController?.animateCamera(CameraUpdate.zoomTo(calculateZoomLevel()));
  }

  @override
  void initState() {
    super.initState();
    _mapController?.setMapStyle(mapStyle);
    loadPosition();
    currCircleRadius = widget.radius;

    refreshTimer =
        Timer.periodic(const Duration(milliseconds: 100), (Timer timer) async {
      if (!mounted || !foundLocation()) return;
      updateRadius();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
      _mapController?.setMapStyle(mapStyle);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!foundLocation()) {
      return Container();
    }

    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: CameraPosition(
            target: userLocation!,
            zoom: calculateZoomLevel(),
          ),
          onMapCreated: _onMapCreated,
          myLocationButtonEnabled: true,
          onCameraMove: null,
          circles: {
            Circle(
              circleId: const CircleId("circle"),
              center: userLocation!,
              radius: currCircleRadius,
              strokeColor: Theme.of(context).colorScheme.secondary,
            )
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    refreshTimer?.cancel();
  }
}

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'mission_card.dart';
import '../../database/database.dart';

class MissionsMap extends StatefulWidget {
  const MissionsMap({Key? key, required this.missions, this.selectedMission})
      : super(key: key);

  final List<MissionInfo> missions;
  final MissionInfo? selectedMission;

  @override
  State<MissionsMap> createState() => _MissionsMapState();
}

class _MissionsMapState extends State<MissionsMap> {
  static const String mapStyle =
      '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]';

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> lines = {};
  BitmapDescriptor? _coinMarker;

  MissionInfo? selectedMission;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void addMarker(LatLng position, MissionInfo mission, String name,
      BitmapDescriptor markerImage) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(position.hashCode.toString()),
        position: position,
        icon: markerImage,
        infoWindow: InfoWindow(
          title: name,
        ),
        onTap: () {
          if (widget.selectedMission != null) return;
          setState(() {
            selectedMission = mission;
          });
        },
      ));
    });
  }

  LatLng scramblePosition(LatLng pos, {double distance = 0.00001}) {
    Random rng = Random();
    double angle = rng.nextDouble() * 2 * pi;
    return LatLng(
      pos.latitude + sin(angle) * distance,
      pos.longitude + cos(angle) * distance,
    );
  }

  Future<void> initMarkers() async {
    _coinMarker = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/images/coin.png', 100));

    int i = 0;
    for (MissionInfo mission in widget.missions) {
      addMarker(
        scramblePosition(latLngFromPosition(mission.startPosition)),
        mission,
        "Mission #${i + 1} Start",
        BitmapDescriptor.defaultMarkerWithHue(hueFromIndex(i)),
      );

      addMarker(
        latLngFromPosition(mission.coinPosition),
        mission,
        "Mission #${i + 1} End",
        _coinMarker!,
      );

      i++;
    }
  }

  double hueFromIndex(int index) {
    if (widget.missions.length <= 1) return 56;
    return index / widget.missions.length * 359.9;
  }

  Color colorFromIndex(int index) {
    double hue = hueFromIndex(index);
    HSLColor hslColor = HSLColor.fromAHSL(1.0, hue, 1.0, 0.5);
    return hslColor.toColor();
  }

  void initLines() {
    int i = 0;
    for (MissionInfo mission in widget.missions) {
      Polyline line = Polyline(
        polylineId: PolylineId("${mission}line"),
        color: colorFromIndex(i),
        points: <LatLng>[
          latLngFromPosition(mission.startPosition),
          latLngFromPosition(mission.coinPosition),
        ],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        width: 8,
      );
      lines.add(line);

      i++;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectedMission != null) {
      selectedMission = widget.selectedMission;
    }
    _mapController?.setMapStyle(mapStyle);
    initMarkers();
    initLines();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
      _mapController?.setMapStyle(mapStyle);
    });
  }

  LatLng getStartPosition() {
    if (widget.missions.isEmpty) {
      return const LatLng(52.322173, 10.227058);
    } else {
      return LatLng(
        widget.missions.fold(0.0, (v, m) => m.middleLatLng.latitude + v) /
            widget.missions.length,
        widget.missions.fold(0.0, (v, m) => m.middleLatLng.longitude + v) /
            widget.missions.length,
      );
    }
  }

  double getStartZoom() {
    double minZoom = 12.2746;
    double maxZoom = 14.4746;
    double maxDistance = 5500;

    if (widget.missions.isEmpty) {
      return (minZoom + maxZoom) / 2;
    } else {
      double zoom = maxZoom;
      for (MissionInfo mission in widget.missions) {
        double distanceQuotient = 1 - mission.length / maxDistance;
        double missionZoom = minZoom + (maxZoom - minZoom) * distanceQuotient;
        if (missionZoom < zoom) zoom = missionZoom;
      }
      return zoom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: CameraPosition(
            target: getStartPosition(),
            zoom: getStartZoom(),
          ),
          onMapCreated: _onMapCreated,
          myLocationButtonEnabled: false,
          markers: _markers,
          polylines: lines,
          onTap: (LatLng latLng) {
            if (widget.selectedMission != null) return;
            setState(() {
              selectedMission = null;
            });
          },
        ),
        if (selectedMission != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MissionCard(info: selectedMission!),
          ),
      ],
    );
  }
}

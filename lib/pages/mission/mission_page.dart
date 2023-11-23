// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:math';

import 'package:Stray/general_widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../helper/coin_generator.dart';
import '../../helper/geo.dart';

import 'compass_widget.dart';
import '../../general_widgets/error_display_widget.dart';
import '../progress/map_page.dart';
import 'mission_length_choice_widget.dart';
import '../../database/database.dart';
import 'win_display_widget.dart';

import 'package:http/http.dart' as http;

class MissionPage extends StatelessWidget {
  const MissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mission")),
      body: const MissionWidget(),
    );
  }
}

class MissionWidget extends StatefulWidget {
  const MissionWidget({Key? key}) : super(key: key);

  @override
  _MissionWidgetState createState() => _MissionWidgetState();
}

class _MissionWidgetState extends State<MissionWidget> {
  double missionLength = 1.0;
  double winMeterTolerance = 50.0;
  bool choosingMissionLength = false;

  Timer? refreshTimer;
  Timer? calibrationReminderTimer;

  StreamSubscription<Position>? positionStream;
  StreamSubscription<CompassEvent>? compassStream;
  Position? currentPosition;

  bool hasGeneratedCoin = false;
  bool coinGenerationFailed = false;
  bool showInternetRequired = false;

  bool showingCalibrationReminder = false;
  DateTime lastCalibrationReminderTime = DateTime.now();

  String? locationErrorMessage;

  Position? coinPos;

  double compassAngle = 0.0;

  Future<void> loadSettings() async {
    await Database.load();
    if (!mounted) return;
    setState(() {});

    if (Database.activeMission != null) {
      choosingMissionLength = false;
      initialzeMission();
    } else {
      choosingMissionLength = true;
    }
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> generateCoinPos() async {
    while (currentPosition == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (coinPos == null) {
      if (Database.activeMission != null) {
        coinPos = Database.activeMission!.coinPosition;
      } else {
        try {
          coinPos = await CoinGenerator.generateCoinPos(
              currentPosition!, missionLength);
        } on http.ClientException catch (e) {
          showInternetRequired = true;
          return;
        }

        if (coinPos == null) {
          coinGenerationFailed = true;
          return;
        }

        DateTime startTime = DateTime.now();
        MissionInfo newMission = MissionInfo(
          startTime: startTime,
          endTime: startTime.add(const Duration(
              seconds: 1)), // will be replaced when mission completes
          length: CoinGenerator.distanceBetween(currentPosition!, coinPos!),
          startPosition: currentPosition!,
          coinPosition: coinPos!,
          completed: false,
        );

        Database.missions.add(newMission);
        Database.save();

        if (!mounted) return;
      }
    }

    setState(() {
      hasGeneratedCoin = true;
    });
  }

  Position getCoinPos() {
    if (currentPosition == null || !hasGeneratedCoin) {
      return CoinGenerator.positionFromLatLon(0, 0);
    }

    return coinPos!;
  }

  double getAngleToCoin() {
    if (currentPosition == null) return 0.0;
    Position coinPos = getCoinPos();
    // while this isn't technically correct,
    // it's almost correct on small scales (such as this one)
    return atan2(
      coinPos.longitude - currentPosition!.longitude,
      coinPos.latitude - currentPosition!.latitude,
    );
  }

  Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (!mounted) return false;

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        locationErrorMessage =
            "Location Access denied. Enable location access to play a mission.";
      });
      return false;
    }

    if (permission == LocationPermission.unableToDetermine) {
      setState(() {
        locationErrorMessage = "Unable to determine your GPS position.";
      });
      return false;
    }

    setState(() {
      locationErrorMessage = null;
    });
    return true;
  }

  Future<void> registerStreams() async {
    Geo.askForPermission();

    if (await checkPermission()) {
      positionStream =
          Geolocator.getPositionStream(locationSettings: Geo.locationSettings)
              .listen((Position position) {
        if (!mounted) return;
        setState(() {
          Geo.lastPosition = position;
          currentPosition = position;
        });
      })
            ..onError((exception) {
              setState(() {
                locationErrorMessage =
                    "Location Access denied. Enable location access to play a mission.";
              });
            });

      compassStream = FlutterCompass.events!.listen((CompassEvent event) {
        if (!mounted) return;
        double? angle = event.heading;
        if (angle != null) {
          setState(() {
            Geo.lastCompassAngle = angle / 180.0 * pi;
            updateCompassAngle();
          });
        }
      });
    }
  }

  void unregisterStreams() {
    positionStream?.cancel();
    compassStream?.cancel();
  }

  void updateCompassAngle() {
    double desiredAngle = getAngleToCoin() - getCompassAngle();
    double smoothRate =
        Database.getSetting("smooth_compass_motion").booleanValue
            ? (1 / 10)
            : (1 / 2);
    compassAngle +=
        Geo.angleDifference(compassAngle, desiredAngle) * smoothRate;
  }

  Future<void> initialzeMission() async {
    registerStreams();

    calibrationReminderTimer =
        Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      Duration timePassed =
          DateTime.now().difference(lastCalibrationReminderTime);
      if (timePassed.inMinutes >=
          Database.getSetting("calibration_reminder_time").integerValue) {
        setState(() {
          showingCalibrationReminder = true;
        });
      }
    });

    refreshTimer =
        Timer.periodic(const Duration(seconds: 3), (Timer timer) async {
      if (!mounted) return;

      bool permissionGiven = await checkPermission();

      if (!mounted) return;
      if (currentPosition == null) {
        if (permissionGiven) {
          unregisterStreams();
          registerStreams();
        }
      }
    });

    await generateCoinPos();
    if (mounted) {
      setState(() {
        showingCalibrationReminder = true;
      });
    }
  }

  double getCompassAngle() {
    if (Geo.lastCompassAngle == null) {
      return 1.0;
    }
    return Geo.lastCompassAngle!;
  }

  double getDistanceToCoin() {
    getCoinPos();
    if (Database.getSetting("cheat").booleanValue) {
      return 9.0;
    }
    return CoinGenerator.distanceBetween(currentPosition!, getCoinPos());
  }

  bool isShowingCompass() {
    return !choosingMissionLength &&
        !showInternetRequired &&
        (locationErrorMessage == null) &&
        (currentPosition != null) &&
        !coinGenerationFailed &&
        hasGeneratedCoin &&
        (getDistanceToCoin() >= winMeterTolerance);
  }

  @override
  Widget build(BuildContext context) {
    if (choosingMissionLength) {
      return MissionLengthChoiceWidget(
        onValueChange: (value) {
          setState(() {
            missionLength = value;
          });
        },
        missionLength: missionLength,
        onSubmit: () async {
          await showLoading(context, Duration(seconds: 1));
          Navigator.pop(context);
          setState(() {
            choosingMissionLength = false;
            initialzeMission();
          });
        },
      );
    }

    if (showInternetRequired) {
      return const ErrorDisplayWidget(
        message:
            "For Coin Generation, a running internet connection is necessary, as this uses a "
            "mapping api to find reachable points in your area. Try again with an internet connection!",
      );
    }

    if (coinGenerationFailed) {
      return const ErrorDisplayWidget(
        message:
            "I haven't found a suitable spot to place a coin near you. Maybe there are "
            "just no good spots? Try moving to a more suitable location and try again or enable 'Unsafe Coins' in the settings.",
      );
    }

    if (locationErrorMessage != null) {
      return ErrorDisplayWidget(message: locationErrorMessage!);
    }

    if (currentPosition == null) {
      return const ErrorDisplayWidget(
          message: "Trying to determine your location... "
              "Try moving to a spot with a good GPS connection (ideally with sky access). "
              "If you haven't got GPS enabled, please enable it in your phone settings!",
          showSpinner: true);
    }

    if (!hasGeneratedCoin) {
      return const ErrorDisplayWidget(
        message: "Generating Coin Position...",
        showSpinner: true,
      );
    }

    if (getDistanceToCoin() < winMeterTolerance) {
      return WinDisplayWidget(onFinish: () async {
        Navigator.pop(context);
      });
    }

    return Stack(
      children: [
        CompassWidget(
          angle: compassAngle,
          northAngle: compassAngle - getAngleToCoin(),
          distance: getDistanceToCoin(),
          onAbort: () {
            Database.missions =
                Database.missions.where((info) => info.completed).toList();
            Database.save();
            Navigator.pop(context);
          },
        ),
        if (showingCalibrationReminder)
          Center(
            child: Container(
              color: Color.fromARGB(199, 0, 0, 0),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                backgroundColor: Colors.white,
                titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily:
                      Theme.of(context).textTheme.headlineLarge!.fontFamily,
                ),
                shadowColor: Colors.black,
                buttonPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                title: const Text('Compass Calibration'),
                content: SingleChildScrollView(
                    child: ListBody(
                  children: [
                    Image.asset(
                        "assets/images/compass_calibration_tutorial.png"),
                    const SizedBox(height: 8),
                    const Text(
                      "Calibrate your compass by moving your device "
                      "in a figure 8 motion. Try to tilt the device in all directions while "
                      "rotating your device and following the motion.\n\nYou can deactivate this reminder in the settings.",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                )),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showingCalibrationReminder = false;
                        lastCalibrationReminderTime = DateTime.now();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        minimumSize:
                            const Size.fromHeight(0) // to expand to full width,
                        ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    calibrationReminderTimer?.cancel();
    unregisterStreams();

    super.dispose();
  }
}

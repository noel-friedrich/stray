import 'dart:async';

import 'package:Stray/general_widgets/info_card.dart';
import 'package:Stray/pages/progress/missions_list_page.dart';
import 'package:flutter/material.dart';

import '../../general_widgets/streak_display.dart';
import '../../helper/level_info.dart';
import 'progress_display_widget.dart';

import '../../database/database.dart';
import 'map_page.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  State createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  Timer? refreshTimer;

  Future<void> loadSettings() async {
    await Database.load();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadSettings();

    refreshTimer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) async {
      await Database.load();
      if (!mounted) return;
      setState(() {});
    });
  }

  Widget missionStatisticsCard() {
    List<MissionInfo> completedMissions =
        Database.missions.where((m) => m.completed).toList();

    int totalCompletedMissions = LevelInfo.getTotalMissions();
    double totalMissionsLength = LevelInfo.getTotalMissionsLength();
    double averageMissionLength = totalMissionsLength / totalCompletedMissions;

    String message =
        "In total, you completed $totalCompletedMissions missions, covering "
        "${totalMissionsLength.toStringAsFixed(2)} kilometers in total.";

    if (!averageMissionLength.isNaN) {
      message += " Your average "
          "mission length is ${averageMissionLength.toStringAsFixed(2)} km";
    } else {
      message +=
          " Complete your first mission to view your history and the mission map here!";
    }

    return InfoCard(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: "Mission Statistics",
      messageTextAlign: TextAlign.start,
      message: message,
      buttons: [
        if (totalCompletedMissions > 0)
          InfoCardButton("Open Mission Map", () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return MapPage(missions: completedMissions);
                },
              ),
            );
          }),
        if (totalCompletedMissions > 0)
          InfoCardButton("Open Mission History", () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const MissionsListWidget();
                },
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      children: <Widget>[
        StreakDisplay(streak: LevelInfo.calculateStreak()),
        ProgressDisplayWidget(key: UniqueKey()),
        missionStatisticsCard(),
      ],
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }
}

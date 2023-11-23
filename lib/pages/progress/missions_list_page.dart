import 'package:flutter/material.dart';

import '../../general_widgets/info_card.dart';

import 'map_page.dart';
import 'mission_card.dart';
import '../../database/database.dart';

class MissionsListWidget extends StatelessWidget {
  const MissionsListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MissionInfo> completedMissions =
        Database.missions.where((m) => m.completed).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mission History"),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          InfoCard(
            title: "Your Missions (${completedMissions.length})",
            message: "Click on a mission to view it's details and locations.",
          ),
          ...completedMissions.map((m) => MissionCard(
                info: m,
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return MapPage(missions: [m], selectedMission: m);
                      },
                    ),
                  );
                },
              ))
        ],
      ),
    );
  }
}

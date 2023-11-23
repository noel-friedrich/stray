import 'package:Stray/general_widgets/info_card.dart';
import 'package:flutter/material.dart';

import '../mission/mission_page.dart';
import '../../database/database.dart';
import '../../helper/level_info.dart';

class MissionCardWidget extends StatelessWidget {
  const MissionCardWidget({Key? key}) : super(key: key);

  String getBodyText() {
    if (LevelInfo.hasCompletedMissionToday()) {
      return 'You have already completed todays mission. Come back tomorrow '
          'to continue your Streak. Upgrade to Premium to unlock unlimited '
          'missions per day.';
    }

    return 'Embark on daily adventures in your city by chasing hidden coins. '
        'Use the compass to find virtual coins placed somewhere around you. No maps, just your senses. '
        'Ready to explore? Start a mission and find the coins!';
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
        title: "Welcome to Stray!",
        message: getBodyText(),
        buttons: [
          InfoCardButton(
              Database.getSetting("premium").booleanValue
                  ? ((Database.activeMission == null)
                      ? 'Start a Mission'
                      : 'Continue the Mission')
                  : LevelInfo.hasCompletedMissionToday()
                      ? "Upgrade to Premium"
                      : ((Database.activeMission == null)
                          ? 'Start a Mission'
                          : 'Continue the Mission'), () {
            if (Database.getSetting("premium").booleanValue ||
                !LevelInfo.hasCompletedMissionToday()) {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return MissionPage(key: UniqueKey());
                  },
                ),
              );
            } else {
              // TODO: Upgrade to premium
            }
          })
        ]);
  }
}

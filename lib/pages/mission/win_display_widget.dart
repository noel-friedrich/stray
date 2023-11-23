import 'package:Stray/helper/coin_generator.dart';
import 'package:flutter/material.dart';
import '../../general_widgets/error_display_widget.dart';

import '../progress/map_page.dart';
import '../progress/missions_map.dart';
import '../../database/database.dart';

class WinDisplayWidget extends StatelessWidget {
  const WinDisplayWidget({Key? key, required this.onFinish}) : super(key: key);

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    if (Database.activeMission == null) {
      return const ErrorDisplayWidget(
          message:
              "Something went wrong here. You shouldn't be seeing this! [E119]");
    }

    int reward = CoinGenerator.meterToReward(Database.activeMission!.length);
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      children: <Widget>[
        Card(
          color: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Text(
                      'You got it!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'You\'ve successfully found the coins. At the beginning, they were '
                  '${Database.activeMission!.length.round()}m away. Amazing! You made it! '
                  'Your reward is:',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "assets/images/coin.png",
                      fit: BoxFit.cover,
                      width: 20,
                      filterQuality: FilterQuality.medium,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      reward.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    // ignore: use_build_context_synchronously
                    await showLoading(context, const Duration(seconds: 1));
                    if (Database.activeMission != null) {
                      Database.activeMission!.endTime = DateTime.now();
                      Database.activeMission!.completed = true;
                    }
                    Database.increaseCoins(reward);
                    await Database.save();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(context);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      minimumSize:
                          const Size.fromHeight(0) // to expand to full width,
                      ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Collect Reward',
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
        SizedBox(
          height: 300,
          child: MissionsMap(
            missions: [Database.activeMission!],
          ),
        ),
      ],
    );
  }
}

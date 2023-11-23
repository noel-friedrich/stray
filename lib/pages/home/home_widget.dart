import 'dart:async';

import 'package:flutter/material.dart';

import '../../general_widgets/info_card.dart';
import '../../general_widgets/streak_display.dart';
import '../../helper/level_info.dart';
import 'mission_card_widget.dart';

import '../../database/database.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key, required this.switchTabIndex}) : super(key: key);

  final Function(int) switchTabIndex;

  @override
  State createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  Timer? refreshTimer;

  Future<void> loadSettings() async {
    await Database.load();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadSettings();

    refreshTimer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) async {
      if (!mounted) return;
      await Database.load();
      if (Database.checkIfChanged()) {
        setState(() {});
      }
      Database.prepareForChangedCheck();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      children: <Widget>[
        StreakDisplay(streak: LevelInfo.calculateStreak(), key: UniqueKey()),
        const SizedBox(height: 10),
        MissionCardWidget(key: UniqueKey()),
        InfoCard(
          message:
              "See your Streak, Statistics and History in the Progress Tab!",
          messageTextAlign: TextAlign.start,
          buttons: [
            InfoCardButton("Open Progress", () {
              widget.switchTabIndex(1);
            })
          ],
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        const SizedBox(height: 10),
        InfoCard(
          coins: Database.getSetting("coins").value,
          message: "Earn coins by completing missions. The bigger the mission, "
              "the more coins you get. Spend your coins in the shop!",
          messageTextAlign: TextAlign.start,
          buttons: [
            InfoCardButton("Open Shop", () {
              widget.switchTabIndex(2);
            })
          ],
          backgroundColor: Theme.of(context).colorScheme.surface,
        )
      ],
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }
}

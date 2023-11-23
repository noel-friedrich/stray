import 'package:flutter/material.dart';

import '../../general_widgets/info_card.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Privacy")),
      body: const _InfoWidget(),
    );
  }
}

class _InfoWidget extends StatelessWidget {
  const _InfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      children: const <Widget>[
        InfoCard(
            title: "Your Data",
            message:
                "For the app to work, it temporarily uses your live location when you're "
                "completing a mission. This is necessary as the app needs to know your position "
                "relative to your goal in order to point you there. However, this location is "
                "not saved. Instead, only your start location and coins position is saved "
                "locally on your device. When generation a coin in safe mode (when you haven't "
                "activated the 'Unsafe Coins' setting) possible coin locations are sent to Google's "
                "Maps servers in order to find a location which lies on a street (a walkable position). No other data "
                "for any other purpose is sent to any server. All data is stored locally on your device."),
        InfoCard(
          title: "Contact",
          message:
              "If you have any question regarding this app, its data management or privacy in general, "
              "feel free to contact the developer at noel.friedrich@outlook.de\nThanks!",
          messageTextAlign: TextAlign.start,
        ),
      ],
    );
  }
}

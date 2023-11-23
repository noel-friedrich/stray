import 'package:flutter/material.dart';

import 'stray_definition_widget.dart';

import '../../general_widgets/info_card.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Info")),
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
      children: <Widget>[
        InfoCard(
            title: "Welcome to Stray!",
            message:
                'Embark on daily adventures in your city by chasing hidden coins. '
                'Use the compass to find virtual coins placed somewhere around you. No maps, just your senses. '
                'Ready to explore? Start a mission and find the coins!',
            buttons: [
              InfoCardButton("Start Exploring", () {
                Navigator.pop(context);
              })
            ]),
        const SizedBox(height: 10),
        const InfoCard(
          title: "How does it work?",
          message:
              "The app let's you play missions. Each mission consists of hunting a pile of "
              "virtual coins. When starting the mission, the app chooses a place that's some "
              "distance away from you. You're allowed to choose this distance. You then need "
              "to find these coins. The catch? You can't see where they are on a map. You just "
              "get a compass. Stray around and explore your location like a scavenger hunt!",
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(
            "assets/images/stray-animation.gif",
          ),
        ),
        const SizedBox(height: 10),
        const StrayDefinitionWidget(),
      ],
    );
  }
}

import 'package:Stray/pages/mission/map_radius_widget.dart';
import 'package:Stray/pages/progress/missions_map.dart';
import 'package:flutter/material.dart';

class MissionLengthChoiceWidget extends StatefulWidget {
  const MissionLengthChoiceWidget({
    Key? key,
    required this.onValueChange,
    required this.missionLength,
    required this.onSubmit,
  }) : super(key: key);

  final double missionLength;
  final ValueSetter<double> onValueChange;
  final VoidCallback onSubmit;

  @override
  State<MissionLengthChoiceWidget> createState() =>
      _MissionLengthChoiceWidgetState();
}

class _MissionLengthChoiceWidgetState extends State<MissionLengthChoiceWidget> {
  double currMissionLength = 1;

  @override
  void initState() {
    super.initState();
    currMissionLength = widget.missionLength;
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Mission Length",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "How far away should I place the coins? The further you choose, the higher "
                  "the reward.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Estimated Reward:",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
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
                      '${(widget.missionLength * 100).round()} (${widget.missionLength.round()}km)',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    valueIndicatorColor:
                        Theme.of(context).colorScheme.background,
                    activeTrackColor: Theme.of(context).colorScheme.secondary,
                    inactiveTrackColor: Theme.of(context).colorScheme.onPrimary,
                    thumbColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Slider(
                    value: widget.missionLength,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: "${widget.missionLength.round()} km",
                    onChanged: (double value) {
                      if (value < 1) {
                        return;
                      }

                      currMissionLength = value;
                      widget.onValueChange(value);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    widget.onSubmit();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Start the Mission',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: MapRadiusWidget(
            radius: currMissionLength * 1000,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../database/database.dart';

class CompassWidget extends StatelessWidget {
  const CompassWidget({
    Key? key,
    required this.angle,
    required this.northAngle,
    required this.distance,
    required this.onAbort,
  }) : super(key: key);

  final double angle;
  final double northAngle;
  final double distance;
  final VoidCallback onAbort;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 10),
          child: Stack(
            children: [
              Transform.rotate(
                angle: angle,
                child: Image.asset(
                  Database.getCompassImagePath(),
                  fit: BoxFit.cover,
                ),
              ),
              if (Database.getSetting("show_compass_north").booleanValue)
                Transform.rotate(
                  angle: northAngle,
                  child: Image.asset(
                    "assets/images/north_compass_overlay.png",
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
        Text(
          "≈ ${distance.round()}m",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: Theme.of(context).colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Text(
                      'Find the coins!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Follow the compass/arrow to find the coins. No maps, just your senses. '
                  'This doesn\'t require an internet connection, just active GPS. Happy Exploring!',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text('Please Confirm'),
                          content: const Text(
                              'Are you sure you want to abort the Mission?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onAbort();
                                },
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.onError),
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.error),
                                ),
                                child: const Text('Yes')),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.onTertiary),
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.tertiary),
                                ),
                                child: const Text('No'))
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      minimumSize:
                          const Size.fromHeight(0) // to expand to full width,
                      ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Abort Mission',
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
}

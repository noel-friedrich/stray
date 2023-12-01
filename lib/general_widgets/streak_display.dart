import 'package:flutter/material.dart';

import '../database/database.dart';

class StreakDisplay extends StatelessWidget {
  const StreakDisplay({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.local_fire_department,
              size: 30,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              Database.getSetting("screenshot_mode").booleanValue
                  ? "9"
                  : streak.toString(),
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            Text(
              "-day Streak",
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

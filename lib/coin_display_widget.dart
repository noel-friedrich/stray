import 'package:flutter/material.dart';

class CoinDisplayWidget extends StatelessWidget {
  const CoinDisplayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
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
                  Settings.getSetting("coins").value.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Earn coins by completing missions. The bigger the mission, the '
              'more coins you get. Spend your coins in the shop!',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

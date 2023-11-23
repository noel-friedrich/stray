import 'package:flutter/material.dart';

class StrayDefinitionWidget extends StatelessWidget {
  const StrayDefinitionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const <Widget>[
            Text(
              'to stray (verb) /streɪ/',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'to move away from a place where you usually are or from a direction in which you usually go.',
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}

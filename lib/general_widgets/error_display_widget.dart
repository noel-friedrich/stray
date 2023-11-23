import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  const ErrorDisplayWidget({
    Key? key,
    required this.message,
    this.showSpinner = false,
  }) : super(key: key);

  final String message;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!showSpinner)
              const Text(
                "Oh no!",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            if (showSpinner)
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            SizedBox(height: showSpinner ? 30 : 10),
            Text(
              message,
              style: const TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

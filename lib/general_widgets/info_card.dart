import 'package:flutter/material.dart';

import '../database/database.dart';

class InfoCardButton {
  final String text;
  final VoidCallback onClick;

  InfoCardButton(this.text, this.onClick);
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    this.title,
    this.message,
    this.onClick,
    this.backgroundColor,
    this.messageTextAlign,
    this.coins,
    this.buttons = const [],
    this.paddingBetween = 8,
    this.width,
    this.height,
  }) : super(key: key);

  final String? title;
  final String? message;
  final List<InfoCardButton> buttons;
  final VoidCallback? onClick;
  final double paddingBetween;

  final Color? backgroundColor;
  final TextAlign? messageTextAlign;

  final int? width;
  final int? height;

  final int? coins;

  @override
  Widget build(BuildContext context) {
    List<Widget> buttonWidgets = [];

    for (InfoCardButton button in buttons) {
      buttonWidgets.add(SizedBox(height: paddingBetween));
      buttonWidgets.add(
        ElevatedButton(
          onPressed: () {
            button.onClick();
          },
          style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              minimumSize: const Size.fromHeight(0) // to expand to full width,
              ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              button.text,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    Widget cardContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          if (coins != null)
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
                  Database.getSetting("screenshot_mode").booleanValue
                      ? "731"
                      : coins.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (coins != null) SizedBox(height: paddingBetween),
          if (title != null)
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (title != null) SizedBox(height: paddingBetween),
          if (message != null)
            Text(
              message!,
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: messageTextAlign ?? TextAlign.justify,
            ),
          ...buttonWidgets
        ],
      ),
    );

    return Card(
      color: backgroundColor ?? Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: (onClick == null)
          ? cardContent
          : InkWell(
              onTap: () {
                if (onClick != null) {
                  onClick!();
                }
              },
              child: cardContent,
            ),
    );
  }
}

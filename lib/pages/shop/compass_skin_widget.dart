import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../database/database.dart';
import 'view_item_page.dart';
import '../../database/shop.dart';

class CompassSkinWidget extends StatefulWidget {
  const CompassSkinWidget(
      {super.key, required this.item, required this.bigView});

  final CompassSkin item;
  final bool bigView;

  @override
  State<CompassSkinWidget> createState() => _CompassSkinWidgetState();
}

class _CompassSkinWidgetState extends State<CompassSkinWidget> {
  double _turns = 0.0;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    refreshTimer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) async {
      if (!mounted) return;

      Random rng = Random();
      double increment = rng.nextDouble() * 0.4 - 0.2;

      setState(() {
        _turns += increment;
      });
    });
  }

  bool isBought() {
    return Database.boughtIdemIds.contains(widget.item.id);
  }

  bool isActive() {
    return Database.getSetting("compassSkinId").stringValue == widget.item.id;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isActive()
          ? Theme.of(context).colorScheme.tertiary
          : Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: () {
          if (widget.bigView) return;
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return ViewItemPage(item: widget.item);
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              AnimatedRotation(
                duration: const Duration(seconds: 1),
                turns: _turns,
                child: Image.asset(Shop.skinFolder + widget.item.skinFilePath),
              ),
              SizedBox(height: widget.bigView ? 16 : 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (!isBought())
                    Image.asset(
                      "assets/images/coin.png",
                      fit: BoxFit.cover,
                      width: widget.bigView ? 22 : 16,
                      filterQuality: FilterQuality.medium,
                    ),
                  if (isBought())
                    Icon(
                      Icons.check,
                      size: widget.bigView ? 30 : 20,
                      color: isBought() ? Colors.green : null,
                    ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    isBought() ? "Bought" : widget.item.price.toString(),
                    style: TextStyle(
                      fontSize: widget.bigView ? 22 : 16,
                      fontWeight: FontWeight.bold,
                      color: isBought() ? Colors.green : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: widget.bigView ? 16 : 1),
              Text(
                widget.item.name,
                style: TextStyle(
                  fontWeight:
                      widget.bigView ? FontWeight.bold : FontWeight.normal,
                  fontSize: widget.bigView ? 20 : 14,
                  color: isActive() ? Colors.black : null,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.bigView) const SizedBox(height: 10),
              if (widget.bigView)
                Text(
                  widget.item.description,
                  style: TextStyle(
                    fontWeight: widget.bigView ? null : FontWeight.bold,
                    fontSize: 16,
                    color: isActive() ? Colors.black : null,
                  ),
                  textAlign: TextAlign.justify,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }
}

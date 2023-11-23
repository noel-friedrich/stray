import 'package:flutter/material.dart';

import '../../general_widgets/info_card.dart';

import '../progress/map_page.dart';
import '../progress/mission_card.dart';
import '../../database/database.dart';
import '../../database/shop.dart';
import 'shop_widget.dart';

class ViewItemPage extends StatefulWidget {
  const ViewItemPage({Key? key, required this.item}) : super(key: key);

  final ShopItem item;

  @override
  State<ViewItemPage> createState() => _ViewItemPageState();
}

class _ViewItemPageState extends State<ViewItemPage> {
  Future<void> reload() async {
    await Database.save();
    await Database.load();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    reload();
  }

  bool isBought() {
    return Database.boughtIdemIds.contains(widget.item.id);
  }

  bool isActive() {
    return Database.getSetting("compassSkinId").stringValue == widget.item.id;
  }

  bool canBuy() {
    return Database.getSetting("coins").integerValue >= widget.item.price;
  }

  void activateItem() {
    Database.getSetting("compassSkinId").setValue(widget.item.id);
    reload();
  }

  void buyItem() {
    if (!canBuy() || isBought()) {
      return;
    }

    Database.increaseCoins(-widget.item.price);
    Database.boughtIdemIds.add(widget.item.id);
    reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop Item"),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          makeShopItemWidget(widget.item, bigView: true),
          const SizedBox(height: 10),
          if (isBought() && isActive())
            InfoCard(
              backgroundColor: Theme.of(context).colorScheme.surface,
              message:
                  "You've activated this compass skin. Activate another Skin to deactivate this one. This is the "
                  "compass that will get used when you start a mission now!",
            ),
          if (isBought() && !isActive())
            InfoCard(
              backgroundColor: Theme.of(context).colorScheme.surface,
              message:
                  "You own this skin. Click the button below to deactivate your current Skin and deactivate "
                  "this skin.",
              buttons: [
                InfoCardButton("Activate", activateItem),
              ],
            ),
          if (!isBought() && canBuy())
            InfoCard(
              backgroundColor: Theme.of(context).colorScheme.surface,
              paddingBetween: 0,
              buttons: [
                InfoCardButton("Buy for ${widget.item.price} coins", buyItem),
              ],
            ),
          if (!isBought() && !canBuy())
            InfoCard(
              backgroundColor: Theme.of(context).colorScheme.surface,
              message:
                  "You currently don't have enough coins to buy this skin. You're "
                  "missing ${widget.item.price - Database.getSetting('coins').integerValue} coins. "
                  "Complete missions to gain the necessary coins and come back later!",
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

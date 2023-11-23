import 'dart:async';
import 'dart:math';

import 'package:Stray/constants/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../general_widgets/info_card.dart';
import '../../database/database.dart';
import '../../database/shop.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'compass_skin_widget.dart';
import 'paywall_widget.dart';

Widget makeShopItemWidget(
  ShopItem item, {
  bool bigView = false,
}) {
  if (item is CompassSkin) {
    return CompassSkinWidget(item: item, bigView: bigView);
  } else {
    return const Text("[E205] NOT IMPLEMENTED ERROR");
  }
}

class ShopWidget extends StatefulWidget {
  const ShopWidget({Key? key}) : super(key: key);

  @override
  State createState() => ShopWidgetState();
}

class ShopWidgetState extends State<ShopWidget> {
  Timer? refreshTimer;

  Future<void> loadSettings() async {
    await Database.load();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadSettings();

    refreshTimer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) async {
      if (!mounted) return;
      await Database.load();
      setState(() {});
    });
  }

  List<Widget> makeShopItemWidgets() {
    List<Widget> out = [];
    for (ShopItem item in Shop.items) {
      out.add(makeShopItemWidget(item));
    }
    return out;
  }

  Future<void> displayPaywall() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.entitlements.all[RevenueCatConstants.entitlementId] !=
            null &&
        customerInfo.entitlements.all[RevenueCatConstants.entitlementId]!
                .isActive ==
            true) {
      Database.getSetting("premium").setValue(true);
      await Database.save();
      if (mounted) {
        setState(() {});
      }
    } else {
      Offerings offerings;
      try {
        offerings = await Purchases.getOfferings();

        if (offerings == null || offerings.current == null) {
          // offerings are empty, show a message to your user
        } else {
          // current offering is available, show paywall
          // ignore: use_build_context_synchronously
          await showModalBottomSheet(
            useRootNavigator: true,
            isDismissible: true,
            isScrollControlled: true,
            backgroundColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                return PaywallWidget(
                  offering: offerings.current!,
                );
              });
            },
          );
        }
      } on PlatformException catch (e) {
        // Error finding the offerings, handle the error.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      children: <Widget>[
        const InfoCard(
          title: "Welcome to the Shop!",
          message:
              "This is the place to spend all your hard-earned coins. Click "
              "on items that interest you. Happy shopping!",
        ),
        if (!Database.getSetting("premium").booleanValue)
          InfoCard(
            title: "Buy Premium",
            message:
                "Upgrade to Premium today to unlock unlimited missions per day "
                "and to help this App's developer out. Premium is NOT necessary to use the App daily!",
            buttons: [
              InfoCardButton("Buy Premium", () {
                displayPaywall();
              })
            ],
          ),
        if (Database.getSetting("premium").booleanValue)
          const InfoCard(
            title: "Premium",
            message:
                "You have an active Premium subscription. Thank you for supporting this app!",
          ),
        InfoCard(
          coins: Database.getSetting("coins").value,
          message: "This is your budget. Complete missions to gain more coins.",
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: StaggeredGrid.count(
            crossAxisCount: 2,
            children: makeShopItemWidgets(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }
}

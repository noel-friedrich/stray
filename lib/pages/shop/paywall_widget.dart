// from https://www.revenuecat.com/blog/engineering/flutter-subscriptions-tutorial/

import 'dart:ffi';

import 'package:Stray/constants/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../database/database.dart';

class PaywallWidget extends StatefulWidget {
  final Offering offering;

  const PaywallWidget({Key? key, required this.offering}) : super(key: key);

  @override
  _PaywallWidgetState createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends State<PaywallWidget> {
  Future<void> exitWithError(String message) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(
              "So Sorry! An error occured. Please report this to the developer!"
              "\n\n$message"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Understood",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> buy(int index) async {
    List<Package> myProductList = widget.offering.availablePackages;

    try {
      CustomerInfo customerInfo =
          await Purchases.purchasePackage(myProductList[index]);
      Database.getSetting("premium").setValue(customerInfo
          .entitlements.all[RevenueCatConstants.entitlementId]!.isActive);
    } catch (e) {
      exitWithError(e.toString());
    }

    if (mounted) {
      setState(() {});
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Package> myProductList = widget.offering.availablePackages;
    return SingleChildScrollView(
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Text(
                "Stray Premium",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                itemCount: myProductList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      minVerticalPadding: 0,
                      contentPadding: const EdgeInsets.all(20.0),
                      tileColor: Theme.of(context).colorScheme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      title: Text(
                        myProductList[index].storeProduct.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        myProductList[index].storeProduct.description,
                      ),
                      trailing: Text(
                        myProductList[index].storeProduct.priceString,
                      ),
                      onTap: () => buy(index),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(RevenueCatConstants.footerText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

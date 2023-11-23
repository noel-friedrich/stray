import 'dart:io';

import 'package:Stray/constants/api_keys.dart';
import 'package:Stray/pages/progress/profile_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'pages/home/home_widget.dart';
import 'pages/shop/shop_widget.dart';
import 'pages/settings/settings_page.dart';
import 'database/database.dart';
import 'pages/help/help_page.dart';
import 'helper/store_config.dart';

import 'package:purchases_flutter/purchases_flutter.dart' as RevCat;

void main() {
  if (Platform.isIOS) {
    StoreConfig(
      store: Store.appleStore,
      apiKey: RevenueCatConstants.appleApiKey,
    );
  } else if (Platform.isAndroid) {
    StoreConfig(
      store: Store.googlePlay,
      apiKey: RevenueCatConstants.googleApiKey,
    );
  }

  runApp(MyApp());
}

MaterialColor colorToMaterialColor(Color color) {
  final int red = color.red;
  final int green = color.green;
  final int blue = color.blue;

  final Map<int, Color> shades = {
    50: Color.fromRGBO(red, green, blue, .1),
    100: Color.fromRGBO(red, green, blue, .2),
    200: Color.fromRGBO(red, green, blue, .3),
    300: Color.fromRGBO(red, green, blue, .4),
    400: Color.fromRGBO(red, green, blue, .5),
    500: Color.fromRGBO(red, green, blue, .6),
    600: Color.fromRGBO(red, green, blue, .7),
    700: Color.fromRGBO(red, green, blue, .8),
    800: Color.fromRGBO(red, green, blue, .9),
    900: Color.fromRGBO(red, green, blue, 1),
  };

  return MaterialColor(color.value, shades);
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.dark);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Stray',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch:
                colorToMaterialColor(const Color.fromARGB(255, 255, 255, 255)),
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 255, 255, 255),
              secondary: Color.fromARGB(255, 255, 244, 103),
              secondaryContainer: Color.fromARGB(255, 198, 188, 47),
              tertiary: Color.fromARGB(255, 110, 255, 103),
              tertiaryContainer: Color.fromARGB(255, 26, 160, 19),
              background: Color.fromARGB(255, 255, 255, 255),
              onPrimary: Color.fromARGB(255, 0, 0, 0),
              onSecondary: Color.fromARGB(255, 0, 0, 0),
              onBackground:
                  Color.fromARGB(255, 236, 236, 236), // grey equivalent
              surface: Color.fromARGB(255, 255, 255, 255), // card color
              surfaceVariant: Color.fromARGB(
                  255, 0, 0, 0), // navigation bar selection color
            ),
            scaffoldBackgroundColor: const Color.fromARGB(255, 221, 221, 221),
            fontFamily: 'Lora',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch:
                colorToMaterialColor(const Color.fromARGB(255, 0, 0, 0)),
            colorScheme: const ColorScheme.dark(
              primary: Color.fromARGB(255, 0, 0, 0),
              secondary: Color.fromARGB(255, 255, 244, 103),
              secondaryContainer: Color.fromARGB(255, 198, 188, 47),
              tertiary: Color.fromARGB(255, 110, 255, 103),
              tertiaryContainer: Color.fromARGB(255, 26, 160, 19),
              background: Color.fromARGB(255, 0, 0, 0),
              onPrimary: Color.fromARGB(255, 255, 255, 255),
              onSecondary: Color.fromARGB(255, 0, 0, 0),
              onBackground: Color.fromARGB(255, 23, 23, 23), // grey equivalent
              surface: Color.fromARGB(255, 33, 33, 33), // card color
              surfaceVariant: Color.fromARGB(
                  255, 255, 244, 103), // navigation bar selection color
            ),
            scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
            fontFamily: 'Lora',
          ),
          themeMode: mode,
          home: MainPage(title: 'Stray', themeNotifier: _themeNotifier),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title, required this.themeNotifier});

  final String title;
  final ValueNotifier<ThemeMode> themeNotifier;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<void> showError(String message) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text("So Sorry! An error occured."
              "\n\n$message"),
          actions: [
            ElevatedButton(
              onPressed: () {
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

  Future<void> initRevenueCat() async {
    RevCat.Purchases.setLogLevel(
        kDebugMode ? RevCat.LogLevel.debug : RevCat.LogLevel.info);
    RevCat.Purchases.configure(
        RevCat.PurchasesConfiguration(StoreConfig.instance.apiKey));

    try {
      RevCat.CustomerInfo customerInfo =
          await RevCat.Purchases.getCustomerInfo();

      RevCat.EntitlementInfo? entitlement =
          customerInfo.entitlements.all[RevenueCatConstants.entitlementId];
      if (kDebugMode) {
        print("REVCAT customerinfo: $customerInfo");
        print("REVCAT entitlement: $entitlement");
      }
      Database.getSetting("premium").setValue(entitlement?.isActive ?? false);
      await Database.save();
    } catch (e) {
      showError(e.toString());
    }

    RevCat.Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      RevCat.CustomerInfo customerInfo =
          await RevCat.Purchases.getCustomerInfo();
      RevCat.EntitlementInfo? entitlement =
          customerInfo.entitlements.all[RevenueCatConstants.entitlementId];

      Database.getSetting("premium").setValue(entitlement?.isActive ?? false);
      await Database.save();

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Database.load().then((_) {
      widget.themeNotifier.value = Database.getSetting("lightmode").booleanValue
          ? ThemeMode.light
          : ThemeMode.dark;
    });
    initRevenueCat();
  }

  int _selectedIndex = 0;

  Widget getBody() {
    switch (_selectedIndex) {
      case 0:
        return HomeWidget(
          key: UniqueKey(),
          switchTabIndex: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        );
      case 1:
        return ProfileWidget(key: UniqueKey());
      case 2:
        return ShopWidget(key: UniqueKey());
      default:
        return const Text(
            'Something went wrong! It would be great if you could report this to the developers.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        title: Row(
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              width: 30,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
            const SizedBox(width: 10),
            Text(widget.title),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return const HelpPage();
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return SettingsPage(themeNotifier: widget.themeNotifier);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: getBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shop',
          ),
        ],
        currentIndex: _selectedIndex,
        // selectedItemColor: ,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        selectedItemColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
    );
  }
}

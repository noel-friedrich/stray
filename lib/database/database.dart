import 'package:Stray/pages/settings/privacy_page.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:geolocator/geolocator.dart';
import '../helper/coin_generator.dart';
import 'dart:convert';

import 'shop.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLng latLngFromPosition(Position pos) {
  return LatLng(pos.latitude, pos.longitude);
}

Position positionFromLatLng(LatLng latLng) {
  return CoinGenerator.positionFromLatLon(latLng.latitude, latLng.longitude);
}

class MissionInfo {
  MissionInfo({
    required this.startTime,
    required this.endTime,
    required this.length,
    required this.startPosition,
    required this.coinPosition,
    required this.completed,
    this.isCheatDay = false,
  });

  DateTime startTime;
  DateTime? endTime;
  double length;
  Position startPosition;
  Position coinPosition;
  bool completed;
  bool isCheatDay;

  Duration? duration() {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  LatLng get middleLatLng {
    return LatLng((startPosition.latitude + coinPosition.latitude) / 2,
        (startPosition.longitude + coinPosition.longitude) / 2);
  }

  factory MissionInfo.fromJson(Map<String, dynamic> jsonData) {
    return MissionInfo(
      startTime: DateTime.fromMillisecondsSinceEpoch(jsonData["startTime"]),
      endTime: jsonData.containsKey("endTime")
          ? DateTime.fromMillisecondsSinceEpoch(jsonData["endTime"])
          : null,
      length: jsonData["length"],
      startPosition:
          CoinGenerator.positionFromString(jsonData["startPosition"]),
      coinPosition: CoinGenerator.positionFromString(jsonData["coinPosition"]),
      completed: jsonData["completed"],
      isCheatDay: jsonData["isCheatDay"] ?? false,
    );
  }

  int getIndex() {
    int i = 0;
    for (MissionInfo mission in Database.missions) {
      if (mission == this) {
        return i;
      }
      i++;
    }
    return -1;
  }

  @override
  String toString() {
    return ("MissionInfo{startTime: $startTime, endTime: $endTime, length: $length, startPosition: "
        "$startPosition, coinPosition: $coinPosition, completed: $completed, isCheatDay: $isCheatDay}");
  }

  static Map<String, dynamic> toMap(MissionInfo info) => {
        "startTime": info.startTime.millisecondsSinceEpoch,
        "endTime": info.endTime?.millisecondsSinceEpoch,
        "length": info.length,
        "startPosition": CoinGenerator.positionToString(info.startPosition),
        "coinPosition": CoinGenerator.positionToString(info.coinPosition),
        "completed": info.completed,
        "isCheatDay": info.isCheatDay,
      };

  static String encode(List<MissionInfo> infos) => json.encode(infos
      .map<Map<String, dynamic>>((info) => MissionInfo.toMap(info))
      .toList());

  static List<MissionInfo> decode(String infosString) =>
      (json.decode(infosString) as List<dynamic>)
          .map<MissionInfo>((info) => MissionInfo.fromJson(info))
          .toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionInfo &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();

  @override
  int get hashCode =>
      startPosition.hashCode ^ coinPosition.hashCode ^ startTime.hashCode;
}

enum SettingType {
  integer,
  boolean,
  button,
  float,
  string,
}

class Setting {
  Setting({
    required this.key,
    required this.defaultValue,
    required this.type,
    this.sectionTitle = "",
    this.title = "",
    this.description = "",
    this.icon = Icons.settings,
    this.options = const <dynamic>[],
    this.visible = true,
    this.onPressed,
  }) : value = defaultValue;

  final String key;
  final dynamic defaultValue;
  dynamic value;
  final SettingType type;
  final String title;
  final String sectionTitle;
  final String description;
  final IconData icon;
  List<dynamic> options = <dynamic>[];
  final Function? onPressed;
  final bool visible;

  Future<void> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (type) {
      case SettingType.string:
        prefs.setString(key, value);
        break;
      case SettingType.boolean:
        prefs.setBool(key, value);
        break;
      case SettingType.integer:
        prefs.setInt(key, value);
        break;
      case SettingType.float:
        prefs.setDouble(key, value);
        break;
      case SettingType.button:
        break;
    }
  }

  @override
  String toString() {
    return 'Setting{key: $key, defaultValue: $defaultValue, value: $value, type: $type, title: $title, description: $description}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Setting &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          defaultValue == other.defaultValue &&
          value == other.value &&
          type == other.type &&
          title == other.title &&
          description == other.description;

  @override
  int get hashCode =>
      key.hashCode ^
      defaultValue.hashCode ^
      value.hashCode ^
      type.hashCode ^
      title.hashCode ^
      description.hashCode;

  void setValue(dynamic value) {
    this.value = value;
  }

  bool get booleanValue {
    return value as bool;
  }

  int get integerValue {
    return value as int;
  }

  double get doubleValue {
    return value as double;
  }

  String get stringValue {
    return value as String;
  }

  void nextOption() {
    int index = options.indexOf(value);
    if (index == -1) {
      return;
    }

    if (index == options.length - 1) {
      index = 0;
    } else {
      index++;
    }
    value = options[index];
  }

  String getDescription() {
    return description.replaceAll("<value>", value.toString());
  }
}

class Database {
  static final List<Setting> _settings = <Setting>[
    Setting(
      key: "lightmode",
      defaultValue: false,
      type: SettingType.boolean,
      title: "Lightmode",
      sectionTitle: "General",
      description: "Change the app's theme to Light.",
      icon: Icons.light_mode,
    ),

    Setting(
      key: "unsafe_coins",
      defaultValue: false,
      type: SettingType.boolean,
      title: "Unsafe Coins",
      sectionTitle: "Coin Generation",
      description:
          "Don't necessarily place coins in locations that lie on streets, instead allow everywhere.",
      icon: Icons.no_encryption,
    ),

    Setting(
      key: "show_compass_north",
      defaultValue: false,
      type: SettingType.boolean,
      title: "Show North",
      sectionTitle: "Compass",
      description: "Display the north in the compass view.",
      icon: Icons.north,
    ),

    Setting(
      key: "smooth_compass_motion",
      defaultValue: false,
      type: SettingType.boolean,
      title: "Smoother Compass",
      sectionTitle: "Compass",
      description:
          "Smoothen out the direction change in the compass. This will make the compass react a bit slower.",
      icon: Icons.waves,
    ),

    Setting(
      key: "calibration_reminder_time",
      defaultValue: 5,
      type: SettingType.integer,
      title: "Calibration Interval",
      sectionTitle: "Compass",
      description:
          "Remind you once every <value> minute(s) to recalibrate your compass.",
      icon: Icons.circle_notifications_outlined,
      options: [1, 2, 3, 5, 10, 30],
    ),

    Setting(
      key: "cheat",
      defaultValue: false,
      type: SettingType.boolean,
      title: "Cheat Mode",
      sectionTitle: "Developer",
      description: "Instantly teleport to the coins.",
      visible: kDebugMode,
      icon: Icons.computer,
    ),

    Setting(
      key: "premium",
      defaultValue: false,
      type: SettingType.boolean,
      title: "Premium Mode",
      sectionTitle: "Developer",
      description: "Activate Premium Mode.",
      visible: kDebugMode,
      icon: Icons.computer,
    ),

    Setting(
      key: "screenshot_mode",
      defaultValue: false,
      type: SettingType.boolean,
      title: "Screenshot Mode",
      sectionTitle: "Developer",
      description: "Activate Screenshot Mode.",
      visible: kDebugMode,
      icon: Icons.computer,
    ),

    Setting(
      key: "reset",
      defaultValue: null,
      type: SettingType.button,
      title: "Reset Settings",
      sectionTitle: "Miscellaneous",
      description: "Restore the default Settings.",
      icon: Icons.restore_rounded,
      onPressed: (BuildContext context) {
        reset();
      },
    ),

    Setting(
      key: "open_privacy",
      defaultValue: null,
      type: SettingType.button,
      title: "Data Privacy",
      sectionTitle: "Miscellaneous",
      description:
          "Open the privacy page telling you how your data is managed.",
      icon: Icons.privacy_tip_outlined,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return const PrivacyPage();
            },
          ),
        );
      },
    ),

    Setting(
      key: "restore_purchases",
      defaultValue: null,
      type: SettingType.button,
      title: "Restore Purchases",
      sectionTitle: "Miscellaneous",
      description: "Restore your previous real-money purchases.",
      icon: Icons.privacy_tip_outlined,
      onPressed: (BuildContext context) async {
        await Purchases.restorePurchases();
      },
    ),

    Setting(
      key: "fullreset",
      defaultValue: null,
      type: SettingType.button,
      title: "Reset all data",
      sectionTitle: "Developer",
      description:
          "Reset all data that is stored. This includes scores, levels and shop-items.",
      icon: Icons.delete_forever_outlined,
      visible: kDebugMode,
      onPressed: () {
        fullReset();
      },
    ),

    // invisible settings

    Setting(
        key: "coins",
        defaultValue: 0,
        type: SettingType.integer,
        visible: false),

    Setting(
        key: "levelPoints",
        defaultValue: 0,
        type: SettingType.integer,
        visible: false),

    Setting(
        key: "compassSkinId",
        defaultValue: "default",
        type: SettingType.string,
        visible: false),
  ];

  static List<Setting> get settings => _settings;
  static List<MissionInfo> missions = [];
  static List<String> boughtIdemIds = [];

  static void increaseCoins(int inc) {
    int coinValue = getSetting("coins").integerValue;
    getSetting("coins").setValue(coinValue + inc);
    int levelPointsValue = getSetting("levelPoints").integerValue;
    getSetting("levelPoints").setValue(levelPointsValue + inc);
  }

  static Future<void> loadMissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String missionsString = prefs.getString("missionsString") ?? "[]";
    missions = MissionInfo.decode(missionsString);
  }

  static Future<void> loadBoughtItemIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString("boughtItemIdsString") ?? "[]";
    List<dynamic> jsonData = jsonDecode(jsonString);
    boughtIdemIds = jsonData.map((e) => (e as String)).toList();
    boughtIdemIds.add("default");
  }

  static String getCompassImagePath() {
    String id = getSetting("compassSkinId").stringValue;

    ShopItem? foundItem;
    for (ShopItem item in Shop.items) {
      if (item.id == id) {
        foundItem = item;
      }
    }

    if (foundItem == null) {
      return "${Shop.skinFolder}default_compass.png";
    }

    return "${Shop.skinFolder}${(foundItem as CompassSkin).skinFilePath}";
  }

  static saveMissions(List<MissionInfo> missions) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("missionsString", MissionInfo.encode(missions));
  }

  static saveBoughtItemIds(List<String> ids) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("boughtItemIdsString", jsonEncode(ids));
  }

  static MissionInfo? get activeMission {
    for (final info in missions) {
      if (!info.completed) return info;
    }
    return null;
  }

  static Setting getSetting(String key) {
    return _settings.firstWhere((element) => element.key == key);
  }

  static List<String> getSectionTitles() {
    List<String> sectionTitles = <String>[];
    for (Setting setting in _settings) {
      if (!sectionTitles.contains(setting.sectionTitle)) {
        sectionTitles.add(setting.sectionTitle);
      }
    }
    return sectionTitles;
  }

  static List<Setting> getSettingsForSection(String sectionTitle) {
    return _settings
        .where((element) => element.sectionTitle == sectionTitle)
        .where((element) => element.visible)
        .toList();
  }

  static Future<void> load() async {
    // using SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (Setting setting in _settings) {
      switch (setting.type) {
        case SettingType.string:
          setting
              .setValue(prefs.getString(setting.key) ?? setting.defaultValue);
          break;
        case SettingType.boolean:
          setting.setValue(prefs.getBool(setting.key) ?? setting.defaultValue);
          break;
        case SettingType.integer:
          setting.setValue(prefs.getInt(setting.key) ?? setting.defaultValue);
          break;
        case SettingType.float:
          setting
              .setValue(prefs.getDouble(setting.key) ?? setting.defaultValue);
          break;
        case SettingType.button:
          break;
      }
    }
    await loadMissions();
    await loadBoughtItemIds();
  }

  static Future<void> save() async {
    for (Setting setting in _settings) {
      await setting.save();
    }
    await saveMissions(missions);
    await saveBoughtItemIds(boughtIdemIds);
  }

  static void reset() {
    for (Setting setting in _settings) {
      if (!setting.visible) continue;
      setting.setValue(setting.defaultValue);
      setting.save();
    }
  }

  static Future<void> fullReset() async {
    for (Setting setting in _settings) {
      setting.setValue(setting.defaultValue);
      await setting.save();
    }
    missions = [];
    await saveMissions(missions);

    boughtIdemIds = [];
    await saveBoughtItemIds(boughtIdemIds);
  }

  static String lastHash = "";

  static String makeHash() {
    String hash = "";
    for (Setting setting in _settings) {
      hash += "${setting.value}#";
    }
    hash += "${missions.length}#";
    hash += "${boughtIdemIds.length}#";
    return hash;
  }

  static void prepareForChangedCheck() {
    lastHash = makeHash();
  }

  static bool checkIfChanged() {
    String newHash = makeHash();
    bool result = newHash != lastHash;
    lastHash = newHash;
    return result;
  }
}

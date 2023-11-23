import 'dart:async';

import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';

import '../../database/database.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key, required this.themeNotifier}) : super(key: key);

  final ValueNotifier<ThemeMode> themeNotifier;

  @override
  Widget build(BuildContext context) {
    List<String> sections = Database.getSectionTitles();
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SettingsWidget(sections: sections, themeNotifier: themeNotifier),
    );
  }
}

class SettingsWidget extends StatefulWidget {
  final List<String> sections;
  final ScrollPhysics physics;
  final ValueNotifier<ThemeMode> themeNotifier;

  const SettingsWidget({
    Key? key,
    required this.sections,
    this.physics = const BouncingScrollPhysics(),
    required this.themeNotifier,
  }) : super(key: key);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  List<SettingsSection> sections = <SettingsSection>[];

  SettingsTile tileFromSetting(BuildContext context, Setting setting) {
    switch (setting.type) {
      case SettingType.boolean:
        return SettingsTile.switchTile(
          onToggle: (value) {
            setting.setValue(value);
            setting.save().then((value) => initAsync());
          },
          initialValue: setting.booleanValue,
          leading: Icon(setting.icon),
          title: Text(setting.title),
          description: Text(setting.getDescription()),
          activeSwitchColor: Theme.of(context).colorScheme.surfaceVariant,
        );
      case SettingType.integer:
        return SettingsTile(
          onPressed: (context) {
            setting.nextOption();
            setting.save().then((value) => initAsync());
          },
          leading: Icon(setting.icon),
          title: Text(setting.title),
          description: Text(setting.getDescription()),
          trailing: Text(
            setting.integerValue.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.surfaceVariant,
              fontSize: 20,
            ),
          ),
        );
      case SettingType.float:
        return SettingsTile(
          onPressed: (context) {
            setting.nextOption();
            setting.save().then((value) => initAsync());
          },
          leading: Icon(setting.icon),
          title: Text(setting.title),
          description: Text(setting.getDescription()),
          trailing: Text(
            setting.doubleValue.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.surfaceVariant,
              fontSize: 20,
            ),
          ),
        );
      case SettingType.string:
        return SettingsTile(
          onPressed: (context) {
            setting.nextOption();
            setting.save().then((value) => initAsync());
          },
          leading: Icon(setting.icon),
          title: Text(setting.title),
          description: Text(setting.getDescription()),
          trailing: Text(
            setting.stringValue,
            style: TextStyle(
              color: Theme.of(context).colorScheme.surfaceVariant,
              fontSize: 20,
            ),
          ),
        );
      case SettingType.button:
        return SettingsTile(
          onPressed: (context) {
            if (setting.onPressed != null) {
              setting.onPressed!(context);
            }
            Database.save().then((value) => initAsync());
          },
          leading: Icon(setting.icon),
          title: Text(setting.title),
          description: Text(setting.description),
        );
    }
  }

  Future<void> initAsync() async {
    sections.clear();
    await Database.load();
    widget.themeNotifier.value = Database.getSetting("lightmode").booleanValue
        ? ThemeMode.light
        : ThemeMode.dark;
    List<String> sectionTitles = Database.getSectionTitles();
    for (String sectionTitle in sectionTitles) {
      if (!widget.sections.contains(sectionTitle)) {
        continue;
      }

      List<Setting> settings = Database.getSettingsForSection(sectionTitle);
      if (settings.isEmpty) {
        // true when all settings in section are invisible
        continue;
      }

      List<SettingsTile> tiles =
          settings.map((setting) => tileFromSetting(context, setting)).toList();
      sections.add(SettingsSection(
          title: Text(
            sectionTitle,
            style: TextStyle(
              // ignore: use_build_context_synchronously
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
          tiles: tiles));
    }
    if (mounted) {
      setState(() {});
    }
  }

  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    initAsync();

    refreshTimer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) async {
      if (!mounted) return;
      initAsync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      shrinkWrap: true,
      physics: widget.physics,
      sections: sections,
      lightTheme: const SettingsThemeData(
        settingsListBackground: Colors.white,
      ),
      darkTheme: const SettingsThemeData(
        settingsListBackground: Colors.black,
      ),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }
}

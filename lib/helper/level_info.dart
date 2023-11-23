import 'package:flutter/foundation.dart';

import '../database/database.dart';
import 'coin_generator.dart';

class LevelInfo {
  static int levelPointsPerLevel = 300;

  static int getPointsOfDay(DateTime day) {
    int total = 0;
    for (final mission in Database.missions) {
      if (mission.completed && isSameDate(mission.endTime!, day)) {
        total += CoinGenerator.meterToReward(mission.length);
      }
    }
    return total;
  }

  static List<String> getLastDayDescriptors(int lastDays) {
    List<String> descriptors = [];
    DateTime currDay = DateTime.now();
    for (int i = 0; i < lastDays; i++) {
      switch (currDay.weekday) {
        case DateTime.monday:
          descriptors.add("M");
          break;
        case DateTime.tuesday:
          descriptors.add("T");
          break;
        case DateTime.wednesday:
          descriptors.add("W");
          break;
        case DateTime.thursday:
          descriptors.add("T");
          break;
        case DateTime.friday:
          descriptors.add("F");
          break;
        case DateTime.saturday:
          descriptors.add("S");
          break;
        case DateTime.sunday:
          descriptors.add("S");
          break;
        default:
          descriptors.add("?");
      }
      currDay = currDay.subtract(const Duration(days: 1));
    }
    return descriptors.reversed.toList();
  }

  static List<int> getPointsOfLastDays(int lastDays) {
    if (Database.getSetting("screenshot_mode").booleanValue) {
      return [108, 291, 187, 450, 183, 241, 329];
    }

    List<int> points = [];
    DateTime currDay = DateTime.now();
    for (int i = 0; i < lastDays; i++) {
      int value = getPointsOfDay(currDay);
      points.add(value > 0 ? value : 1);
      currDay = currDay.subtract(const Duration(days: 1));
    }
    return points.reversed.toList();
  }

  static double getLevelProgress() {
    if (Database.getSetting("screenshot_mode").booleanValue) {
      return 0.35;
    }

    return (Database.getSetting("levelPoints").integerValue %
            levelPointsPerLevel) /
        (levelPointsPerLevel - 1);
  }

  static int getLevel() {
    if (Database.getSetting("screenshot_mode").booleanValue) {
      return 7;
    }

    return (Database.getSetting("levelPoints").integerValue /
                levelPointsPerLevel)
            .floor() +
        1;
  }

  static int getCoinsToNextLevel() {
    if (Database.getSetting("screenshot_mode").booleanValue) {
      return 109;
    }

    return levelPointsPerLevel -
        (Database.getSetting("levelPoints").integerValue % levelPointsPerLevel);
  }

  static int getTotalMissions() {
    if (Database.getSetting("screenshot_mode").booleanValue) {
      return 39;
    }

    List<MissionInfo> completedMissions =
        Database.missions.where((m) => m.completed).toList();
    return completedMissions.length;
  }

  static double getTotalMissionsLength() {
    if (Database.getSetting("screenshot_mode").booleanValue) {
      return getTotalMissions() * 1.70717;
    }

    List<MissionInfo> completedMissions =
        Database.missions.where((m) => m.completed).toList();
    return completedMissions.fold(0.0, (v, m) => m.length + v) / 1000;
  }

  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool dayIsCovered(DateTime day) {
    return getPointsOfDay(day) > 0;
  }

  static bool hasCompletedMissionToday() {
    return dayIsCovered(DateTime.now());
  }

  static int calculateStreak() {
    if (Database.getSetting("screenshot_mode").booleanValue) {
      return 9;
    }

    int streakCount = 0;
    DateTime currDay = DateTime.now().subtract(const Duration(days: 1));
    while (dayIsCovered(currDay)) {
      streakCount++;
      currDay = currDay.subtract(const Duration(days: 1));
    }

    if (hasCompletedMissionToday()) {
      streakCount++;
    }

    return streakCount;
  }
}

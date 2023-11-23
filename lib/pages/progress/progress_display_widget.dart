import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../helper/level_info.dart';

class ProgressDisplayWidget extends StatelessWidget {
  const ProgressDisplayWidget({Key? key}) : super(key: key);

  String getCompleteStreakInfoMessage() {
    String message = streakInfoMessage();
    if (LevelInfo.calculateStreak() == 0) {
      return message;
    } else if (LevelInfo.hasCompletedMissionToday()) {
      return "$message Come back tomorrow to continue your streak.";
    } else {
      return "$message Complete todays mission to keep this going.";
    }
  }

  String streakInfoMessage() {
    int streak = LevelInfo.calculateStreak();
    if (streak == 0) {
      return "Complete todays mission to start a streak!";
    } else if (streak == 1) {
      return "Your streak: 1 day! You're getting somewhere!";
    } else if (streak == 2) {
      return "Your streak: 2 days! You're slowly getting somewhere!";
    } else if (streak == 3) {
      return "Your streak: 3 days! You're on track to become a champion!";
    } else if (streak == 4) {
      return "Your streak: 4 days! 4 is an awesome number! You should be proud!";
    } else if (streak == 5) {
      return "Your streak: 5 days! Congrats! Keep up the good work!";
    } else if (streak == 6) {
      return "Your streak: 6 days! Only one more to go and you've got a week!";
    } else if (streak == 7) {
      return "Your streak: 7 days! That's an entire week! You should be proud.";
    } else if (streak < 30) {
      return "Your streak: $streak days! Next Milestone: 30 days.";
    } else if (streak == 30) {
      return "A whole month! You've completed a 30-day streak! You're making it a habit!";
    } else {
      int remainder = streak % 3;
      if (remainder == 0) {
        return "Your streak: $streak days! Keep going! You're clearly a master.";
      } else if (remainder == 1) {
        return "Your streak: $streak days! You're truly dedicated and unstoppable! Keep going!";
      } else {
        return "Your streak: $streak days! You're a champion!";
      }
    }
  }

  String dayLetterFromValue(double value) {
    List<String> descriptors = LevelInfo.getLastDayDescriptors(7);
    int i = max(0, min(descriptors.length, value.round()));
    return descriptors[i];
  }

  List<BarChartGroupData> makeBarGroups(BuildContext context) {
    List<int> pointsPerDay = LevelInfo.getPointsOfLastDays(7);

    List<BarChartGroupData> data = [];
    for (int i = 0; i < pointsPerDay.length; i++) {
      data.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: pointsPerDay[i].toDouble(),
          width: 20,
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          color: Theme.of(context).colorScheme.secondary,
        ),
      ]));
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    int maxPoints = LevelInfo.getPointsOfLastDays(7).reduce(max);

    return Card(
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Level ${LevelInfo.getLevel()}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "(${LevelInfo.levelPointsPerLevel - LevelInfo.getCoinsToNextLevel()}/${LevelInfo.levelPointsPerLevel})",
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: 0.1 + LevelInfo.getLevelProgress() * 0.9,
              minHeight: 15,
              backgroundColor: Theme.of(context).colorScheme.onBackground,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              getCompleteStreakInfoMessage(),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 2,
              child: BarChart(
                BarChartData(
                  maxY: maxPoints > 100.0 ? maxPoints.toDouble() : 100.0,

                  borderData: FlBorderData(
                    border: const Border(
                      top: BorderSide.none,
                      right: BorderSide.none,
                      bottom: BorderSide(width: 1),
                    ),
                  ),

                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            Text(dayLetterFromValue(value)),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  // add bars
                  barGroups: makeBarGroups(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

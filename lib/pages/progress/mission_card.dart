import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../general_widgets/info_card.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({
    Key? key,
    required this.info,
    this.onClick,
  }) : super(key: key);

  final MissionInfo info;
  final VoidCallback? onClick;

  String dateToString(DateTime date) {
    return date.toLocal().toString();
  }

  String durationToString(Duration duration) {
    String out = "";
    if (duration.inDays > 0) out += "${duration.inDays}d ";
    if (duration.inHours % 24 > 0) out += "${duration.inHours % 24}h ";
    if (duration.inMinutes % 60 > 0) out += "${duration.inMinutes % 60}m ";
    if (duration.inSeconds % 60 > 0) out += "${duration.inSeconds % 60}s";
    if (out.isEmpty) return "0 seconds";
    return out;
  }

  String getText() {
    return "Start: ${dateToString(info.startTime)}\n"
        "Duration: ${durationToString(info.duration()!)}\n"
        "Distance: ${info.length.toInt()}m";
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
        title: "Mission #${info.getIndex() + 1}",
        message: getText(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        messageTextAlign: TextAlign.start,
        onClick: onClick);
  }
}

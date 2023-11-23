import 'package:Stray/pages/progress/missions_map.dart';
import 'package:flutter/material.dart';

import '../../database/database.dart';

Future<void> showLoading(BuildContext context, Duration duration) async {
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
      transitionDuration: Duration.zero,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      opaque: false,
    ),
  );
  await Future.delayed(duration);
}

class MapPage extends StatelessWidget {
  const MapPage({Key? key, required this.missions, this.selectedMission})
      : super(key: key);

  final List<MissionInfo> missions;
  final MissionInfo? selectedMission;

  Future<bool> _onWillPop(BuildContext context) async {
    // see https://github.com/flutter/flutter/issues/105965
    await showLoading(context, const Duration(seconds: 1));
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _onWillPop(context);
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(missions.length > 1 ? 'Missions' : 'Mission View')),
        body: MissionsMap(missions: missions, selectedMission: selectedMission),
      ),
    );
  }
}

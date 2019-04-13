import 'package:flutter/material.dart';
import 'package:gps_distance/gps_distance.dart';
import 'package:omukae/data/gps_data.dart';

class DistanceLabel extends StatefulWidget {
  const DistanceLabel({
    Key key,
    this.targetPosition,
    this.currentPosition,
  }) : super(key: key);

  final GpsData targetPosition;
  final GpsData currentPosition;

  @override
  _DistanceLabelState createState() => _DistanceLabelState();
}

class _DistanceLabelState extends State<DistanceLabel> {
  Future<String> _updateDistanceText2() async {
    if (widget.targetPosition == null || widget.currentPosition == null) {
      return null;
    }

    var distanceInMeters = await GpsDistance.calculateDistance(
      widget.targetPosition.latitude,
      widget.targetPosition.longitude,
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
    );

    return (distanceInMeters / 1000.0).toStringAsFixed(2) + "km";
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _updateDistanceText2(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Text(
                  'distance ${snapshot.data}',
                  textAlign: TextAlign.right,
                )
              : Text(
                  'distance -',
                  textAlign: TextAlign.right,
                );
        });
  }
}

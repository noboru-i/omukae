import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:gps_distance/gps_distance.dart';

class DistanceLabel extends StatefulWidget {
  const DistanceLabel({
    Key key,
    this.targetPosition,
  }) : super(key: key);

  final LocationData targetPosition;

  @override
  _DistanceLabelState createState() => _DistanceLabelState();
}

class _DistanceLabelState extends State<DistanceLabel> {
  LocationData currentPosition;
  String label;

  void _initLocation() async {
    try {
      var currentLocation = await Location().getLocation();
      setState(() {
        currentPosition = currentLocation;
      });
    } on PlatformException catch (e) {
      debugPrint("exception: $e");
      debugPrint("is permission denied: ${e.code == 'PERMISSION_DENIED'}");
      return null;
    }
  }

  Future<String> _updateDistanceText2() async {
    if (widget.targetPosition == null || currentPosition == null) {
      return null;
    }

    var distanceInMeters = await GpsDistance.calculateDistance(
      widget.targetPosition.latitude,
      widget.targetPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    return (distanceInMeters / 1000.0).toStringAsFixed(2) + "km";
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
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

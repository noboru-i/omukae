import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class DistanceLabel extends StatefulWidget {
  const DistanceLabel({
    Key key,
    this.targetPosition,
  }) : super(key: key);

  final Position targetPosition;

  @override
  _DistanceLabelState createState() => _DistanceLabelState();
}

class _DistanceLabelState extends State<DistanceLabel> {
  Position currentPosition;
  String label;

  void _initLocation() async {
    try {
      var currentLocation = await Geolocator().getLastKnownPosition();
      if (currentLocation == null) {
        currentLocation = await Geolocator().getCurrentPosition();
      }
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

    var distanceInMeters = await Geolocator().distanceBetween(
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

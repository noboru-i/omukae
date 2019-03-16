import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectTargetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('目的地の選択'),
      ),
      body: MapContainer(),
//      body: Center(
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            MapContainer(),
//            RaisedButton(
//              padding: EdgeInsets.all(20.0),
//              color: Colors.lightBlue[100],
//              onPressed: () {},
//              child: Text('選択する'),
//            ),
//          ],
//        ),
//      ),
    );
  }
}

class MapContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapContainerState();
}

class MapContainerState extends State<MapContainer> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}

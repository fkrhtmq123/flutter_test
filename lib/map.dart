import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/provider/google_user_data_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() => runApp(MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: "Google Map",
      home: const MapPage(),
    ));

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late GoogleMapController mapController;

  // 現在位置変数
  LatLng _currentLocation = const LatLng(0, 0);

  Set<Marker> _markers = {};

  late StreamSubscription<Position> positionStream;

  void _onMapCreated(GoogleMapController controller) {
    // mapController = controller;
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    debugPrint("user : ${userData.currentUser!.email}");

    return Scaffold(
      appBar: AppBar(
        title: const Text("現在位置設定"),
        backgroundColor: Colors.green[700],
        actions: <Widget>[
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text("設定"),
                        content: const Text("現在位置を設定しますか？"),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: const Text("いいえ"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          CupertinoDialogAction(
                            child: const Text("はい"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
              child: const Text("設定"))
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 17.0,
        ),
        markers: _markers,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getCurrentLocation();

          if (context != null) {
            _showLocationSnacBar(_currentLocation);
          } else {
            debugPrint("Scaffold context is null");
          }
        },
        child: const Icon(Icons.work),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    GoogleMapController _mapController = await _controller.future;
    // 位置情報同意
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    // 現在位置の座標取得
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _markers = Set();
        _markers.add(Marker(
            markerId: MarkerId(_currentLocation.toString()),
            position: _currentLocation,
            infoWindow: InfoWindow(
                title: "現在位置",
                snippet:
                    "座標 : ${_currentLocation.latitude}, ${_currentLocation.longitude}"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed)));
      });
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }

    // 取得した現在位置に移動
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation, 15.0),
    );
  }

  void _showLocationSnacBar(LatLng location) {
    final snackBar = SnackBar(
      content: Text("現在位置座標 : ${location.latitude}, ${location.longitude}"),
      action: SnackBarAction(label: "閉じる", onPressed: () {}),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

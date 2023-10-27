import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'database/location_db.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String time;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.time,
  });
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  Position? currentLocation;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  void getPermission() async {
    final _locresult = await Permission.location.request();

    if (_locresult.isGranted) {
      getCurrentLocation();
      loadMarkersFromDatabase();
    } else if (_locresult.isDenied) {
      requestPermission();
    } else {
      manualPermission();
    }
  }

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final currentTime = DateTime.now();
    String formattedTime = _formatDateTime(currentTime);

    final locationData = LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      time: formattedTime,
    );

    int? locationId = await LocationDatabaseHelper.insertLocation(locationData);

    if (locationId != null) {
      setState(() {
        currentLocation = position;
        _markers.add(
          Marker(
            markerId: MarkerId(locationId.toString()),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(
              title: 'Current Location',
              snippet: formattedTime,
            ),
          ),
        );
      });

      GoogleMapController googleMapController = await _controller.future;
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
            target: LatLng(position.latitude, position.longitude),
          ),
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute} ${dateTime.hour >= 12 ? 'PM' : 'AM'}";
  }

  Future<void> loadMarkersFromDatabase() async {
    List<Map<String, dynamic>> locations =
        await LocationDatabaseHelper.getlocation();
    Set<Marker> markers = {};

    for (var location in locations) {
      LocationData locationCoordinate = LocationData(
        latitude: location['latitude'],
        longitude: location['longitude'],
        time: location['time'],
      );

      markers.add(
        Marker(
          markerId: MarkerId(location['id'].toString()),
          position:
              LatLng(locationCoordinate.latitude, locationCoordinate.longitude),
          infoWindow: InfoWindow(
            title: 'Recorded Location',
            snippet: locationCoordinate.time,
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition;
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
        target: LatLng(currentLocation!.latitude, currentLocation!.longitude),
        zoom: 13.5,
      );
    } else {
      //for default location if there is no current location
      initialCameraPosition = CameraPosition(
        target: LatLng(11.219439, 78.167725),
        zoom: 13.5,
      );
    }

    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  requestPermission() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Permission Required"),
            content: Text(
                "Please Allow Permission so that we can get your Location"),
            actions: [
              TextButton(
                  onPressed: () {
                    getPermission();
                    Navigator.of(context).pop();
                  },
                  child: Text("Okay"))
            ],
          );
        });
  }

  manualPermission() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Permission Required"),
            content: Text(
                "Please Allow Permission so that we can get your Location"),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        openAppSettings();
                      },
                      child: Text("Open App Settings")),
                  TextButton(
                      onPressed: () {
                        getPermission();
                        // AppRouter().pop(context);
                        Navigator.of(context).pop(true);
                      },
                      child: Text("Retry")),
                ],
              )
            ],
          );
        });
  }
}

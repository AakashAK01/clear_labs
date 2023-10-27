import 'dart:async';
import 'package:clear_labs/track_page.dart';
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
  List<Map<String, dynamic>> locations = [];
  Position? currentLocation;
  Set<Marker> _markers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getCurrentLocation();

    loadMarkersFromDatabase();
  }

  Future<void> getCurrentLocation() async {
    try {
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

      int? locationId =
          await LocationDatabaseHelper.insertLocation(locationData);

      if (locationId != null) {
        setState(() {
          currentLocation = position;
          _markers.add(
            Marker(
              markerId: MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: InfoWindow(
                title: 'Current Location',
                snippet: formattedTime,
              ),
            ),
          );
          isLoading = false;
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
    } catch (e) {
      print('Error fetching location: $e');
    } finally {}
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute} ${dateTime.hour >= 12 ? 'PM' : 'AM'}";
  }

  Future<void> loadMarkersFromDatabase() async {
    locations = await LocationDatabaseHelper.getlocation();
    print("${locations.length}:LENGTH: ");
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
      _markers.addAll(markers);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(isLoading);
    print("${currentLocation}:POSITION");
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: _getInitialCameraPosition(),
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
                ],
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => TrackPage()),
            );
          },
          child: Icon(Icons.map_outlined),
        ),
      ),
    );
  }

  CameraPosition _getInitialCameraPosition() {
    int length = locations.length;
    print(length);
    print(currentLocation);
    double initialLatitude = 0;
    double initialLongitude = 0;

    if (currentLocation != null) {
      initialLatitude = currentLocation!.latitude;
      initialLongitude = currentLocation!.longitude;
    } else if (length > 0 || currentLocation == null) {
      initialLatitude = locations[length - 1]['latitude'];
      initialLongitude = locations[length - 1]['longitude'];
    }

    return CameraPosition(
      target: LatLng(initialLatitude, initialLongitude),
      zoom: 13.5,
    );
  }
}

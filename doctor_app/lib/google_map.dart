import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyGooglemap extends StatefulWidget {
  const MyGooglemap({super.key});

  @override
  State<MyGooglemap> createState() => _MyGooglemapState();
}

class _MyGooglemapState extends State<MyGooglemap> {
  late GoogleMapController mapController;
  final LatLng centre = const LatLng(1.3815, 103.7649);
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: centre, zoom: 11.0),
        onMapCreated: onMapCreated,
      ),
    );
  }
}

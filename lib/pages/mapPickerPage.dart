import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? selectedLocation;
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    determinePosition();
  }

  Future<void> determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location' , style: TextStyle(color: Colors.white),) 
      , backgroundColor: Theme.of(context).primaryColor, leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(Icons.arrow_back , color: Colors.white,)),),
      // backgroundColor: Colors.white,
      
      // body: GoogleMap(
      //   initialCameraPosition: const CameraPosition(
      //     target: LatLng(20.5937, 78.9629), // Default to center of India
      //     zoom: 5,
      //   ),
      //   onTap: (LatLng latLng) {
      //     setState(() => selectedLocation = latLng);
      //   },
      //   markers: selectedLocation != null
      //       ? {
      //           Marker(markerId: const MarkerId("selected"), position: selectedLocation!)
      //         }
      //       : {},
      //   onMapCreated: (GoogleMapController controller) {
      //     mapController = controller;
      //   },
      // ),
        body: GoogleMap(
    initialCameraPosition: CameraPosition(
      target: LatLng(37.7749, -122.4194),
      zoom: 10,
    ),
  ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedLocation != null) {
            Navigator.of(context).pop(selectedLocation);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

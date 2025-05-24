import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


 final googleApiKey = dotenv.env['google_map_api'];

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? selectedLocation;
  late GoogleMapController mapController;

  double fabX = 20;
  double fabY = 600;

  final places = GoogleMapsPlaces(apiKey: '$googleApiKey');

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

  Future<void> handleSearch() async {
    final prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: '$googleApiKey',
      
      mode: Mode.overlay,
      language: 'en',
      components: [Component(Component.country, "in")],
      
    );
    
    if (prediction != null) {
      final detail = await places.getDetailsByPlaceId(prediction.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      final newLocation = LatLng(lat, lng);
      setState(() => selectedLocation = newLocation);
      mapController.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 15));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location', style: TextStyle(color: Colors.white)),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back , color: Colors.white,)),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: handleSearch,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.5937, 78.9629),
              zoom: 5,
            ),
            onTap: (LatLng latLng) {
              setState(() => selectedLocation = latLng);
            },
            markers: selectedLocation != null
                ? {Marker(markerId: const MarkerId("selected"), position: selectedLocation!)}
                : {},
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          Positioned(
            left: fabX,
            top: fabY,
            child: Draggable(
              feedback: _buildFab(),
              childWhenDragging: const SizedBox.shrink(),
              onDragEnd: (details) {
                setState(() {
                  fabX = details.offset.dx;
                  fabY = details.offset.dy - AppBar().preferredSize.height;
                });
              },
              child: _buildFab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        if (selectedLocation != null) {
          Navigator.of(context).pop(selectedLocation);
        }
      },
      child: const Icon(Icons.check),
    );
  }
}

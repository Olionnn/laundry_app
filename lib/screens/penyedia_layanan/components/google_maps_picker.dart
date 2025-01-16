import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class GoogleMapsPicker extends StatefulWidget {
  const GoogleMapsPicker({super.key});

  @override
  State<GoogleMapsPicker> createState() => _GoogleMapsPickerState();
}

class _GoogleMapsPickerState extends State<GoogleMapsPicker> {
  LatLng? _selectedLocation;
  CameraPosition? _initialCameraPosition;
  TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  // Set initial location to current location
  Future<void> _setInitialLocation() async {
    try {
      await _checkPermissions();
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        );
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('selected'),
          position: _selectedLocation!,
        ));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: ${e.toString()}')),
      );
      setState(() {
        _initialCameraPosition = const CameraPosition(
          target: LatLng(-6.176123, 106.830201), // Default location
          zoom: 15,
        );
      });
    }
  }

  // Request permissions
  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, cannot request permissions.');
    }
  }

  // Function to handle search query with debouncing
  void _searchLocation(String query) async {
    if (query.isEmpty) return;

    // Cancel previous search query if any
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Start a new debounce
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=APIKEY',
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['predictions'] != null && data['predictions'].isNotEmpty) {
          final placeId = data['predictions'][0]['place_id'];
          await _fetchPlaceDetails(placeId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No results found for this search')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error fetching places: ${response.statusCode}')),
        );
      }
    });
  }

  // Fetch detailed place information (latitude and longitude)
  Future<void> _fetchPlaceDetails(String placeId) async {
    final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=APIKEY',
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final lat = data['result']['geometry']['location']['lat'];
      final lng = data['result']['geometry']['location']['lng'];

      setState(() {
        _selectedLocation = LatLng(lat, lng);
        _initialCameraPosition = CameraPosition(
          target: _selectedLocation!,
          zoom: 15,
        );
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('selected'),
          position: _selectedLocation!,
        ));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error fetching place details: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a place',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                _searchLocation(query);
              },
            ),
          ),
          Expanded(
            child: _initialCameraPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: _initialCameraPosition!,
                    onTap: (LatLng position) {
                      setState(() {
                        _selectedLocation = position;
                        _markers.clear();
                        _markers.add(Marker(
                          markerId: const MarkerId('selected'),
                          position: _selectedLocation!,
                        ));
                      });
                    },
                    markers: _markers,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedLocation != null) {
            Navigator.pop(context, _selectedLocation);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a location')),
            );
          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.check),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_layanan_screen.dart'; // Import the detail screen

class GMapsLayananScreen extends StatefulWidget {
  const GMapsLayananScreen({Key? key}) : super(key: key);

  @override
  _GMapsLayananScreenState createState() => _GMapsLayananScreenState();
}

class _GMapsLayananScreenState extends State<GMapsLayananScreen> {
  final String apiKey =
      'AIzaSyCw3vsFQ-pgLbJpiE2LsKK_L-6C4HzXBX0'; // Replace with your Google API Key
  final Location location = Location();
  bool _isLoading = false;
  List<dynamic> laundryPlaces = [];
  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  /// Fetch user's location
  Future<void> _getUserLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        final bool serviceRequested = await location.requestService();
        if (!serviceRequested) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        final PermissionStatus permissionRequested =
            await location.requestPermission();
        if (permissionRequested != PermissionStatus.granted) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final locData = await location.getLocation();
      userLat = locData.latitude;
      userLng = locData.longitude;

      await _fetchLaundryPlaces();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to fetch location')),
      );
      setState(() => _isLoading = false);
    }
  }

  /// Fetch laundry places near the user's location
  Future<void> _fetchLaundryPlaces() async {
    if (userLat == null || userLng == null) {
      setState(() => _isLoading = false);
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$userLat,$userLng&radius=5000&keyword=laundry&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            laundryPlaces = data['results'];
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['status']}')),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to fetch data from API')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to fetch data')),
      );
    }
  }

  Future<void> _getDetailedPlaceData(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          // Navigate to DetailLayananScreen with the selected place data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailLayananScreen(
                gMapsData: data['result'], // Pass the place data
                isFromGMaps: true, // Indicate it's from Google Maps
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['status']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to fetch data from API')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to fetch data')),
      );
    }
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(lat1, lng1, lat2, lng2) {
    const double R = 6371; // Radius of Earth in km
    double dLat = (lat2 - lat1) * (pi / 180.0);
    double dLng = (lng2 - lng1) * (pi / 180.0);
    double a = 0.5 -
        cos(dLat) / 2 +
        cos(lat1 * (pi / 180.0)) *
            cos(lat2 * (pi / 180.0)) *
            (1 - cos(dLng)) /
            2;

    return R * 2 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : laundryPlaces.isEmpty
              ? const Center(
                  child: Text(
                    "No laundry services found nearby.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: laundryPlaces.length,
                  itemBuilder: (context, index) {
                    final place = laundryPlaces[index];
                    final distance = _calculateDistance(
                      userLat!,
                      userLng!,
                      place['geometry']['location']['lat'],
                      place['geometry']['location']['lng'],
                    );

                    return Card(
                      color: Colors.white12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                          title: Text(
                            place['name'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Distance: ${distance.toStringAsFixed(2)} km\n"
                            "Rating: ${place['rating'] ?? 'No rating'}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Text(
                            place['opening_hours']?['open_now'] == true
                                ? "Open"
                                : "Closed",
                            style: TextStyle(
                              color: place['opening_hours']?['open_now'] == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () async {
                            await _getDetailedPlaceData(place['place_id']);
                          }

                          ),
                    );
                  },
                ),
    );
  }
}

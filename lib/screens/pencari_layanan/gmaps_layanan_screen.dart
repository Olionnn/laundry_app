import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const GMapsLayananScreen(),
    );
  }
}

class GMapsLayananScreen extends StatefulWidget {
  const GMapsLayananScreen({Key? key}) : super(key: key);

  @override
  State<GMapsLayananScreen> createState() => _GMapsLayananScreenState();
}

class _GMapsLayananScreenState extends State<GMapsLayananScreen> {
  final String apiKey = 'YOUR_GOOGLE_API_KEY'; // Ganti dengan API Key Anda
  Location location = Location();
  bool _isLoading = false;
  List<dynamic> laundryPlaces = [];

  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoading = true;
    });

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    final locData = await location.getLocation();
    userLat = locData.latitude;
    userLng = locData.longitude;

    await _fetchLaundryPlaces();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchLaundryPlaces() async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$userLat,$userLng&radius=5000&keyword=laundry&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        setState(() {
          laundryPlaces = data['results'];
        });
      } else {
        print("Error from API: ${data['status']}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  double _calculateDistance(lat1, lng1, lat2, lng2) {
    const double R = 6371; // Radius Bumi dalam km
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
      appBar: AppBar(
        title: const Text("Laundry Nearby"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : laundryPlaces.isEmpty
              ? const Center(child: Text("No laundry services found nearby."))
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

                    return ListTile(
                      title: Text(place['name']),
                      subtitle:
                          Text("Distance: ${distance.toStringAsFixed(2)} km"),
                      trailing: Text(place['vicinity']),
                    );
                  },
                ),
    );
  }
}

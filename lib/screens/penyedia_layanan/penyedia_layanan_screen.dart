import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:laundry_app/models/penyedia_layanan.dart';
import 'package:laundry_app/screens/penyedia_layanan/components/main_layout.dart';
import 'package:laundry_app/services/penyedia_layanan_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HalamanPenyediaLayanan extends StatefulWidget {
  const HalamanPenyediaLayanan({super.key});

  @override
  State<HalamanPenyediaLayanan> createState() => _HalamanPenyediaLayananState();
}

class _HalamanPenyediaLayananState extends State<HalamanPenyediaLayanan> {
  Future<List<Map<String, dynamic>>> _fetchRequests() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User ID not found in preferences');
      }

      final penyediaLayanan =
          await PenyediaLayananService.getPenyediaLayananProfile(userId);

      if (penyediaLayanan == null) {
        throw Exception('Penyedia layanan not found');
      }

      return [
        {
          'id': penyediaLayanan.id,
          'nama_toko': penyediaLayanan.namaToko,
          'alamat': penyediaLayanan.alamat,
          'deskripsi': penyediaLayanan.deskripsi,
          'lat': penyediaLayanan.lat,
          'long': penyediaLayanan.long,
        }
      ];
    } catch (e) {
      throw Exception('Failed to fetch requests: $e');
      
    }
  }

  void _refreshPage() {
    setState(() {}); // Triggers rebuild
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Dashboard Penyedia Layanan',
      currentIndex: 0,
      onTabTapped: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/profile_layanan').then((_) {
            _refreshPage(); // Refresh state when returning
          });
        } else if (index == 2) {
          Navigator.pushNamed(context, '/login');
        }
      },
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading requests: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No requests available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final requests = snapshot.data!;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                color: Colors.white12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['nama_toko'] ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        request['deskripsi'] ?? 'No description',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        request['alamat'] ?? 'No address available',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              request['lat'] ?? 0.0,
                              request['long'] ?? 0.0,
                            ),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(request['id'].toString()),
                              position: LatLng(
                                request['lat'] ?? 0.0,
                                request['long'] ?? 0.0,
                              ),
                              infoWindow: InfoWindow(
                                title: request['nama_toko'],
                                snippet: request['alamat'],
                              ),
                            ),
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/detail_request_layanan',
                            arguments: request['id'], // Pass request ID
                          ).then((_) {
                            _refreshPage(); // Refresh page on return
                          });
                        },
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

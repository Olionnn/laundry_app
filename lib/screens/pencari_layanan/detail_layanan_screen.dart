import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:laundry_app/models/penyedia_layanan.dart';
import 'package:laundry_app/services/penyedia_layanan_services.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailLayananScreen extends StatefulWidget {
  final int layananId;
  const DetailLayananScreen({super.key, required this.layananId});

  @override
  State<DetailLayananScreen> createState() => _DetailLayananScreenState();
}

class _DetailLayananScreenState extends State<DetailLayananScreen> {
  bool _isLoading = true;
  PenyediaLayanan? _layanan;

  @override
  void initState() {
    super.initState();
    _fetchLayananDetail();
  }

  Future<void> _fetchLayananDetail() async {
    try {
      final layanan =
          await PenyediaLayananService.getDetailLayanan(widget.layananId);
      setState(() {
        _layanan = layanan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _redirectToGoogleMaps(String latitude, String longitude) async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Layanan ${widget.layananId}'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _layanan == null
              ? const Center(
                  child: Text(
                    'Data tidak ditemukan',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Nama Toko'),
                      _buildDetailText(_layanan!.namaToko),
                      const SizedBox(height: 10),
                      _buildSectionTitle('Deskripsi'),
                      _buildDetailText(_layanan!.deskripsi),
                      const SizedBox(height: 10),
                      _buildSectionTitle('Alamat'),
                      _buildDetailText(_layanan!.alamat),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Lokasi'),
                      SizedBox(
                        height: 200,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              double.parse(_layanan!.lat),
                              double.parse(_layanan!.long),
                            ),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('location'),
                              position: LatLng(
                                double.parse(_layanan!.lat),
                                double.parse(_layanan!.long),
                              ),
                              onTap: () => _redirectToGoogleMaps(
                                _layanan!.lat,
                                _layanan!.long,
                              ),
                            ),
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildButton(
                            label: 'Kembali',
                            color: Colors.deepPurple,
                            onPressed: () => Navigator.pop(context),
                          ),
                          _buildButton(
                            label: 'Pesan',
                            color: Colors.green,
                            onPressed: () {
                              // Handle redirect to ordering screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Redirect ke Pemesanan')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDetailText(String detail) {
    return Text(
      detail,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:laundry_app/models/penyedia_layanan.dart';
import 'package:laundry_app/screens/pencari_layanan/components/quisioner_formdb_screen.dart';
import 'package:laundry_app/screens/pencari_layanan/components/quisioner_layanan_screen.dart';
import 'package:laundry_app/services/penyedia_layanan_services.dart';
import 'package:laundry_app/widgets/responsive_container.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailLayananScreen extends StatefulWidget {
  final int? layananId; // For database items
  final dynamic gMapsData; // For Google Maps data
  final bool isFromGMaps;

  const DetailLayananScreen({
    super.key,
    this.layananId,
    this.gMapsData,
    required this.isFromGMaps,
  });

  @override
  State<DetailLayananScreen> createState() => _DetailLayananScreenState();
}

class _DetailLayananScreenState extends State<DetailLayananScreen> {
  bool _isLoading = true;
  PenyediaLayanan? _layanan; // For database items

  @override
  void initState() {
    super.initState();
    if (!widget.isFromGMaps) {
      _fetchLayananDetail();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLayananDetail() async {
    try {
      final layanan =
          await PenyediaLayananService.getDetailLayanan(widget.layananId!);
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
        title: Text(widget.isFromGMaps
            ? widget.gMapsData['name'] ?? 'Detail Layanan'
            : _layanan?.namaToko ?? 'Detail Layanan'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveContainer(
              child: SingleChildScrollView(
                child: widget.isFromGMaps
                    ? _buildGMapsDetails()
                    : _layanan == null
                        ? const Center(
                            child: Text(
                              'Data tidak ditemukan',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : _buildDatabaseDetails(),
              ),
            ),
    );
  }

  /// Build UI for Google Maps data
  Widget _buildGMapsDetails() {
    final location = widget.gMapsData['geometry']?['location'];
    final lat = location?['lat'];
    final lng = location?['lng'];
    final openingHours =
        widget.gMapsData['current_opening_hours']?['weekday_text'] ?? [];
    final ownerName = widget.gMapsData['name'] ?? 'Tidak tersedia';
    final ownerPhone =
        widget.gMapsData['international_phone_number'] ?? 'Tidak tersedia';
    final ownerEmail = widget.gMapsData['email'] ?? 'Tidak tersedia';
    final description =
        widget.gMapsData['description'] ?? 'Deskripsi tidak tersedia';
    final reviews = widget.gMapsData['reviews'] ?? [];

    if (lat == null || lng == null) {
      return const Center(
        child: Text(
          'Data lokasi tidak tersedia',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Nama Toko'),
        _buildDetailText(widget.gMapsData['name'] ?? 'Unknown'),
        const SizedBox(height: 10),
        _buildSectionTitle('Deskripsi'),
        _buildDetailText(description),
        const SizedBox(height: 10),
        _buildSectionTitle('Alamat'),
        _buildDetailText(
            widget.gMapsData['formatted_address'] ?? 'Alamat tidak tersedia'),
        const SizedBox(height: 10),
        _buildSectionTitle('Pemilik'),
        _buildDetailText('Nama: $ownerName'),
        _buildDetailText('No HP: $ownerPhone'),
        _buildDetailText('Email: $ownerEmail'),
        const SizedBox(height: 20),
        _buildSectionTitle('Lokasi'),
        SizedBox(
          height: 200,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, lng),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('gmaps_location'),
                position: LatLng(lat, lng),
                onTap: () =>
                    _redirectToGoogleMaps(lat.toString(), lng.toString()),
              ),
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Rating & Ulasan'),
        if (reviews.isNotEmpty)
          Column(
            children: reviews.map<Widget>((review) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailText('⭐ ${review['rating']}'),
                  _buildDetailText(review['text'] ?? 'Ulasan tidak tersedia'),
                  const SizedBox(height: 10),
                ],
              );
            }).toList(),
          )
        else
          _buildDetailText('Tidak ada ulasan'),
        const SizedBox(height: 20),
        _buildSectionTitle('Jadwal Buka'),
        if (openingHours.isNotEmpty)
          Column(
            children: openingHours.map<Widget>((day) {
              return _buildDetailText(day);
            }).toList(),
          )
        else
          _buildDetailText('Jadwal tidak tersedia'),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return QuisionerLayananScreen(phoneNumber: ownerPhone);
                }));
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Build UI for database data
  Widget _buildDatabaseDetails() {
    return Column(
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
        const SizedBox(height: 10),
        _buildSectionTitle('Pemilik'),
        _buildDetailText('Nama: ${_layanan!.ownerName ?? 'Tidak tersedia'}'),
        _buildDetailText('No HP: ${_layanan!.ownerPhone ?? 'Tidak tersedia'}'),
        _buildDetailText('Email: ${_layanan!.ownerEmail ?? 'Tidak tersedia'}'),
        const SizedBox(height: 20),
        _buildSectionTitle('Lokasi'),
        SizedBox(
          height: 200,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_layanan!.lat, _layanan!.long),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('db_location'),
                position: LatLng(_layanan!.lat, _layanan!.long),
                onTap: () => _redirectToGoogleMaps(
                  _layanan!.lat.toString(),
                  _layanan!.long.toString(),
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
                print("Layanan ID: ${_layanan!.id}");
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CreatePesananScreen(id: _layanan!.id);
                }));
              },
            ),
          ],
        ),
      ],
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

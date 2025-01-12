import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:laundry_app/screens/penyedia_layanan/components/createedit_layanan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laundry_app/services/penyedia_layanan_services.dart';
import 'package:laundry_app/models/penyedia_layanan.dart';

class ProfileLayananScreen extends StatefulWidget {
  const ProfileLayananScreen({super.key});

  @override
  State<ProfileLayananScreen> createState() => _ProfileLayananScreenState();
}

class _ProfileLayananScreenState extends State<ProfileLayananScreen> {
  bool _isLoading = true;
  PenyediaLayanan? _layanan;

  int? userId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      setState(() {
        this.userId = userId;
      });
      await _fetchLayanan();
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
    }
  }

  Future<void> _fetchLayanan() async {
    if (userId == null) return;

    try {
      final layanan =
          await PenyediaLayananService.getPenyediaLayananProfile(userId!);

      setState(() {
        _layanan = layanan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching layanan: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Layanan'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _layanan == null
              ? _buildNoLayanan(context)
              : _buildLayananView(context),
    );
  }

  Widget _buildNoLayanan(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEditLayananScreen(),
            ),
          ).then((_) => _fetchLayanan()); // Refresh the profile on return
        },
        child: const Text('Create Layanan'),
      ),
    );
  }

  Widget _buildLayananView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nama Toko: ${_layanan!.namaToko}',
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          Text('Deskripsi: ${_layanan!.deskripsi}',
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          Text('Alamat: ${_layanan!.alamat}',
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 20),
          _buildMap(), // Display the map
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateEditLayananScreen(layanan: _layanan?.toJson()),
                ),
              ).then((_) => _fetchLayanan()); // Refresh profile after editing
            },
            child: const Text('Edit Layanan'),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_layanan!.lat, _layanan!.long),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId(_layanan!.id.toString()),
            position: LatLng(_layanan!.lat, _layanan!.long),
            infoWindow: InfoWindow(
              title: _layanan!.namaToko,
              snippet: _layanan!.alamat,
            ),
          ),
        },
      ),
    );
  }
}

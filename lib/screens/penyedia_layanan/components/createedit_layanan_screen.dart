import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:laundry_app/services/penyedia_layanan_services.dart';
import 'package:laundry_app/screens/penyedia_layanan/components/google_maps_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateEditLayananScreen extends StatefulWidget {
  final Map<String, dynamic>? layanan;

  const CreateEditLayananScreen({this.layanan, super.key});

  @override
  State<CreateEditLayananScreen> createState() =>
      _CreateEditLayananScreenState();
}

class _CreateEditLayananScreenState extends State<CreateEditLayananScreen> {
  final TextEditingController _namaTokoController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  int? _userId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();

    // Pre-fill fields if editing an existing layanan
    if (widget.layanan != null) {
      _namaTokoController.text = widget.layanan!['nama_toko'] ?? '';
      _deskripsiController.text = widget.layanan!['deskripsi'] ?? '';
      _alamatController.text = widget.layanan!['alamat'] ?? '';
      _latController.text = widget.layanan!['lat'].toString();
      _longController.text = widget.layanan!['long'].toString();
    }
  }

  Future<void> _initializeUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found in preferences')),
      );
    }
  }

  Future<void> _syncLocation() async {
    try {
      await _checkPermissions();
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latController.text = position.latitude.toString();
        _longController.text = position.longitude.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location synchronized successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error syncing location: ${e.toString()}')),
      );
    }
  }

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

  Future<void> _saveLayanan() async {
    try {
      if (_userId == null) {
        throw Exception('User ID not found. Please log in again.');
      }

      if (_namaTokoController.text.isEmpty ||
          _deskripsiController.text.isEmpty ||
          _alamatController.text.isEmpty ||
          _latController.text.isEmpty ||
          _longController.text.isEmpty) {
        throw Exception('Please fill in all fields before saving.');
      }

      if (widget.layanan == null) {
        // Create new layanan
        await PenyediaLayananService.createLayananProfile(
          _namaTokoController.text,
          _deskripsiController.text,
          _alamatController.text,
          _latController.text,
          _longController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan created successfully!')),
        );
      } else {
        // Update existing layanan
        await PenyediaLayananService.updateLayananProfile(
          widget.layanan!['id'].toString(),
          {
            'nama_toko': _namaTokoController.text,
            'deskripsi': _deskripsiController.text,
            'alamat': _alamatController.text,
            'lat': _latController.text,
            'long': _longController.text,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan updated successfully!')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving layanan: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.layanan == null ? 'Create Layanan' : 'Edit Layanan'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField('Nama Toko', _namaTokoController),
            _buildTextField('Deskripsi', _deskripsiController),
            _buildTextField('Alamat', _alamatController),
            _buildTextField('Latitude', _latController, editable: false),
            _buildTextField('Longitude', _longController, editable: false),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _syncLocation,
              child: const Text('Sync Location'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final LatLng? selectedLocation = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GoogleMapsPicker()),
                );
                if (selectedLocation != null) {
                  setState(() {
                    _latController.text = selectedLocation.latitude.toString();
                    _longController.text =
                        selectedLocation.longitude.toString();
                  });
                }
              },
              child: const Text('Pick Location on Map'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveLayanan,
              child: Text(
                  widget.layanan == null ? 'Create Layanan' : 'Update Layanan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool editable = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        enabled: editable,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
        ),
      ),
    );
  }
}
